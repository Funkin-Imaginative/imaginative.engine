package backend.scripting;

import backend.scripting.types.HaxeScript;
import backend.scripting.types.InvaildScript;
import backend.scripting.types.LuaScript;

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
	 * States that this script instance is an invaild language script.
	 */
	var TypeInvaild = 'Invaild';

	/**
	 * If true, this script can't actaully be used for anything.
	 */
	public var dummy(get, never):Bool;
	@SuppressWarnings('checkstyle:FieldDocComment') inline function get_dummy():Bool
		return this == TypeUnregistered || this == TypeInvaild;
}

/**
 * All your scripting needs are right here!
 * @author Class started by @Zyflx. Expanded on by @rodney528.
 */
class Script extends FlxBasic implements IScript {
	@:allow(backend.system.Main)
	static function init():Void {
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

	/**
	 * All possible script extension types.
	 */
	public static var exts(default, null):Array<String> = ['hx', 'lua'];

	/**
	 * This variable holds the root path of where this the script is located.
	 */
	public var rootPath:String;
	/**
	 * This variable holds the mod path of where this the script is located.
	 */
	public var path:String;
	/**
	 * This variable holds the name of the script.
	 */
	public var name:String;
	/**
	 * This variable holds the name of the file extension.
	 */
	public var extension:String;

	/**
	 * Creates a script instance(s).
	 * @param file The mod path.
	 * @param pathType Specify path instances.
	 * @param getAllInstances If it should get all possible scripts in loaded mods with `file` name.
	 * @return `Array<Script>`
	 */
	public static function create(file:String, pathType:ModType = ANY, getAllInstances:Bool = true):Array<Script> {
		var scriptPath:String->Array<String> = (file:String) -> {
			if (getAllInstances) {
				var result:Array<String> = [];
				for (ext in exts)
					for (instance in ModConfig.getAllInstancesOfFile('$file.$ext', pathType))
						result.push(instance);
				return result;
			} else return [Paths.script(file, pathType)];
		}
		final paths:Array<String> = scriptPath(file);
		var scripts:Array<Script> = [];
		for (path in paths) {
			switch (FilePath.extension(path).toLowerCase()) {
				case 'haxe' | 'hx' | 'hscript' | 'hsc' | 'hxs' | 'hxc' | 'hxp':
					scripts.push(new HaxeScript(path));
				case 'lua':
					scripts.push(new LuaScript(path));
				default:
					scripts.push(new InvaildScript(path));
			}
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
			case 'InvaildScript': 	TypeInvaild;
			default:              	TypeUnregistered;
		}
	}

	function renderNecessities():Void {}

	function new(path:String, ?code:String):Void {
		if (code == null) {
			rootPath = path;
			name = FilePath.withoutDirectory(path);
			extension = FilePath.extension(path);
			this.path = path;
		}
		super();
		renderScript(path);
		renderNecessities();
		if (code == null) {
			scripts.push(this);
			GlobalScript.call('scriptCreated', [this, type]);
		}
	}

	var code:String = '';
	function renderScript(path:String, ?code:String):Void {}
	function loadCodeString(code:String):Void {}

	/**
	 * Load's code from string.
	 * @param code The script code.
	 * @param vars Variables to input into the script instance.
	 * @param funcToRun Function to run inside the script instance.
	 * @param fungArgs Arguments to run for said function.
	 * @return `Script` ~ The script instance from string.
	 */
	public function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?fungArgs:Array<Dynamic>):Script return this;

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
	function get_parent():Dynamic return null;
	function set_parent(value:Dynamic):Dynamic return value = null;

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
	public function get(variable:String, ?def:Dynamic):Dynamic return def;
	/**
	 * Call's a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @return `Dynamic` ~ Whatever is in the functions return statement.
	 */
	public function call(func:String, ?args:Array<Dynamic>):Dynamic return null;
	/**
	 * Call's a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	public function event<SC:ScriptEvent>(func:String, event:SC):SC return event;

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
