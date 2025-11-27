package imaginative.backend.scripting.types;

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

	var interp:Interp;
	var parser:Parser;
	var expr:Expr;

	static function getScriptImports(script:HaxeScript):Map<String, Dynamic> {
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
			'ModType' => Type.resolveClass('imaginative.backend.system.Paths.ModType_HSC'),
			'ModPath' => Type.resolveClass('imaginative.backend.system.Paths.ModPath_HSC'),
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
			'Version' => Type.resolveClass('thx.semver.Version_HSC'),
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

	override function get_parent():Dynamic
		return interp.scriptObject;
	override function set_parent(value:Dynamic):Dynamic
		return interp.scriptObject = value;

	@:allow(imaginative.backend.scripting.Script._create)
	override function new(file:ModPath, ?code:String)
		super(file, code);

	override function renderScript(file:ModPath, ?code:String):Void {
		interp = new Interp();
		parser = new Parser();

		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		interp.allowStaticVariables = interp.allowPublicVariables = true;
		interp.staticVariables = Script.constantVariables;

		super.renderScript(file, code);
	}
	var __importedPaths:Array<String> = [];
	@:access(imaginative.backend.Console.formatLogInfo)
	override function loadNecessities():Void {
		super.loadNecessities();

		if (filePath != null)
			__importedPaths.push(filePath.format());

		parser.preprocesorValues = #if (neko || eval || display) haxe.macro.Context.getDefines() #else new Map<String, Dynamic>() #end;
		interp.errorHandler = (error:Error) -> {
			var content:String = error.toString();
			if (content.startsWith(error.origin))
				content = content.substr(error.origin.length);
			_log(Console.formatLogInfo(content, ErrorMessage, error.origin, error.line), ErrorMessage);
		}
		interp.importFailedCallback = (importPath:Array<String>) -> {
			var sourcePath:String = 'source/${importPath.join('/')}';
			for (ext in exts) {
				// current path probably wont work, as I haven't setup the directory properly
				var path:String = '$sourcePath.$ext';
				if (__importedPaths.contains(path))
					return true; // prevent double import
				if (Paths.fileExists(path)) {
					var content:String = Assets.text(path);
					var expr:Expr = null;
					try {
						if (!content.isNullOrEmpty()) {
							parser.line = 1;
							expr = parser.parseString(content, '${importPath.join('/')}.$ext');
						}
					} catch(error:Error)
						try {
							interp.errorHandler(error);
						} catch(error:Error)
							interp.errorHandler(new Error(ECustom(error.toString()), 0, 0, filePath?.format() ?? 'from string', 0));
					if (expr != null) {
						@:privateAccess
							interp.exprReturn(expr);
						__importedPaths.push(path);
					}
					return true;
				}
			}
			return false;
		}

		/**
		Snapshot in time.
		```haxe
		interp.importFailedCallback = (importPath:Array<String>) -> {
			var sourcePath:ModPath = 'source/${importPath.join('/')}';
			for (ext in exts) {
				// abstracts can die in a fire for thousands of years... ITS NOT THE SAME FUCKING INSTANCE YOU BITCH!!!!
				var path:ModPath = sourcePath; // .pushExt(ext)
				path.pushExt(ext);
				// any cloning methods I did, didn't wanna work 😭
			}
			return false;
		}
		```
		**/
	}

	override function launchCode(code:String):Void {
		try {
			if (!code.isNullOrEmpty()) {
				expr = parser.parseString(code, filePath?.format() ?? 'from string');
				canRun = true;
				return;
			}
		} catch(error:Error)
			try {
				interp.errorHandler(error);
			} catch(error:Error)
				interp.errorHandler(new Error(ECustom(error.toString()), 0, 0, filePath?.format() ?? 'from string', 0));
		canRun = false;
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
				log('Error while trying to execute script: ${error.message}', ErrorMessage);
		}
	}

	override public function setGlobalVariables(map:Map<String, Dynamic>):Void
		interp.publicVariables = map;

	override public function set(variable:String, value:Dynamic):Void
		interp.variables.set(variable, value);
	override public function get<V>(name:String, ?def:V):V {
		if (interp.variables.exists(func))
			return interp.variables.get(variable) ?? def;
		return def;
	}
	override public function call<R>(func:String, ?args:Array<Dynamic>, ?def:R):R {
		if (!active) return def;
		if (!interp.variables.exists(func)) return def;

		var daFunc:haxe.Constraints.Function = get(func);
		if (Reflect.isFunction(daFunc))
			try {
				return Reflect.callMethod(null, daFunc, args ?? []) ?? def;
			} catch(error:haxe.Exception)
				log('Error while trying to call function $func: ${error.message}', ErrorMessage);

		return null;
	}

	override public function destroy():Void {
		interp = null;
		parser = null;
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