package imaginative.backend.scripting;

import imaginative.backend.scripting.types.HaxeScript;
import imaginative.backend.scripting.types.InvalidScript;
import imaginative.backend.scripting.types.LuaScript;

/**
 * Helps clarify a script language instance.
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
 * Class started by @Zyflx, expanded on by @rodney528.
 * @author @Zyflx & @rodney528
 */
class Script implements IFlxDestroyable implements IScript {
	/**
	 * Every script instance that currently exists.
	 */
	public static var scripts:Array<IScript> = [];
	/**
	 * All possible script extension types.
	 */
	public static var exts(get, never):Array<String>;
	inline static function get_exts():Array<String> {
		return [
			for (exts in [HaxeScript.exts, LuaScript.exts])
				for (ext in exts)
					ext
		];
	}

	/**
	 * Contains the mod path information.
	 */
	public var scriptPath(default, null):ModPath;

	/**
	 * This variable holds the file name of the script.
	 */
	public var fileName(get, never):String;
	inline function get_fileName():String
		return FilePath.withoutDirectory(scriptPath.path);
	/**
	 * This variable holds the name of the file extension.
	 */
	public var extension(get, never):String;
	inline function get_extension():String
		return scriptPath.extension;

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
					scripts.push(new HaxeScript('root:$path'));
				if (LuaScript.exts.contains(extension))
					scripts.push(new LuaScript('root:$path'));
			} else scripts.push(new InvalidScript('root:$path'));
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
			case 'Script':        TypeUnregistered;
			case 'HaxeScript':    TypeHaxe;
			case 'LuaScript':     TypeLua;
			case 'InvalidScript': TypeInvalid;
			default:              TypeUnregistered;
		}
	}

	function new(file:ModPath, ?code:String):Void {
		if (code == null)
			scriptPath = file;
		loadScriptCode(scriptPath, code);
		loadNecessities();
		if (code == null) {
			scripts.push(this);
			GlobalScript.call('scriptCreated', [this, type]);
		}
	}

	var scriptCode(null, null):String = '';
	function loadScriptCode(file:ModPath, ?code:String):Void {
		try {
			scriptCode = code == null ? Assets.text(file) : code;
		} catch(error:haxe.Exception) {
			log('Error while trying to get script contents: ${error.message}', ErrorMessage);
			scriptCode = '';
		}
	}

	function loadNecessities():Void {}

	function launchScript(code:String):Void {}

	// /**
	//  * Loads code from string.
	//  * @param code The script code.
	//  * @param vars Variables to input into the script instance.
	//  * @param funcToRun Function to run inside the script instance.
	//  * @param funcArgs Arguments to run for said function.
	//  * @return `Script` ~ The script instance from string.
	//  */
	// public static function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?funcArgs:Array<Dynamic>):Script
	// 	return this;

	/**
	 * If true, the script is active and can mess around with the game.
	 */
	public var active(get, default):Bool = true;
	inline function get_active():Bool
		return active && canRun;
	/**
	 * States if the script has loaded.
	 */
	public var loaded(default, null):Bool = false;
	/**
	 * Loads the script, pretty self-explanatory.
	 */
	inline public function load():Void
		if (!loaded && canRun)
			launchScript(scriptCode);

	/**
	 * The parent object that the script is tied to.
	 */
	public var parent(get, set):Dynamic;
	function get_parent():Dynamic
		return null;
	function set_parent(value:Dynamic):Dynamic
		return null;

	/**
	 * Sets a variable to the script.
	 * @param variable The variable to apply.
	 * @param value The value the variable will hold.
	 */
	public function set(variable:String, value:Dynamic):Void {}
	/**
	 * Gets a variable from the script.
	 * @param variable The variable to receive.
	 * @param def If it's null then return this.
	 * @return `T` ~ The value the variable will hold.
	 */
	public function get<T>(variable:String, ?def:T):T
		return def;
	/**
	 * Calls a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @param def If your using this to return something, then this would be if it returns null.
	 * @return `T` ~ Whatever is in the functions return statement.
	 */
	public function call<T>(func:String, ?args:Array<Dynamic>, ?def:T):T
		return def;
	/**
	 * Calls a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	public function event<SC:ScriptEvent>(func:String, event:SC):SC
		return event;

	/**
	 * Ends the script, basically **destroy**, but with an extra step.
	 * @param funcName The function name to call that tells the script that it's time is over.
	 */
	inline public function end(funcName:String = 'end'):Void {
		call(funcName);
		destroy();
	}

	/**
	 * Destroys the script instance when called.
	 */
	public function destroy():Void {
		GlobalScript.call('scriptDestroyed', [this, type]);
		if (scripts.contains(this))
			scripts.remove(this);
	}
}
