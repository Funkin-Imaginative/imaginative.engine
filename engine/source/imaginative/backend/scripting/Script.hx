package imaginative.backend.scripting;

import imaginative.backend.scripting.types.*;

/**
 * Helps clarify a script language instance.
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
 * Class started by @Zyflx, expanded on by @rodney528.
 * @author @Zyflx & @rodney528
 */
class Script extends FlxBasic implements IScript {
	/**
	 * The default imports classes will use.
	 */
	public static final defaultImports:Map<String, Dynamic> = new Map<String, Dynamic>();
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
		var classList:List<Class<Dynamic>> = CompileTime.getAllClasses();
		function getClasses(?rootPath:String, ?excludes:Array<String>):List<Class<Dynamic>> {
			return classList.filter(classInst -> {
				var className:String = Std.string(classInst);
				if (className.endsWith('_Impl_') || !className.startsWith(rootPath ?? className))
					return false;
				for (exclude in excludes ?? [])
					if (className.startsWith(exclude.endsWith('*') ? exclude.substring(0, exclude.length - 1) : exclude))
						return false;
				return true;
			});
		}
		inline function importClass(cls:Class<Dynamic>, ?alias:String):Void
			defaultImports.set(alias ?? Std.string(cls).split('.').last(), cls);
		// TODO: Implement blacklisting.
		var flixelExclude = [
			'flixel.animation.*',
			'flixel.effects.*',
			'flixel.graphics.*',
			'flixel.input.*',
			'flixel.path.*',
			'flixel.system.*',
			'flixel.tile.*',
			'flixel.addons.api.*',
			'flixel.addons.editors.*',
			'flixel.addons.plugin.*',
			'flixel.addons.system.*',
			'flixel.addons.tile.*'
		];
		var imagExclude = [
			'imaginative.backend.converters.*',
			'imaginative.backend.display.*',
			'imaginative.backend.system.ALSoftSetup',
			'imaginative.backend.system.CrashHandler',
			'imaginative.backend.system.EngineInfoText',
			'imaginative.backend.system.Native',
			'imaginative.backend.system.Preloader',
			'imaginative.objects.arrows.group.*',
			'imaginative.objects.arrows.ArrowModifier',
			// 'imaginative.objects.holders.*',
			'imaginative.states.EngineProcess'
		];
		for (list in [getClasses('imaginative', imagExclude), getClasses('flixel', flixelExclude)])
			for (classInst in list)
				importClass(classInst);
		// still gonna import using classes for other types
		var classArray:Array<Class<Dynamic>> = [Date, DateTools, Lambda, Math, Std, StringTools, Type];
		for (i in classArray)
			importClass(i);
		HaxeScript.init();
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

	// was being weird when loadNecessities would run in extended classes
	var startVariables:Map<String, Dynamic> = new Map<String, Dynamic>();
	function new(file:ModPath, ?code:String):Void {
		if (code == null)
			filePath = file;
		super();
		renderScript(filePath);
		loadNecessities();
		for (map in [defaultImports, startVariables])
			for (key => value in map)
				set(key, value);
		GlobalScript.call('scriptCreated', [this, type]);
	}

	var scriptCode:String = '';
	function renderScript(file:ModPath, ?code:String):Void {
		#if SCRIPT_SUPPORT
		try {
			var content:String = file.isFile ? Assets.text(file) : '';
			scriptCode = content.isNullOrEmpty() ? code : content;
		} catch(error:haxe.Exception) {
			log('Error while trying to get script contents: ${error.message}', ErrorMessage);
			scriptCode = '';
		}
		#end
	}
	@:access(imaginative.backend.Console.formatValueInfo)
	function loadNecessities():Void {
		// Custom Functions //
		startVariables.set('addInfrontOf', (obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>) ->
			return SpriteUtil.addInfrontOf(obj, from, into)
		);
		startVariables.set('addBehind', (obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>) ->
			return SpriteUtil.addBehind(obj, from, into)
		);
		startVariables.set('trace', Reflect.makeVarArgs((value:Array<Dynamic>) -> log(Console.formatValueInfo(value, false), FromUnknown)));
		startVariables.set('log', (value:Dynamic, level:LogLevel = LogMessage) -> log(value, level, FromUnknown));
		startVariables.set('disableScript', () -> active = false);
		startVariables.set('__this__', this);
	}

	var canRun:Bool = false;
	function launchCode(code:String):Void {}

	/**
	 * States if the script has loaded.
	 */
	public var loaded(default, null):Bool = false;
	/**
	 * Loads the script, pretty self-explanatory.
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