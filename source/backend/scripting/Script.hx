package backend.scripting;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import haxe.io.Path;

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
	private function get_isInvalid():Bool
		return invalid;

	public static final exts:Array<String> = ['hx', 'hscript', 'hsc', 'hxs', 'hxc', 'lua'];

	public static function create(file:String, type:String = ''):Script {
		final path:String = Paths.script(switch (type) {
			case 'state': 'content/states/$file';
			case 'icon': 'objects/icons/$file';
			// case 'song': 'songs/${PlayState.SONG.song}/$file';
			case 'char': 'objects/characters/$file';
			default: file;
		});
		#if debug trace(path); #end
		switch (Path.extension(path).toLowerCase()) {
			case 'hx' | 'hscript' | 'hsc' | 'hxs' | 'hxc':
				return new Script(path);
			case 'lua':
				#if THROW_LUA_MAKEFUN
				@:privateAccess if (!states.sub.LuaMakeFunLmao.alreadyOpened) {
					var target:Dynamic;
					if (!FlxG.state.persistentUpdate && FlxG.state.subState != null)
						target = FlxG.state.subState;
					else
						target = FlxG.state;
					target.persistentUpdate = false;
					target.persistentDraw = false;
					target.openSubState(new states.sub.LuaMakeFunLmao());
				} else
					states.sub.PauseSubState.bfStare = true;
				#else
				trace('LUA SCRIPTS AIN\'T SUPPORTED BITCH!!!');
				#end
				// doing a cne but more trollish lmao
		}
		return new Script(FallbackUtil.invaildScriptKey);
	}

	// idk what to call this
	public static function getScriptImports(script:Script):Map<String, Dynamic> {
		return [
			// Haxe //
			'Std' => Std,
			'Math' => Math,
			'Date' => Date,
			'Type' => Type,
			'StringTools' => StringTools,
			'Json' => haxe.Json,
			'Reflect' => Reflect,
			'Main' => Main,

			// Lime + OpenFL //
			'Assets' => openfl.utils.Assets,
			'Application' => lime.app.Application,
			'window' => lime.app.Application.current.window,

			// Flixel //
			'FlxG' => FlxG,
			'FlxBasic' => FlxBasic,
			'FlxObject' => FlxObject,
			'FlxSprite' => FlxSprite,
			'FlxSkewedSprite' => flixel.addons.effects.FlxSkewedSprite,
			'FlxBackdrop' => flixel.addons.display.FlxBackdrop,
			'FlxText' => FlxText,
			'FlxCamera' => FlxCamera,
			'FlxMath' => FlxMath,
			'FlxTween' => FlxTween,
			'FlxEase' => FlxEase,
			'FlxTypedGroup' => FlxTypedGroup,
			'FlxGroup' => FlxGroup,
			'FlxTypedSpriteGroup' => FlxTypedSpriteGroup,
			'FlxSpriteGroup' => flixel.group.FlxSpriteGroup,
			'FlxTimer' => FlxTimer,
			'FlxSound' => FlxSound,
			'FlxColor' => Type.resolveClass('flixel.util.FlxColor_HSC'),
			'FlxColorHelper' => FlxColorHelper,
			'FlxAxes' => Type.resolveClass('flixel.util.FlxAxes_HSC'),
			'FlxPoint' => Type.resolveClass('flixel.math.FlxPoint_HSC'),

			// Engine //
			//

			// Custom Functions //
			'addInfrontOf' => (obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup) -> {
				CoolUtil.addInfrontOf(obj, fromThis, into);
			},
			'addBehind' => (obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup) -> {
				CoolUtil.addBehind(obj, fromThis, into);
			},
			'disableScript' => () -> {
				script.active = false;
			},
			'trace' => (value:Dynamic) -> {
				trace('${script.rawPath}: $value');
			},

			// self //
			'_this' => script
		];
	}

	// I wanted to have a reload func for scripts but I couldn't figure it out without error's so this part is mostly ripped from cne
	private var rawPath:String;
	public var path:String;
	public var fileName:String;
	public var extension:String;

	public function new(path:String):Void {
		super();
		rawPath = path;
		path = getFilenameFromLibFile(path);
		fileName = Path.withoutDirectory(path);
		extension = Path.extension(path);
		this.path = path;
		scriptCreation(path);
		for (name => thing in getScriptImports(this))
			set(name, thing);
	}

	inline function getFilenameFromLibFile(path:String) {
		var file = new Path(path);
		if (file.file.startsWith('LIB_'))
			return file.dir + '.' + file.ext;
		return path;
	}

	private function scriptCreation(path:String) {
		interp = new Interp();
		parser = new Parser();

		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		interp.allowStaticVariables = interp.allowPublicVariables = true;

		if (path == FallbackUtil.invaildScriptKey)
			invalid = true;
		else
			try {
				scriptCode = Paths.getFileContent(path);
			} catch (e:haxe.Exception) {
				trace('Error while trying to initialize script: ${e.message}');
				scriptCode = '';
			}
	}

	public function onLoad(stopNewCall:Bool = false) {
		loadCodeFromString(scriptCode);
		if (canExecute && !loaded) {
			try {
				@:privateAccess interp.execute(parser.mk(EBlock([]), 0, 0));
				if (expr != null) {
					interp.execute(expr);
					loaded = true;
					if (!stopNewCall)
						call('new');
				}
			} catch (e:haxe.Exception)
				trace('Error while trying to execute script: ${e.message}');
		}
	}

	inline public function load(stopNewCall:Bool = false) {
		if (loaded) return;
		onLoad(stopNewCall);
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
			} catch (e:haxe.Exception)
				trace('Error while trying to call function $funcName: ${e.message}');

		return null;
	}

	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		call(func, [event]);
		return event;
	}

	public function reload() {
		// save variables
		interp.allowStaticVariables = interp.allowPublicVariables = false;
		var savedVariables:Map<String, Dynamic> = [];
		for (name => thing in interp.variables)
			if (!Reflect.isFunction(thing))
				savedVariables[name] = thing;
		final oldParent = parent;
		scriptCreation(path);

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

	inline public function setPublicVars(map:Map<String, Dynamic>)
		interp.publicVariables = map;

	override public function destroy():Void {
		call('destroy');
		interp = null;
		parser = null;
		super.destroy();
	}

	private function loadCodeFromString(code:String):Void {
		try {
			if (code != null && code.trim() != '') {
				expr = parser.parseString(code);
				canExecute = true;
			}
		} catch (e:haxe.Exception) {
			canExecute = false;
			trace('Error while parsing script: ${e.message}');
		}
	}
}