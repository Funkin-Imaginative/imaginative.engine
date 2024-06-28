package fnf.backend.scripting;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import haxe.io.Path;

// This class was mostly coded by @Zyflx and was used on smth else before he started helping lol.
class Script extends FlxBasic implements IReloadable {
	// because parent being null returns the script itself I think it would be best to make this unreflective
	@:unreflective var interp:Interp;
	@:unreflective var parser:Parser;
	@:unreflective var expr:Expr;

	@:unreflective var scriptCode:String = '';

	@:unreflective var canExecute:Bool = false;

	public var loaded:Bool = false;

	@:unreflective var invalid:Bool = false;
	public var isInvalid(get, never):Bool;
	private function get_isInvalid():Bool return invalid;

	public static final exts:Array<String> = ['hx', 'hscript', 'hsc', 'hxs', 'hxc', 'lua'];

	public static function create(file:String, type:String = ''):Script {
		final path:String = Paths.script(switch (type) {
			case 'state': 'content/states/$file';
			case 'icon': 'images/icons/$file';
			case 'song': 'songs/${PlayState.SONG.song}/$file';
			case 'char': 'characters/$file';
			default: '$file';
		});
		#if debug trace(path); #end
		switch (Path.extension(path).toLowerCase()) {
			case 'hx' | 'hscript' | 'hsc' | 'hxs' | 'hxc': return new Script(path);
			case 'lua': #if THROW_LUA_MAKEFUN @:privateAccess if (!fnf.states.sub.LuaMakeFunLmao.alreadyOpened) FlxG.state.openSubState(new fnf.states.sub.LuaMakeFunLmao()); else fnf.states.sub.PauseSubState.bfStare = true; #else trace('LUA SCRIPTS AIN\'T SUPPORTED BITCH!!!'); #end
			// doing a cne but more trollish lmao
		}
		return new Script(FailsafeUtil.invaildScriptKey);
	}

