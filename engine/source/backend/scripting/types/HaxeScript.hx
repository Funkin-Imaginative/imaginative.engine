package backend.scripting.types;

#if CAN_HAXE_SCRIPT
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
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
	var interp:Interp;
	var parser:Parser;
	var expr:Expr;

	static function getScriptImports(script:HaxeScript):Map<String, Dynamic>
		return [
			// Haxe //
			'Std' => Std,
			'Math' => Math,
			'Date' => Date,
			'Type' => Type,
			'Lambda' => Lambda,
			'StringTools' => StringTools,
			'Json' => haxe.Json,
			'Reflect' => Reflect,

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
			'ArrowField' => ArrowField,
			'Note' => Note,
			'Strum' => Strum,
			'SpriteText' => SpriteText,
			'SpriteTextLine' => SpriteTextLine,
			'SpriteTextCharacter' => SpriteTextCharacter,
			'HealthIcon' => HealthIcon,
			'FlxWindow' => FlxWindow,
			'mainWindow' => FlxWindow.direct,
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
			'addInfrontOf' => (obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup) -> {
				return SpriteUtil.addInfrontOf(obj, fromThis, into);
			},
			'addBehind' => (obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup) -> {
				return SpriteUtil.addBehind(obj, fromThis, into);
			},
			'disableScript' => () -> {
				script.active = false;
			},
			'trace' => (value:Dynamic) -> {
				var info:haxe.PosInfos = script.interp.posInfos();
				haxe.Log.trace(value, info);
			},

			// self //
			'__this__' => script
		];

	@:allow(backend.scripting.Script.create)
	override function new(file:ModPath, ?code:String)
		super(file, code);

	override function renderNecessities():Void {
		interp.allowStaticVariables = interp.allowPublicVariables = true;
		for (name => thing in getScriptImports(this))
			set(name, thing);
	}

	override function renderScript(file:ModPath, ?code:String):Void {
		interp = new Interp();
		parser = new Parser();

		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;

		try {
			final content:String = Paths.getFileContent(file);
			this.code = content.trim() == '' ? code : content;
		} catch(error:haxe.Exception) {
			trace('Error while trying to get script contents: ${error.message}');
			this.code = '';
		}
	}
	override function loadCodeString(code:String):Void {
		try {
			if (code != null && code.trim() != '') {
				expr = parser.parseString(code, pathing.format().getDefault('from string'));
				canRun = true;
			}
		} catch(error:haxe.Exception) {
			trace('Error while parsing script: ${error.message}');
			canRun = false;
		}
	}

	override public function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?funcArgs:Array<Dynamic>):HaxeScript {
		var script:HaxeScript = new HaxeScript('', code);
		for (name => thing in vars)
			script.set(name, thing);
		script.call(funcToRun, funcArgs.getDefault([]));
		return script;
	}

	@:access(hscript.Parser.mk)
	override public function load() {
		super.load();
		if (!loaded && canRun) {
			try {
				interp.execute(parser.mk(EBlock([]), 0, 0));
				if (expr != null) {
					interp.execute(expr);
					loaded = true;
					call('new');
				}
			} catch(error:haxe.Exception)
				trace('Error while trying to execute script: ${error.message}');
		}
	}
	override public function reload():Void {
		// save variables
		interp.allowStaticVariables = interp.allowPublicVariables = false;
		var savedVariables:Map<String, Dynamic> = new Map<String, Dynamic>();
		for (name => thing in interp.variables)
			if (!Reflect.isFunction(thing))
				savedVariables[name] = thing;
		final oldParent:Dynamic = interp.scriptObject;
		renderScript(pathing);

		for (name => thing in getScriptImports(this))
			set(name, thing);

		load();
		parent = oldParent;

		for (name => thing in savedVariables)
			set(name, thing);

		interp.allowStaticVariables = interp.allowPublicVariables = true;
	}

	override function get_parent():Dynamic
		return interp.scriptObject;
	override function set_parent(value:Dynamic):Dynamic
		return interp.scriptObject = value;

	override public function setPublicMap(map:Map<String, Dynamic>):Void
		interp.publicVariables = map;

	override public function set(variable:String, value:Dynamic):Void
		interp.variables.set(variable, value);
	override public function get(variable:String, ?def:Dynamic):Dynamic {
		var whatsGotten:Dynamic = interp.variables.get(variable);
		return whatsGotten == null ? def : whatsGotten;
	}
	override public function call(func:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null || !interp.variables.exists(func))
			return null;

		final func = get(func);
		if (func != null && Reflect.isFunction(func))
			try {
				return Reflect.callMethod(null, func, args.getDefault([]));
			} catch(error:haxe.Exception)
				trace('Error while trying to call function $func: ${error.message}');

		return null;
	}
	override public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		event.returnCall = call(func, [event]);
		return event;
	}

	override public function destroy():Void {
		super.destroy();
		interp = null;
		parser = null;
	}
	#else
	@:allow(backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		trace('Haxe scripting isn\'t supported in this build.');
		super(file, null);
	}
	#end
}