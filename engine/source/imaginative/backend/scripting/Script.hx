package imaginative.backend.scripting;

import imaginative.backend.scripting.types.*;

/**
 * Help's clarify a script language instance.
 */
enum abstract ScriptType(String) from String to String {
	/**
	 * States that this script runs on an unregistered coding language.
	 */
	var TypeUnregistered = 'Unregistered';
	/**
	 * States that this script runs on the haxe coding language.
	 */
	var TypeHaxe = 'Haxe';
	/**
	 * States that this script runs on the lua coding language.
	 */
	var TypeLua = 'Lua';
	/**
	 * States that this script runs on an invalid coding language.
	 */
	var TypeInvalid = 'Invalid';

	/**
	 * If true this script can't actually be used for anything.
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
	/**
	 * All possible script extension types.
	 */
	public static var exts(default, null):Array<String> = ['hx', 'lua'];

	@:allow(imaginative.backend.system.Main.new)
	inline static function init():Void {
		exts = [
			for (exts in [HaxeScript.exts, LuaScript.exts])
				for (ext in exts)
					ext
		];
	}

	// Util Functions.
	/**
	 * Loads code from string.
	 * @param code The script code.
	 * @param language The script language to use.
	 * @param onCreate Runs when the script is created.
	 * @param onLoad Runs when the script is loaded.
	 * @return Script ~ The script instance.
	 */
	public static function loadCodeFromString(code:String, language:ScriptType, onCreate:Script->Void, onLoad:Script->Void):Script {
		switch (language) {
			#if CAN_HAXE_SCRIPT
			case TypeHaxe:
				return HaxeScript.loadCodeFromString(code, onCreate, onLoad);
			#end
			#if CAN_LUA_SCRIPT
			case TypeLua:
				return LuaScript.loadCodeFromString(code, onCreate, onLoad);
			#end
			default:
				return new InvalidScript('');
		}
	}

	/**
	 * Creates a script instance.
	 * @param file The mod path.
	 * @return Script ~ The script you wished to create.
	 */
	public static function create(file:ModPath):Script
		return _create(Paths.script(file).format());
	/**
	 * Creates script instances.
	 * @param file The mod path.
	 * @param preventModDuplicates If true prevent's duplicates between mods.
	 * @return Array<Script> ~ The scripts you wished to create.
	 */
	public static function createMulti(file:ModPath, preventModDuplicates:Bool = true):Array<Script> {
		#if SCRIPT_SUPPORT
		var paths:Array<String> = [
			#if MOD_SUPPORT
			for (ext in exts)
				for (instance in Modding.getAllInstancesOfFile('${file.path}.$ext', file.type, preventModDuplicates))
					instance
			#else
			Paths.script(file).format()
			#end
		];
		var scripts:Array<Script> = [for (path in paths) _create(path)];
		scripts.filter((script:Script) -> {
			if (script == null)
				return false;
			if (script.type.dummy) {
				script.destroy();
				return false;
			}
			return true;
		});
		return scripts;
		#else
		return [];
		#end
	}
	static function _create(path:String):Script {
		#if SCRIPT_SUPPORT
		var extension:String = FilePath.extension(path).toLowerCase();
		if (exts.contains(extension)) {
			if (HaxeScript.exts.contains(extension))
				return new HaxeScript('root:$path');
			if (LuaScript.exts.contains(extension))
				return new LuaScript('root:$path');
		}
		return new InvalidScript('root:$path');
		#else
		new InvalidScript('');
		#end
	}

	// The important stuff.
	/**
	 * This is the static variables map, these variables can be accessed at all times.
	 */
	public static var constantVariables:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * States the type of script this is.
	 */
	public var type(get, never):ScriptType;
	inline function get_type():ScriptType {
		return switch (this.getClassName()) {
			case 'Script':          TypeUnregistered;
			case 'HaxeScript':      TypeHaxe;
			case 'LuaScript':       TypeLua;
			case 'InvalidScript':   TypeInvalid;
			default:                TypeUnregistered;
		}
	}

	/**
	 * Contains the mod path information.
	 */
	public final filePath:ModPath;
	/**
	 * Holds the name of the script file.
	 */
	public var name(get, never):String;
	inline function get_name():String
		return FilePath.withoutExtension(FilePath.withoutDirectory(filePath?.path)) ?? 'none';
	/**
	 * Holds the name of the file extension.
	 */
	public var extension(get, never):String;
	inline function get_extension():String
		return filePath?.extension ?? 'none';

	/**
	 * The parent object that the script is tied to.
	 */
	public var parent(get, set):Dynamic;
	function get_parent():Dynamic return null;
	function set_parent(value:Dynamic):Dynamic return null;
	/**
	 * This sets the public variables map.
	 * @param map The public variables map.
	 */
	public function setGlobalVariables(map:Map<String, Dynamic>):Void {}

	function new(file:ModPath, ?code:String):Void {
		if (code == null)
			filePath = file;
		super();
		renderScript(filePath);
		loadNecessities();
		GlobalScript.call('scriptCreated', [this, type]);
	}

	var scriptCode:String = '';
	function renderScript(file:ModPath, ?code:String):Void {
		#if SCRIPT_SUPPORT
		try {
			var content:String = file.isFile ? '' : Assets.text(file);
			scriptCode = content.isNullOrEmpty() ? code : content;
		} catch(error:haxe.Exception) {
			log('Error while trying to get script contents: ${error.message}', ErrorMessage);
			scriptCode = '';
		}
		#end
	}
	function loadNecessities():Void {
		// TODO: load pre-import stuff here
		/* var classes:Map<String, Class<Dynamic>> = [];
		for (c in classes)
			set(c.getClassName(), c); */
	}

	var canRun:Bool = false;
	function launchCode(code:String):Void {}

	/**
	 * States if the script has loaded.
	 */
	public var loaded(default, null):Bool = false;
	/**
	 * Load's the script, pretty self-explanatory.
	 */
	public function load():Void
		if (!loaded)
			launchCode(scriptCode);

	// Basic functions.
	/**
	 * Sets a variable in the script.
	 * @param name The name of the variable.
	 * @param value The value to apply.
	 */
	public function set(name:String, value:Dynamic):Void {}
	/**
	 * Gets a variable from the script.
	 * @param name The name of the variable.
	 * @param def If it doesn't exist or is null, return this.
	 * @return Dynamic ~ The value.
	 */
	public function get<V>(name:String, ?def:V):V
		return def;
	/**
	 * Calls a function in the script.
	 * @param func The name of the function.
	 * @param args Arguments of the said function.
	 * @param def If it returns null, then return this.
	 * @return Dynamic ~ Whatever the function returns.
	 */
	public function call<R>(func:String, ?args:Array<Dynamic>, ?def:R):R
		return def;

	/**
	 * Ends the script.
	 * @param funcName Custom function call name.
	 */
	inline public function end(funcName:String = 'end'):Void {
		call(funcName);
		destroy();
	}
	override public function destroy():Void {
		GlobalScript.call('scriptDestroyed', [this, type]);
		super.destroy();
	}
}
