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
	var internalScript(default, null):RuleScript;
	var _parser(get, never):HxParser;
	inline function get__parser():HxParser
		return internalScript.getParser(HxParser);

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
			'mainWindow' => FlxWindow.instance,
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
				log(value, FromHaxe, script.internalScript.interp.posInfos()),
			'log' => (value:Dynamic, level:LogLevel = LogMessage) ->
				log(value, level, FromHaxe, script.internalScript.interp.posInfos()),

			'disableScript' => () ->
				script.active = false,

			// self //
			'__this__' => script
		];
	}

	@:allow(imaginative.backend.scripting.Script.create)
	override function new(file:ModPath, ?code:String) {
		internalScript = new RuleScript();
		super(file, code);
	}

	override function loadScriptCode(file:ModPath, ?code:String):Void {
		super.loadScriptCode(file, code);
		_parser.allowAll();
	}

	@:access(imaginative.backend.Console.formatLogInfo)
	override function loadNecessities():Void {
		internalScript.scriptName = scriptPath == null ? 'from string' : scriptPath.format();
		for (name => thing in getScriptImports(this))
			set(name, thing);
		#if (neko || eval || display)
		for (tag => value in haxe.macro.Context.getDefines())
			if (!_parser.preprocesorValues.exists(tag))
				_parser.preprocesorValues.set(tag, value);
		#end
		internalScript.errorHandler = (error:haxe.Exception) -> {
			_log(Console.formatLogInfo(error.message, ErrorMessage, internalScript.scriptName, _parser.parser.line), ErrorMessage);
			return error;
		}
		canRun = true;
	}

	override function launchScript(code:String):Void {
		try {
			if (!code.isNullOrEmpty()) {
				internalScript.tryExecute(code, internalScript.errorHandler);
				loaded = true;
				return;
			} else _log('Script "${internalScript.scriptName}" is either null or empty.');
		} catch(error:haxe.Exception)
			internalScript.errorHandler(error);
		loaded = false;
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
		script.call(funcToRun, funcArgs);
		return script;
	}

	override function get_parent():Dynamic
		return internalScript.superInstance;
	override function set_parent(value:Dynamic):Dynamic
		return internalScript.superInstance = value;

	override public function set(variable:String, value:Dynamic):Void
		internalScript.variables.set(variable, value);
	override public function get<T>(variable:String, ?def:T):T
		return internalScript.variables.get(variable) ?? def;

	override public function call<T>(func:String, ?args:Array<Dynamic>, ?def:T):T {
		if (!active && internalScript.interp == null || !internalScript.variables.exists(func))
			return def;

		var func = get(func);
		if (func != null && Reflect.isFunction(func))
			try {
				return Reflect.callMethod(null, func, args ?? []) ?? def;
			} catch(error:haxe.Exception)
				log('Error while trying to call function $func: ${error.message}', ErrorMessage);

		return def;
	}
	override public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		event.returnCall = call(func, [event]);
		return event;
	}

	override public function destroy():Void {
		internalScript = null;
		super.destroy();
	}
	#else
	@:allow(imaginative.backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		_log('[Script] Haxe scripting isn\'t supported in this build.', SystemMessage);
		super(file, null);
	}
	#end
}