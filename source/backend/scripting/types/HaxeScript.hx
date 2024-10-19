package backend.scripting.types;

#if CAN_HAXE_SCRIPT
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
#end

final class HaxeScript extends Script {
	/**
	 * All possible haxe script extension types.
	 */
	public static final exts:Array<String> = ['haxe', 'hx', 'hscript', 'hsc', 'hxs', 'hxc', 'hxp'];

	#if CAN_HAXE_SCRIPT
	var interp:Interp;
	var parser:Parser;
	var expr:Expr;

	public static function getScriptImports(script:HaxeScript):Map<String, Dynamic>
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
			'FlxSpriteGroup' => flixel.group.FlxSpriteGroup,
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
			'FlxTypedSignal' => Type.resolveClass('flixel.util.FlxSignal.FlxTypedSignal_HSC'),
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
			'Paths' => Paths,
			'ModConfig' => ModConfig,
			'PlayConfig' => PlayConfig,
			'BeatState' => BeatState,
			'BeatSubState' => BeatSubState,
			'Conductor' => Conductor,
			'BeatGroup' => BeatGroup,
			'BeatSpriteGroup' => BeatSpriteGroup,
			'ModState' => backend.scripting.states.ModState,
			'ModSubState' => backend.scripting.states.ModSubState,
			'GlobalScript' => GlobalScript,
			'Script' => Script,
			'ScriptGroup' => ScriptGroup,
			'TypeXY' => TypeXY,
			'PositionStruct' => PositionStruct,
			'FlxWindow' => FlxWindow,
			'mainWindow' => FlxWindow.direct,
			'Main' => Main,
			'AnimContext' => Type.resolveClass('objects.BaseSprite.AnimContext_HSC'),
			'BaseSprite' => BaseSprite,
			'BeatSprite' => BeatSprite,
			'Character' => Character,
			'DifficultyHolder' => DifficultyHolder,
			'LevelHolder' => LevelHolder,
			'HealthIcon' => HealthIcon,
			'PlayState' => PlayState,
			'FunkinUtil' => FunkinUtil,
			'ParseUtil' => ParseUtil,
			'PlatformUtil' => PlatformUtil,
			'FlxColorUtil' => FlxColorUtil,
			'SpriteUtil' => SpriteUtil,

			// Custom Functions //
			'addInfrontOf' => (obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup) -> {
				SpriteUtil.addInfrontOf(obj, fromThis, into);
			},
			'addBehind' => (obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup) -> {
				SpriteUtil.addBehind(obj, fromThis, into);
			},
			'disableScript' => () -> {
				script.active = false;
			},
			'trace' => (value:Dynamic) -> {
				trace('${script.rootPath}: $value');
			},

			// self //
			'__this__' => script
		];

	@:allow(backend.scripting.Script.create)
	override function new(path:String, ?code:String)
		super(path, code);

	override function renderNecessities():Void {
		interp.allowStaticVariables = interp.allowPublicVariables = true;
		for (name => thing in getScriptImports(this))
			set(name, thing);
	}

	override function renderScript(path:String, ?code:String):Void {
		interp = new Interp();
		parser = new Parser();

		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;

		try {
			this.code = Paths.getFileContent(path).getDefault(code);
		} catch(error:haxe.Exception) {
			trace('Error while trying to get script contents: ${error.message}');
			this.code = '';
		}
	}
	override function loadCodeString(code:String):Void {
		try {
			if (code != null && code.trim() != '') {
				expr = parser.parseString(code);
				canRun = true;
			}
		} catch(error:haxe.Exception) {
			trace('Error while parsing script: ${error.message}');
			canRun = false;
		}
	}

	override public function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?fungArgs:Array<Dynamic>):Void {
		var script:HaxeScript = new HaxeScript('', code);
		for (name => thing in vars)
			script.set(name, thing);
		script.call(funcToRun, fungArgs.getDefault([]));
	}

	override public function load() {
		super.load();
		if (!loaded && canRun) {
			try {
				@:privateAccess interp.execute(parser.mk(EBlock([]), 0, 0));
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
		var savedVariables:Map<String, Dynamic> = [];
		for (name => thing in interp.variables)
			if (!Reflect.isFunction(thing))
				savedVariables[name] = thing;
		final oldParent:Dynamic = interp.scriptObject;
		renderScript(path);

		for (name => thing in getScriptImports(this))
			set(name, thing);

		load();
		parent = oldParent;

		for (name => thing in savedVariables)
			set(name, thing);

		interp.allowStaticVariables = interp.allowPublicVariables = true;
	}

	override function get_parent():Dynamic
		return interp.scriptObject.getDefault(this);
	override function set_parent(value:Dynamic):Dynamic
		return interp.scriptObject = value;

	override public function setPublicVars(map:Map<String, Dynamic>):Void
		interp.publicVariables = map;

	override public function set(variable:String, value:Dynamic):Void
		interp.variables.set(variable, value);
	override public function get(variable:String, ?def:Dynamic):Dynamic {
		var whatsGotten:Dynamic = interp.variables.get(variable);
		return whatsGotten == null ? def : whatsGotten;
	}
	override public function call(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null || !interp.variables.exists(funcName))
			return null;

		final func = get(funcName);
		if (func != null && Reflect.isFunction(func))
			try {
				return Reflect.callMethod(null, func, args.getDefault([]));
			} catch(error:haxe.Exception)
				trace('Error while trying to call function $funcName: ${error.message}');

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
	override function new(path:String, ?_:String) {
		trace('Haxe scripting isn\'t supported in this build.');
		super(path, null);
	}
	#end
}