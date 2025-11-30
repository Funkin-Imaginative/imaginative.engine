package imaginative.backend.scripting.types;

#if CAN_HAXE_SCRIPT
import rulescript.RuleScript;
import rulescript.parsers.HxParser;
#end

/**
 * This class handles script instances under the haxe language.
 */
final class HaxeScript extends Script {
	/**
	 * All possible haxe extension types.
	 */
	public static final exts:Array<String> = ['haxe', 'hx', 'hscript', 'hsc', 'hxs', 'hxc'];

	#if CAN_HAXE_SCRIPT
	@:allow(imaginative.backend.scripting.Script)
	inline static function init():Void {
		var rootImport = RuleScript.defaultImports.get('');
		rootImport.remove('Sys');
		var jic:Map<String, Dynamic> = [
			'Float' => Float,
			'Int' => Int,
			'Bool' => Bool,
			'String' => String,
			'Array' => Array
		];
		for (key => value in jic)
			rootImport.set(key, value);
		for (classInst in CompileTime.getAllClasses('rulescript.__abstracts'))
			rootImport.set(Std.string(classInst).split('.').last().substring(1), classInst);
	}

	/**
	 * Loads code from string.
	 * @param code The script code.
	 * @param onCreate Runs when the script is created.
	 * @param onLoad Runs when the script is loaded.
	 * @return HaxeScript ~ The haxe script instance.
	 */
	public static function loadCodeFromString(code:String, onCreate:HaxeScript->Void, onLoad:HaxeScript->Void):HaxeScript {
		var script:HaxeScript = new HaxeScript('', code);
		if (onCreate != null) onCreate(script);
		script.load();
		if (onLoad != null) onLoad(script);
		return script;
	}

	var internalScript(default, null):RuleScript;
	var _parser(get, never):HxParser;
	inline function get__parser():HxParser
		return internalScript.getParser(HxParser);

	override function get_parent():Dynamic
		return internalScript.superInstance;
	override function set_parent(value:Dynamic):Dynamic
		return internalScript.superInstance = value;

	@:allow(imaginative.backend.scripting.Script._create)
	override function new(file:ModPath, ?code:String) {
		internalScript = new RuleScript();
		super(file, code);
		internalScript.scriptName = filePath == null ? 'from string' : filePath.format();
		// trace(startVariables);
	}

	override function renderScript(file:ModPath, ?code:String):Void {
		super.renderScript(file, code);
		_parser.allowAll();
	}

	@:access(imaginative.backend.Console.formatValueInfo)
	@:access(imaginative.backend.Console.formatLogInfo)
	override function loadNecessities():Void {
		super.loadNecessities();
		var usingArray:Array<Class<Dynamic>> = [Lambda, StringTools];
		for (i in usingArray) // TODO: Add more.
			internalScript.interp.usings.set(Std.string(i).split('.').last(), i);

		startVariables.set('trace', Reflect.makeVarArgs((value:Array<Dynamic>) -> log(Console.formatValueInfo(value, false), FromHaxe, internalScript.interp.posInfos())));
		startVariables.set('log', (value:Dynamic, level:LogLevel = LogMessage) -> log(value, level, FromHaxe, internalScript.interp.posInfos()));

		#if (neko || eval || display)
		for (tag => value in haxe.macro.Context.getDefines())
			if (!_parser.preprocesorValues.exists(tag))
				_parser.preprocesorValues.set(tag, value);
		#end
		internalScript.errorHandler = (error:haxe.Exception) -> {
			var errorMessage = error.message.split(':'); errorMessage.shift();
			var errorLine:Int = Std.parseInt(errorMessage.shift());
			_log(Console.formatLogInfo(errorMessage.join(':').substring(1), ErrorMessage, internalScript.scriptName, errorLine, FromHaxe), ErrorMessage);
			return error;
		}
		canRun = true;
	}

	override function launchCode(code:String):Void {
		try {
			if (!code.isNullOrEmpty()) {
				internalScript.tryExecute(code, internalScript.errorHandler);
				loaded = true;
				call('new');
				return;
			} else _log('Script "${internalScript.scriptName}" is either null or empty.');
		} catch(error:haxe.Exception)
			internalScript.errorHandler(error);
		loaded = false;
	}

	override public function set(name:String, value:Dynamic):Void
		internalScript.variables.set(name, value);
	override public function get<V>(name:String, ?def:V):V {
		if (internalScript.variables.exists(name))
			return internalScript.variables.get(name) ?? def;
		return def;
	}

	override public function call<R>(func:String, ?args:Array<Dynamic>, ?def:R):R {
		if (!active) return def;
		if (!internalScript.variables.exists(func)) return def;

		var daFunc:haxe.Constraints.Function = get(func);
		if (Reflect.isFunction(daFunc))
			try {
				return Reflect.callMethod(null, daFunc, args ?? []) ?? def;
			} catch(error:haxe.Exception)
				log('Error while trying to call function "$func". (error:$error)', ErrorMessage);

		return def;
	}

	override public function destroy():Void {
		internalScript.interp = null;
		internalScript.parser = null;
		internalScript = null;
		super.destroy();
	}
	#else
	@:allow(imaginative.backend.scripting.Script._create)
	override function new(file:ModPath, ?_:String) {
		if (file.isFile)
			_log('[Script] Haxe scripting isn\'t supported in this build. (file:${file.format()})');
		super(file, null);
	}
	#end
}