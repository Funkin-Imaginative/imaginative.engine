package imaginative.backend.scripting.types;

#if CAN_HAXE_SCRIPT
import rulescript.RuleScript;
import rulescript.interps.RuleScriptInterp;
import rulescript.parsers.HxParser;
import rulescript.types.ScriptedTypeUtil;
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
		var rootImport = Script.defaultImports.copy();
		var jic:Map<String, Dynamic> = [
			'Float' => Float,
			'Int' => Int,
			'Bool' => Bool,
			'String' => String,
			'Array' => Array
		];
		for (key => value in jic)
			rootImport.set(key, value);
		// we don't need to worry about excluding with this one
		for (classInst in CompileTime.getAllClasses('rulescript.__abstracts'))
			rootImport.set(Std.string(classInst).split('.').last().substring(1), classInst);

		ScriptedTypeUtil.resolveModule = (name:String) -> {
			_log('[HaxeScript] Resolving script for module: $name');
			var script:HaxeScript = cast Script.create('lead:content/modules/${name.replace('.', '/')}', TypeHaxe);
			if (script.type.dummy) {
				_log('[HaxeScript] Failed to resolve module: $name');
				script.destroy();
				return null;
			}
			if (!script.filePath.isFile) script.destroy();
			return script.filePath.isFile ? script._parser.parseModule(Assets.text(script.filePath)) : null;
		}
		RuleScript.defaultImports.set('', rootImport);
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
	var _interp(get, never):RuleScriptInterp;
	inline function get__interp():RuleScriptInterp
		return internalScript.getInterp(RuleScriptInterp);

	override function get_parent():Dynamic
		return destroyed ? null : internalScript.superInstance;
	override function set_parent(value:Dynamic):Dynamic {
		if (destroyed) return null;
		return internalScript.superInstance = value;
	}
	override function setGlobalVariables(variables:Map<String, Dynamic>):Void
		if (!destroyed) internalScript.context.publicVariables = variables;

	@:allow(imaginative.backend.scripting.Script._create)
	override function new(file:ModPath, ?code:String) {
		internalScript = new RuleScript(new rulescript.Context());
		var finalPath:String = file.format();
		if (file.isFile && finalPath.contains('content/modules/')) {
			if (!Paths.fileExists(Paths.script('lead:content/modules/${internalScript.scriptPackage.replace('.', '/')}', TypeHaxe))) {
				internalScript.scriptPackage = finalPath.split('/content/modules/')[1].split('/').join('/').split('.')[0].replace('/', '.');
				_parser.mode = MODULE;
			}
		}
		super(file, code);
		internalScript.scriptName = code == null ? (filePath.isFile ? filePath.format() : 'no code') : 'from string';
	}

	override function renderScript(file:ModPath, ?code:String):Void {
		super.renderScript(file, code);
		_parser.allowAll();
	}

	@:access(imaginative.backend.Console.formatLogInfo)
	override function loadNecessities():Void {
		super.loadNecessities();
		var usingArray:Array<Class<Dynamic>> = [Lambda, StringTools, FunkinUtil, ReflectUtil, SpriteUtil];
		for (i in usingArray) // TODO: Add more.
			_interp.usings.set(Std.string(i).split('.').last(), i);

		startVariables.set('trace', Reflect.makeVarArgs((value:Array<Dynamic>) -> log(value, FromHaxe, _interp.posInfos())));
		startVariables.set('log', (value:Dynamic, level:LogLevel = LogMessage) -> log(value, level, FromHaxe, _interp.posInfos()));
		internalScript.context.staticVariables = Script.constantVariables;

		#if (neko || eval || display)
		for (tag => value in haxe.macro.Context.getDefines())
			if (!_parser.preprocesorValues.exists(tag))
				_parser.preprocesorValues.set(tag, value);
		#end
		internalScript.errorHandler = (error:haxe.Exception) -> {
			var errorMessage = error.message.split(':'); errorMessage.shift();
			var line = errorMessage.shift();
			var errorLine:Int = /* Std.parseInt(line) */ _parser.parser.line;
			Sys.println(Console.formatLogInfo(errorMessage.join(':').substring(1), ErrorMessage, internalScript.scriptName, errorLine, FromHaxe));
		}
		canRun = true;
	}

	override function launchCode(code:String):Void {
		if (destroyed) return;
		try {
			if (!code.isNullOrEmpty()) {
				internalScript.tryExecute(code, (error:haxe.Exception) -> {
					internalScript.errorHandler(error);
					return error;
				});
				active = loaded = true;
				if (_parser.mode != MODULE)
					call('new');
				return;
			} else _log('Script "${internalScript.scriptName}" is either null or empty.');
		} catch(error:haxe.Exception)
			internalScript.errorHandler(error);
		active = loaded = false;
	}

	override public function set(name:String, value:Dynamic):Void
		if (!destroyed && exists) internalScript.access.setVariable(name, value);
	override public function get<V>(name:String, ?def:V):V {
		if (!destroyed && exists && internalScript.access.variableExists(name))
			return internalScript.access.getVariable(name) ?? def;
		return def;
	}

	override public function call<R>(func:String, ?args:Array<Dynamic>, ?def:R):R {
		if (!active || destroyed || !exists)
			return def;
		try {
			return internalScript.access.callFunction(func, args ?? []) ?? def;
		} catch(error:haxe.Exception)
			log('Error while trying to call function "$func". (error:$error)', ErrorMessage);
		return def;
	}

	override public function destroy():Void {
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