	// idk what to call this
	public static function getDefaults(?script:Script):Map<String, Dynamic> {
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
			'FlxText' => FlxText,
			'FlxCamera' => FlxCamera,
			'FlxMath' => FlxMath,
			'FlxTween' => FlxTween,
			'FlxEase' => FlxEase,
			'FlxGroup' => FlxGroup,
			'FlxTypedGroup' => FlxTypedGroup,
			'FlxSpriteGroup' => flixel.group.FlxSpriteGroup,
			'FlxTypedSpriteGroup' => FlxTypedSpriteGroup,
			'FlxTimer' => FlxTimer,
			'FlxSound' => FlxSound,
			'FlxColor' => Type.resolveClass('flixel.util.FlxColor_HSC'), 'FlxColorHelper' => FlxColorHelper,
			'FlxAxes' => Type.resolveClass('flixel.util.FlxAxes_HSC'),
			'FlxPoint' => Type.resolveClass('flixel.math.FlxPoint_HSC'),

			// Engine //
			'AnimType' => Type.resolveClass('fnf.backend.interfaces.IPlayAnim.AnimType_HSC'), // backend.interfaces
			'PositionMeta' => PositionMeta, // backend.metas
			'SongState' => SongState, // backend.song
			'SongSubstate' => SongSubstate,
			'ScriptEvent' => ScriptEvent, // backend.scripting.events , may preadd more soon
			'ModState' => ModState, // backend.scripting
			'ModSubstate' => ModSubstate,
			'Script' => Script,
			'ScriptGroup' => ScriptGroup,
			'BareCameraPoint' => BareCameraPoint, // backend
			'CameraPoint' => CameraPoint,
			'Conductor' => Conductor,
			'Controls' => Controls,
			'SaveManager' => SaveManager,
			'NoteGroup' => fnf.objects.note.groups.NoteGroup, // objects.note.groups
			'StrumGroup' => fnf.objects.note.groups.StrumGroup,
			'HoldCover' => fnf.objects.note.HoldCover, // objects.note
			'Note' => fnf.objects.note.Note,
			'Splash' => fnf.objects.note.Splash,
			'Strum' => fnf.objects.note.Strum,
			'BetterBarFillDirection' => Type.resolveClass('fnf.objects.BetterBar.BetterBarFillDirection_HSC'), 'BetterBar' => fnf.objects.BetterBar, // objects
			'Character' => fnf.objects.Character,
			'SpriteFacing' => Type.resolveClass('fnf.objects.FunkinSprite.SpriteFacing_HSC'), 'FunkinSprite' => fnf.objects.FunkinSprite,
			'PlayField' => PlayField,
			'FreeplayState' => fnf.states.menus.FreeplayState, // states.menus
			'MainMenuState' => fnf.states.menus.MainMenuState,
			'StoryMenuState' => fnf.states.menus.StoryMenuState,
			'TitleState' => fnf.states.menus.TitleState,
			'GameOverSubstate' => fnf.states.sub.GameOverSubstate, // states.sub
			'OutdatedSubState' => fnf.states.sub.OutdatedSubState,
			'PauseSubState' => fnf.states.sub.PauseSubState,
			'LoadingState' => LoadingState, // states
			'PlayState' => PlayState,
			'Alphabet' => fnf.ui.Alphabet, // ui
			'HealthIcon' => fnf.ui.HealthIcon,
			'CoolUtil' => CoolUtil, // utils
			'FailsafeUtil' => FailsafeUtil,
			'ModUtil' => ModUtil,
			'Paths' => Paths,
			'PlayUtil' => PlayUtil,

			// Custom Functions //
			'addInfrontOfObject' => (obj:FlxBasic, infrontOfThis:FlxBasic = null, ?into:Dynamic) -> {
				if (script == null || script.parent == null)
					return trace('addInfrontOfObject: Script and/or parent not found.');
				var resolvedGroup = @:privateAccess FlxTypedGroup.resolveGroup(obj);
				if (resolvedGroup == null) resolvedGroup = script.parent;
				final group:Dynamic = into == null ? resolvedGroup : into;
				if (infrontOfThis != null) group.insert(group.members.indexOf(infrontOfThis) + 1, obj);
			},
			'addBehindObject' => (obj:FlxBasic, behindThis:FlxBasic = null, ?into:Dynamic) -> {
				if (script == null || script.parent == null)
					return trace('addBehindObject: Script and/or parent not found.');
				var resolvedGroup = @:privateAccess FlxTypedGroup.resolveGroup(obj);
				if (resolvedGroup == null) resolvedGroup = script.parent;
				final group:Dynamic = into == null ? resolvedGroup : into;
				if (behindThis != null) group.insert(group.members.indexOf(behindThis), obj);
			},
			'disableScript' => () -> {
				if (script != null)
					script.active = false;
			},
			'trace' => (value:Dynamic) -> {
				trace('${script == null ? '???' : '${script.rawPath}'}: $value');
			},

			// self //
			'self' => script
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
		for (name => thing in getDefaults(this)) set(name, thing);
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

		if (path == FailsafeUtil.invaildScriptKey) invalid = true; else {
			try {scriptCode = Paths.getContent(path);} catch(e:haxe.Exception) {
				trace('Error while trying to initialize script: ${e.message}');
				scriptCode = '';
			}
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
					if (!stopNewCall) call('new');
				}
			} catch(e:haxe.Exception) trace('Error while trying to execute script: ${e.message}');
		}
	}

	inline public function load(stopNewCall:Bool = false) {
		if (loaded) return;
		onLoad(stopNewCall);
	}

	inline public function set(variable:String, value:Dynamic):Void interp.variables.set(variable, value);
	inline public function get(variable:String):Dynamic return interp.variables.get(variable);

	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null || !interp.variables.exists(funcName)) return null;

		final func = interp.variables.get(funcName);
		if (func != null && Reflect.isFunction(func))
			try {return Reflect.callMethod(null, func, args == null ? [] : args);}
			catch(e:haxe.Exception) trace('Error while trying to call function $funcName: ${e.message}');

		return null;
	}

	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		call(func, [event]);
		if (event.stopped) event;
		return event;
	}

	public var parent(get, set):Dynamic;
	inline function get_parent():Dynamic return interp.scriptObject == null ? this : interp.scriptObject; // lol
	inline function set_parent(value:Dynamic):Dynamic return interp.scriptObject = value;

	inline public function setPublicVars(map:Map<String, Dynamic>) interp.publicVariables = map;

	override public function destroy():Void {
		call('destroy');
		interp = null;
		parser = null;
		super.destroy();
	}

	public var reloading(default, null):Bool = false;
	public function reload(hard:Bool = false) {
		call('reload', [hard, reloading = true]);
		if (hard) {
			// save variables
			interp.allowStaticVariables = interp.allowPublicVariables = false;
			var savedVariables:Map<String, Dynamic> = [];
			for (name => thing in interp.variables)
				if (!Reflect.isFunction(thing))
					savedVariables[name] = thing;
			final oldParent = parent;
			scriptCreation(path);

			for (name => thing in getDefaults(this))
				set(name, thing);

			load();
			parent = oldParent;

			for (name => thing in savedVariables)
				interp.variables.set(name, thing);

			interp.allowStaticVariables = interp.allowPublicVariables = true;
		}
		call('reloadPost', [hard, reloading = false]);
	}

	private function loadCodeFromString(code:String):Void {
		try {
			if (code != null && code.trim() != '') {
				expr = parser.parseString(code);
				canExecute = true;
			}
		} catch(e:haxe.Exception) {
			canExecute = false;
			trace('Error while parsing script: ${e.message}');
		}
	}
}