package backend.scripting;

import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

// This class was mostly coded by @Zyflx and was used on smth else before he started helping lol.
class Script extends FlxBasic {
	// because parent being null returns the script itself I think it would be best to make this unreflective
	@:unreflective var interp:Interp;
	@:unreflective var parser:Parser;
	@:unreflective var expr:Expr;

	@:unreflective var scriptCode:String = '';

	@:unreflective var canExecute:Bool = false;

	public var loaded:Bool = false;

	@:unreflective var invalid:Bool = false;

	public var isInvalid(get, never):Bool;
	inline function get_isInvalid():Bool
		return invalid;

	public static final exts:Array<String> = ['hx', 'hscript', 'hsc', 'hxs', 'hxc', 'lua'];

	public static function create(file:String, pathType:FunkinPath = ANY, getAllInstances:Bool = true):Array<Script> {
		var scriptPath:String->Array<String> = (file:String) -> {
			if (getAllInstances) {
				var result:Array<String> = [];
				for (ext in exts)
					for (instance in ModConfig.getAllInstancesOfFile('$file.$ext', pathType))
						result.push(instance);
				return result;
			} else return [Paths.script(file, pathType)];
		}
		final paths:Array<String> = scriptPath(file);
		#if debug
		for (path in paths)
			if (path.trim() != '')
				trace(path);
		#end
		var scripts:Array<Script> = [];
		for (path in paths) {
			switch (FilePath.extension(path).toLowerCase()) {
				case 'hx' | 'hscript' | 'hsc' | 'hxs' | 'hxc':
					#if CAN_HX_SCRIPT
					scripts.push(new Script(path));
					#else
					trace('Hx scripting is not supported in this build.');
					#end
				case 'lua':
					#if CAN_LUA_SCRIPT
					#else
					trace('Lua scripting is not supported.'); // in this build
					#end
					// doing a cne but more trollish lmao
			}
		}
		return scripts;
	}

	public static function getScriptImports(script:Script):Map<String, Dynamic> {
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
			'GlobalScript' => GlobalScript,
			'ModState' => ModState,
			'ModSubState' => ModSubState,
			'Script' => Script,
			'ScriptGroup' => ScriptGroup,
			'TypeXY' => TypeXY,
			'PositionStruct' => PositionStruct,
			'FlxWindow' => FlxWindow,
			'mainWindow' => FlxWindow.direct,
			'Main' => Main,
			'DifficultyObject' => DifficultyObject,
			'LevelObject' => LevelObject,
			'AnimType' => Type.resolveClass('objects.sprites.BaseSprite.AnimType_HSC'),
			'BaseSprite' => BaseSprite,
			'BeatSprite' => BeatSprite,
			'Character' => Character,
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
				trace('${script.rawPath}: $value');
			},

			// self //
			'__this__' => script
		];
	}

	// I wanted to have a reload func for scripts but I couldn't figure it out without error's so this part is mostly ripped from cne
	var rawPath:String;
	public var path:String;
	public var fileName:String;
	public var extension:String;

	public function new(?path:String):Void {
		super();
		rawPath = path;
		fileName = FilePath.withoutDirectory(path);
		extension = FilePath.extension(path);
		this.path = path;
		renderScript(path);
		interp.allowStaticVariables = interp.allowPublicVariables = true;
		for (name => thing in getScriptImports(this))
			set(name, thing);
		GlobalScript.call('scriptCreated', [this, 'hscript']);
	}

	function renderScript(path:String):Void {
		interp = new Interp();
		parser = new Parser();

		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;

		if (path == null)
			invalid = true;
		else
			try {
				scriptCode = Paths.getFileContent(path);
			} catch(error:haxe.Exception) {
				trace('Error while trying to initialize script: ${error.message}');
				scriptCode = '';
			}
	}

	public function onLoad():Void {
		loadCodeFromString(scriptCode);
		if (canExecute && !loaded) {
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

	inline public function load():Void {
		if (loaded) return;
		onLoad();
	}

	inline public function set(variable:String, value:Dynamic):Void
		interp.variables.set(variable, value);

	inline public function get(variable:String, ?def:Dynamic):Dynamic {
		var whatsGotten:Dynamic = interp.variables.get(variable);
		return whatsGotten == null ? def : whatsGotten;
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null || !interp.variables.exists(funcName))
			return null;

		final func = get(funcName);
		if (func != null && Reflect.isFunction(func))
			try {
				return Reflect.callMethod(null, func, args == null ? [] : args);
			} catch(error:haxe.Exception)
				trace('Error while trying to call function $funcName: ${error.message}');

		return null;
	}

	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		event.returnCall = call(func, [event]);
		return event;
	}

	public function reload():Void {
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

	public var parent(get, set):Dynamic;
	inline function get_parent():Dynamic
		return interp.scriptObject == null ? this : interp.scriptObject; // lol
	inline function set_parent(value:Dynamic):Dynamic
		return interp.scriptObject = value;

	inline public function setPublicVars(map:Map<String, Dynamic>):Void
		interp.publicVariables = map;

	override public function destroy():Void {
		call('destroy');
		interp = null;
		parser = null;
		super.destroy();
	}

	function loadCodeFromString(code:String):Void {
		try {
			if (code != null && code.trim() != '') {
				expr = parser.parseString(code);
				canExecute = true;
			}
		} catch(error:haxe.Exception) {
			canExecute = false;
			trace('Error while parsing script: ${error.message}');
		}
	}
}
