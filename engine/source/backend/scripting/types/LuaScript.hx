package backend.scripting.types;

#if CAN_LUA_SCRIPT
import lscript.LScript;
#end

/**
 * This class handles script instances under the lua language.
 */
final class LuaScript extends Script {
	/**
	 * All possible lua extension types.
	 */
	public static final exts:Array<String> = ['lua'];

	#if CAN_LUA_SCRIPT
	public var lscript:LScript;

	@:access(backend.Console.formatLogInfo)
	static function getScriptImports(script:LuaScript):Map<String, Dynamic> {
		return [
			// Lime + OpenFL //
			'Assets' => openfl.utils.Assets,
			'Application' => lime.app.Application,
			'window' => lime.app.Application.current.window,

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
			'PlayConfig' => PlayConfig,
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
			'ScriptedState' => backend.scripting.states.ScriptedState,
			'ScriptedSubState' => backend.scripting.states.ScriptedSubState,
			'GlobalScript' => GlobalScript,
			'HaxeScript' => HaxeScript,
			'InvalidScript' => InvalidScript,
			'LuaScript' => LuaScript,
			'Main' => Main,
			#if MOD_SUPPORT
			'Modding' => Modding,
			#end
			'ModType' => Type.resolveClass('backend.system.Paths.ModType_HSC'),
			'ModPath' => Type.resolveClass('backend.system.Paths.ModPath_HSC'),
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
			'AnimationContext' => Type.resolveClass('objects.BaseSprite.AnimationContext_HSC'),
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
			'Version' => Type.resolveClass('thx.semver.Version_HSC'),
			#end

			// Custom Functions //
			'addInfrontOf' => (obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>) ->
				return SpriteUtil.addInfrontOf(obj, from, into),
			'addBehind' => (obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>) ->
				return SpriteUtil.addBehind(obj, from, into),

			'print' => (value:Dynamic) ->
				_log(Console.formatLogInfo(value, LogMessage, script.pathing.format(), FromLua)),
			'log' => (value:Dynamic, level:String = LogMessage) ->
				_log(Console.formatLogInfo(value, level, script.pathing.format(), FromLua)),

			'disableScript' => () ->
				script.active = false,

			// self //
			'__this__' => script
		];
	}

	@:allow(backend.scripting.Script.create)
	override function new(file:ModPath, ?code:String)
		super(file, code);

	override function renderScript(file:ModPath, ?code:String):Void {
		try {
			var content:String = Paths.getFileContent(file);
			this.code = content.trim() == '' ? code : content;
		} catch(error:haxe.Exception) {
			log('Error while trying to get script contents: ${error.message}', ErrorMessage);
			this.code = '';
		}
		lscript = new LScript(this.code);
	}

	@:access(backend.Console.formatLogInfo)
	override function loadCodeString(code:String):Void {
		try {
			// for (name => thing in getScriptImports(this))
			// 	set(name, thing);
			canRun = true;
			return;
		} catch(error:haxe.Exception)
			_log(Console.formatLogInfo(error.message, ErrorMessage, pathing.format()), ErrorMessage);
		canRun = false;
	}

	override public function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?funcArgs:Array<Dynamic>):LuaScript {
		var script:LuaScript = new LuaScript('', code);
		for (name => thing in vars)
			script.set(name, thing);
		script.call(funcToRun, funcArgs ?? []);
		script.load();
		return script;
	}

	override function load():Void {
		super.load();
		if (!loaded && canRun) {
			try {
				lscript.execute();
				loaded = true;
				call('new');
			} catch(error:haxe.Exception)
				log('Error while trying to execute script: ${error.message}', ErrorMessage);
		}
	}

	override function get_parent():Dynamic
		return lscript.parent;
	override function set_parent(value:Dynamic):Dynamic
		return lscript.parent = value;

	override public function set(variable:String, value:Dynamic):Void
		lscript.setVar(variable, value);
	override public function get(variable:String, ?def:Dynamic):Dynamic
		return lscript.getVar(variable) ?? def;

	override public function call(func:String, ?args:Array<Dynamic>):Dynamic
		return lscript.callFunc(func, args ?? []);
	override public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		event.returnCall = call(func, [event]);
		return event;
	}

	override public function destroy() {
		if (lscript.luaState != null) {
			llua.Lua.close(lscript.luaState);
			lscript.luaState = null;
		}
		if (lscript != null)
			lscript = null;
		super.destroy();
	}
	#else
	@:allow(backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		log('Lua scripting isn\'t supported in this build.', SystemMessage);
		super(file, null);
	}
	#end
}