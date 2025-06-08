package imaginative.backend.scripting.types;

#if CAN_HAXE_SCRIPT
import hscript.Expr;
import rulescript.RuleScript;
import rulescript.RuleScriptInterp;
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
	var rulescript(default, null):RuleScript = new RuleScript();
	var expr(default, null):Expr;
	var interp(get, never):RuleScriptInterp;
	inline function get_interp():RuleScriptInterp
		return rulescript.interp;
	var parser(get, never):HxParser;
	inline function get_parser():HxParser
		return rulescript.getParser(HxParser);

	static function getScriptImports(script:HaxeScript):Map<String, Dynamic> {
		return [
			// Haxe // rest is done by rulescript
			'Lambda' => Lambda,
			'Json' => haxe.Json,

			// Lime + OpenFL //
			'Assets' => openfl.utils.Assets,
			'Application' => lime.app.Application,

			// Flixel //
			'FlxBasic' => FlxBasic,
			'FlxCamera' => FlxCamera,
			'FlxG' => FlxG,
			'FlxObject' => FlxObject,
			'FlxSprite' => FlxSprite,
			'FlxState' => FlxState,
			'FlxSubState' => FlxSubState,
			'FlxTypeText' => FlxTypeText,
			'FlxGroup' => FlxGroup,
			'FlxSpriteGroup' => FlxSpriteGroup,
			'FlxTypedGroup' => FlxTypedGroup,
			'FlxTypedSpriteGroup' => FlxTypedSpriteGroup,
			'FlxAngle' => FlxAngle,
			'FlxMath' => FlxMath,
			'FlxPoint' => Type.resolveClass('flixel.math.FlxPoint_HSC'),
			'FlxRect' => FlxRect,
			'FlxVelocity' => FlxVelocity,
			'FlxSound' => FlxSound,
			'FlxSoundGroup' => FlxSoundGroup,
			'FlxText' => FlxText,
			'FlxEase' => FlxEase,
			'FlxTween' => FlxTween,
			'FlxAxes' => Type.resolveClass('flixel.util.FlxAxes_HSC'),
			'FlxColor' => Type.resolveClass('flixel.util.FlxColor_HSC'),
			'FlxGradient' => FlxGradient,
			'FlxSave' => FlxSave,
			'FlxTypedSignal' => Type.resolveClass('flixel.util.FlxTypedSignal_HSC'),
			'FlxSkewedSprite' => flixel.addons.effects.FlxSkewedSprite,
			'FlxBackdrop' => flixel.addons.display.FlxBackdrop,
			'FlxSort' => FlxSort,
			'FlxTimer' => FlxTimer,
			'OneOfFour' => Type.resolveClass('flixel.util.typeLimit.OneOfFour_HSC'),
			'OneOfThree' => Type.resolveClass('flixel.util.typeLimit.OneOfThree_HSC'),
			'OneOfTwo' => Type.resolveClass('flixel.util.typeLimit.OneOfTwo_HSC'),
			'FlxArrayUtil' => FlxArrayUtil,
			'FlxColorTransformUtil' => FlxColorTransformUtil,
			'FlxDestroyUtil' => FlxDestroyUtil,
			'FlxSpriteUtil' => FlxSpriteUtil,
			'FlxStringUtil' => FlxStringUtil,

			// Engine //
			'Controls' => Controls,
			'Conductor' => Conductor,
			'BeatGroup' => BeatGroup,
			'BeatSpriteGroup' => BeatSpriteGroup,
			'BeatTypedGroup' => BeatTypedGroup,
			'BeatTypedSpriteGroup' => BeatTypedSpriteGroup,
			'BeatState' => BeatState,
			'BeatSubState' => BeatSubState,
			'TypeXY' => TypeXY,
			'Position' => Position,
			'Script' => Script,
			'ScriptGroup' => ScriptGroup,
			'ScriptedState' => imaginative.backend.scripting.states.ScriptedState,
			'ScriptedSubState' => imaginative.backend.scripting.states.ScriptedSubState,
			'GlobalScript' => GlobalScript,
			'HaxeScript' => HaxeScript,
			'InvalidScript' => InvalidScript,
			'LuaScript' => LuaScript,
			'Main' => Main,
			#if MOD_SUPPORT
			'Modding' => Modding,
			#end
			'ModType' => Type.resolveClass('imaginative.backend.system._Paths.ModType_Impl_'),
			'ModPath' => Type.resolveClass('imaginative.backend.system._Paths.ModPath_Impl_'),
			'Paths' => Paths,
			'Settings' => Settings,
			'DifficultyHolder' => DifficultyHolder,
			'LevelHolder' => LevelHolder,
			'FlxWindow' => FlxWindow,
			'mainWindow' => FlxWindow.direct,
			'ArrowField' => ArrowField,
			'Note' => Note,
			'Strum' => Strum,
			'SpriteText' => SpriteText,
			'SpriteTextLine' => SpriteTextLine,
			'SpriteTextCharacter' => SpriteTextCharacter,
			'HealthIcon' => HealthIcon,
			'WindowBounds' => WindowBounds,
			'AnimationContext' => Type.resolveClass('imaginative.objects.BaseSprite.AnimationContext_HSC'),
			'BaseSprite' => BaseSprite,
			'BeatSprite' => BeatSprite,
			'Character' => Character,
			'PlayState' => PlayState,
			'FunkinUtil' => FunkinUtil,
			'ParseUtil' => ParseUtil,
			'PlatformUtil' => PlatformUtil,
			'SpriteUtil' => SpriteUtil,

			// Extra //
			#if KNOWS_VERSION_ID
			'Version' => Type.resolveClass('thx.semver._Version.Version_Impl_'),
			#end

			// Custom Functions //
			'addInfrontOf' => (obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>) ->
				return SpriteUtil.addInfrontOf(obj, from, into),
			'addBehind' => (obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>) ->
				return SpriteUtil.addBehind(obj, from, into),

			'trace' => (value:Dynamic) ->
				log(value, FromHaxe, script.interp.posInfos()),
			'log' => (value:Dynamic, level:LogLevel = LogMessage) ->
				log(value, level, FromHaxe, script.interp.posInfos()),

			'disableScript' => () ->
				script.active = false,

			// self //
			'__this__' => script
		];
	}

	@:allow(imaginative.backend.scripting.Script.create)
	override function new(file:ModPath, ?code:String)
		super(file, code);

	@:access(imaginative.backend.Console.formatLogInfo)
	override function loadNecessities():Void {
		rulescript.scriptName = scriptPath == null ? 'from string' : scriptPath.format();
		for (name => thing in getScriptImports(this))
			set(name, thing);
		#if (neko || eval || display)
		for (tag => value in haxe.macro.Context.getDefines())
			if (!rulescript.preprocesorValues.exists(tag))
				rulescript.preprocesorValues.set(tag, value);
		#end
		rulescript.errorHandler = (error:haxe.Exception) -> {
			_log(Console.formatLogInfo(error.message, ErrorMessage, rulescript.scriptName, parser.parser.line), ErrorMessage);
			return error;
		}
	}

	override function renderScript(file:ModPath, ?code:String):Void {
		parser.allowAll();

		super.renderScript(file, code);
	}
	override function loadCodeString(code:String):Void {
		try {
			if (!code.isNullOrEmpty()) {
				expr = parser.parse(code);
				canRun = true;
				return;
			}
		} catch(error:haxe.Exception)
			rulescript.errorHandler(error);
		canRun = false;
	}

	/**
	 * Load's code from string.
	 * @param code The script code.
	 * @param vars Variables to input into the haxe script instance.
	 * @param funcToRun Function to run inside the haxe script instance.
	 * @param funcArgs Arguments to run for said function.
	 * @return `HaxeScript` ~ The haxe script instance from string.
	 */
	public static function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?funcArgs:Array<Dynamic>):HaxeScript {
		var script:HaxeScript = new HaxeScript('', code);
		for (name => thing in vars)
			script.set(name, thing);
		script.load();
		script.call(funcToRun, funcArgs ?? []);
		return script;
	}

	override public function load() {
		super.load();
		if (!loaded && canRun) {
			try {
				if (expr != null) {
					rulescript.tryExecute(expr, rulescript.errorHandler);
					loaded = true;
					call('new');
				}
			} catch(error:haxe.Exception)
				log('Error while trying to execute script: ${error.message}', ErrorMessage);
		}
	}
	override public function reload():Void {
		// save variables
		var savedVariables:Map<String, Dynamic> = new Map<String, Dynamic>();
		for (name => thing in rulescript.variables)
			if (!Reflect.isFunction(thing))
				savedVariables[name] = thing;
		var oldParent:Dynamic = rulescript.superInstance;
		renderScript(scriptPath);

		for (name => thing in getScriptImports(this))
			set(name, thing);

		load();
		parent = oldParent;

		for (name => thing in savedVariables)
			set(name, thing);
	}

	override function get_parent():Dynamic
		return rulescript.superInstance;
	override function set_parent(value:Dynamic):Dynamic
		return rulescript.superInstance = value;

	// override public function setPublicMap(map:Map<String, Dynamic>):Void
	// 	interp.publicVariables = map;

	override public function set(variable:String, value:Dynamic):Void
		rulescript.variables.set(variable, value);
	override public function get(variable:String, ?def:Dynamic):Dynamic
		return rulescript.variables.get(variable) ?? def;

	override public function call(func:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null || !rulescript.variables.exists(func))
			return null;

		var func = get(func);
		if (func != null && Reflect.isFunction(func))
			try {
				return Reflect.callMethod(null, func, args ?? []);
			} catch(error:haxe.Exception)
				log('Error while trying to call function $func: ${error.message}', ErrorMessage);

		return null;
	}
	override public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		event.returnCall = call(func, [event]);
		return event;
	}

	override public function destroy():Void {
		rulescript = null;
		super.destroy();
	}
	#else
	@:allow(imaginative.backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		log('Haxe scripting isn\'t supported in this build.', SystemMessage);
		super(file, null);
	}
	#end
}