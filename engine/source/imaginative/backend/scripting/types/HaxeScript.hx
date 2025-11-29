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
		RuleScript.defaultImports.get('').remove('Sys');
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
	var parser(get, never):HxParser;
	inline function get_parser():HxParser
		return internalScript.getParser(HxParser);

	/* static function getScriptImports(script:HaxeScript):Map<String, Dynamic> {
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
	} */

	override function get_parent():Dynamic
		return internalScript.superInstance;
	override function set_parent(value:Dynamic):Dynamic
		return internalScript.superInstance = value;

	@:allow(imaginative.backend.scripting.Script._create)
	override function new(file:ModPath, ?code:String) {
		super(file, code);
		internalScript = new RuleScript();
	}

	override function renderScript(file:ModPath, ?code:String):Void {
		super.renderScript(file, code);
		parser.allowAll();
	}

	@:access(imaginative.backend.Console.formatValueInfo)
	@:access(imaginative.backend.Console.formatLogInfo)
	override function loadNecessities():Void {
		super.loadNecessities();
		set('trace', Reflect.makeVarArgs((value:Array<Dynamic>) -> log(Console.formatValueInfo(value, false), FromHaxe, internalScript.interp.posInfos())));
		set('log', (value:Dynamic, level:LogLevel = LogMessage) -> log(value, level, FromHaxe, internalScript.interp.posInfos()));

		/* inline function importClass(cls:Class<Dynamic>, ?alias:String):Void {
			set(alias ?? cls.getClassName(), cls);
		}
		var classArray:Array<Class<Dynamic>> = [Float, Int, Bool, String];
		for (i in classArray)
			importClass(i); */

		internalScript.scriptName = filePath == null ? 'from string' : filePath.format();
		#if (neko || eval || display)
		for (tag => value in haxe.macro.Context.getDefines())
			if (!parser.preprocesorValues.exists(tag))
				parser.preprocesorValues.set(tag, value);
		#end
		internalScript.errorHandler = (error:haxe.Exception) -> {
			_log(Console.formatLogInfo(error.message, ErrorMessage, internalScript.scriptName, parser.parser.line), ErrorMessage);
			return error;
		}
		canRun = true;
	}

	override function launchCode(code:String):Void {
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