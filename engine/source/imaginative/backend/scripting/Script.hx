package imaginative.backend.scripting;

import imaginative.backend.scripting.types.HaxeScript;
import imaginative.backend.scripting.types.InvalidScript;
import imaginative.backend.scripting.types.LuaScript;

/**
 * Help's clarify a script language instance.
 */
enum abstract ScriptType(String) from String to String {
	/**
	 * States that this script instance is a unregistered language script.
	 */
	var TypeUnregistered = 'Unregistered';
	/**
	 * States that this script instance is a haxe language script.
	 */
	var TypeHaxe = 'Haxe';
	/**
	 * States that this script instance is a lua language script.
	 */
	var TypeLua = 'Lua';
	/**
	 * States that this script instance is an invalid language script.
	 */
	var TypeInvalid = 'Invalid';

	/**
	 * If true, this script can't actually be used for anything.
	 */
	public var dummy(get, never):Bool;
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function get_dummy():Bool
		return this == TypeUnregistered || this == TypeInvalid;
}

/**
 * All your scripting needs are right here!
 * @author Class started by @Zyflx. Expanded on by @rodney528.
 */
class Script extends FlxBasic implements IScript {
	@:allow(imaginative.backend.system.Main)
	inline static function init():Void {
		exts = [
			for (exts in [HaxeScript.exts, LuaScript.exts])
				for (ext in exts)
					ext
		];
	}

	/**
	 * Every script instance created.
	 */
	public static var scripts:Array<Script> = [];
	public static var staticVars:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * All possible script extension types.
	 */
	public static var exts(default, null):Array<String> = ['hx', 'lua'];

	/**
	 * This variable holds the name of the script.
	 */
	public var name(get, never):String;
	inline function get_name():String
		return FilePath.withoutDirectory(pathing.path);
	/**
	 * Contains the mod path information.
	 */
	public var pathing(default, null):ModPath;
	/**
	 * This variable holds the name of the file extension.
	 */
	public var extension(get, never):String;
	inline function get_extension():String
		return pathing.extension;

	/**
	 * Creates a script instance(s).
	 * @param file The mod path.
	 * @param getAllInstances If it should get all possible scripts in loaded mods with `file` name.
	 * @return `Array<Script>`
	 */
	public static function create(file:ModPath, getAllInstances:Bool = true):Array<Script> {
		#if MOD_SUPPORT
		var scriptPath:ModPath->Array<String> = (file:ModPath) -> {
			if (getAllInstances) {
				var result:Array<String> = [];
				for (ext in exts)
					for (instance in Modding.getAllInstancesOfFile('${file.path}.$ext', file.type, true))
						result.push(instance);
				return result;
			} else return [Paths.script(file).format()];
		}
		var paths:Array<String> = scriptPath(file);
		#else
		var paths:Array<String> = [Paths.script(file).format()];
		#end

		var scripts:Array<Script> = [];
		for (path in paths) {
			var extension:String = FilePath.extension(path).toLowerCase();
			if (exts.contains(extension)) {
				if (HaxeScript.exts.contains(extension))
					scripts.push(new HaxeScript(path));
				if (LuaScript.exts.contains(extension))
					scripts.push(new LuaScript(path));
			} else scripts.push(new InvalidScript(path));
		}
		return scripts;
	}

	var canRun:Bool = false;
	/**
	 * States the type of script this is.
	 */
	public var type(get, never):ScriptType;
	inline function get_type():ScriptType {
		return switch (this.getClassName()) {
			case 'Script':        	TypeUnregistered;
			case 'HaxeScript':    	TypeHaxe;
			case 'LuaScript':     	TypeLua;
			case 'InvalidScript': 	TypeInvalid;
			default:              	TypeUnregistered;
		}
	}

	function renderNecessities():Void {}

	function new(file:ModPath, ?code:String):Void {
		if (code == null)
			pathing = file;
		super();
		renderScript(pathing);
		renderNecessities();
		if (code == null) {
			scripts.push(this);
			GlobalScript.call('scriptCreated', [this, type]);
		}
	}

	var code:String = '';
	function renderScript(file:ModPath, ?code:String):Void {
		try {
			var content:String = Assets.text(file);
			this.code = content.trim() == '' ? code : content;
		} catch(error:haxe.Exception) {
			log('Error while trying to get script contents: ${error.message}', ErrorMessage);
			this.code = '';
		}
	}
	function loadCodeString(code:String):Void {}

	/**
	 * Load's code from string.
	 * @param code The script code.
	 * @param vars Variables to input into the script instance.
	 * @param funcToRun Function to run inside the script instance.
	 * @param funcArgs Arguments to run for said function.
	 * @return `Script` ~ The script instance from string.
	 */
	/* public static function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?funcArgs:Array<Dynamic>):Script
		return this; */

	/**
	 * States if the script has loaded.
	 */
	public var loaded(default, null):Bool = false;
	/**
	 * Load's the script, pretty self-explanatory.
	 */
	public function load():Void
		if (!loaded)
			loadCodeString(code);
	/**
	 * Reload's the script, pretty self-explanatory.
	 * Only if it's possible for that script type.
	 */
	public function reload():Void {}

	/**
	 * The parent object that the script is tied to.
	 */
	public var parent(get, set):Dynamic;
	function get_parent():Dynamic
		return null;
	function set_parent(value:Dynamic):Dynamic
		return value = null;

	/**
	 * Set's the public map for getting global variables.
	 * @param map The map itself.
	 */
	public function setPublicMap(map:Map<String, Dynamic>):Void {}

	/**
	 * Set's a variable to the script.
	 * @param variable The variable to apply.
	 * @param value The value the variable will hold.
	 */
	public function set(variable:String, value:Dynamic):Void {}
	/**
	 * Get's a variable from the script.
	 * @param variable The variable to receive.
	 * @param def If it's null then return this.
	 * @return `Dynamic` ~ The value the variable will hold.
	 */
	public function get(variable:String, ?def:Dynamic):Dynamic
		return def;
	/**
	 * Call's a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @return `Dynamic` ~ Whatever is in the functions return statement.
	 */
	public function call(func:String, ?args:Array<Dynamic>):Dynamic
		return null;
	/**
	 * Call's a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	public function event<SC:ScriptEvent>(func:String, event:SC):SC
		return event;

	/**
	 * End's the script.
	 * @param funcName Custom function call name.
	 */
	inline public function end(funcName:String = 'end'):Void {
		call(funcName);
		destroy();
	}

	override public function destroy():Void {
		GlobalScript.call('scriptDestroyed', [this, type]);
		if (scripts.contains(this))
			scripts.remove(this);
		super.destroy();
	}
}
