package fnf.backend.scripting;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

class Script extends FlxBasic {
	var interp:Interp;
	var parser:Parser;
	var expr:Expr;

	var scriptCode:String = '';

	var canExecute:Bool = false;

	public var scriptName:String = '';
	public var loaded:Bool = false;

	public function new(file:String, type:String):Void {
		super();

		interp = new Interp();
		parser = new Parser();

		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		interp.allowStaticVariables = interp.allowPublicVariables = true;

		var pathsSetup:String = '';
		switch (type) {
			case 'song': pathsSetup = Paths.file('data/$file/script.hx');
			case 'state': pathsSetup = Paths.file('content/states/$file.hx');
		}
		scriptName = haxe.io.Path.withoutDirectory(pathsSetup);


		try {scriptCode = Paths.getContent(pathsSetup);} catch (e:haxe.Exception) {
			scriptCode = '';
			trace('Error while trying to initialize script: $e');
		}

		for (name => thing in getBasicImports(this)) set(name, thing);
	}

	public function load() {
		if (loaded) return;
		onLoad();
		loaded = true;
	}

	public function onLoad() {
		loadCodeFromString(scriptCode);
		if (canExecute) {
			// setVariables();
			try {
				@:privateAccess interp.execute(parser.mk(EBlock([]), 0, 0));
				if (expr != null) {
					interp.execute(expr);
					call('new', []);
				}
			} catch (e:haxe.Exception) trace('Error while trying to execute script: $e');
		}
	}

	public static function getBasicImports(?script:Script):Map<String, Dynamic> {
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
			'FlxColor' => Type.resolveClass('flixel.util.FlxColor_HSC'),
			'FlxAxes' => Type.resolveClass('flixel.util.FlxAxes_HSC'),
			'FlxPoint' => Type.resolveClass('flixel.math.FlxPoint_HSC'),

			// Engine //
			'BareCameraPoint' => BareCameraPoint, // backend
			'CameraPoint' => CameraPoint,
			'Conductor' => Conductor,
			'Controls' => Controls,
			'SaveManager' => SaveManager,
			'NoteGroup' => fnf.objects.note.groups.NoteGroup, // objects.note.groups
			'SplashGroup' => fnf.objects.note.groups.SplashGroup,
			'StrumGroup' => fnf.objects.note.groups.StrumGroup,
			'Note' => fnf.objects.note.Note, // objects.note
			'Splash' => fnf.objects.note.Splash,
			'Strum' => fnf.objects.note.Strum,
			'Character' => fnf.objects.Character, // objects
			'PlayField' => fnf.objects.PlayField,
			'FreeplayState' => fnf.states.menus.FreeplayState, // states.menus
			'MainMenuState' => fnf.states.menus.MainMenuState,
			'StoryMenuState' => fnf.states.menus.StoryMenuState,
			'TitleState' => fnf.states.menus.TitleState,
			'GameOverSubstate' => fnf.states.sub.GameOverSubstate, // states.sub
			'MusicBeatSubstate' => MusicBeatSubstate,
			'OutdatedSubState' => fnf.states.sub.OutdatedSubState,
			'PauseSubState' => fnf.states.sub.PauseSubState,
			'LoadingState' => LoadingState, // states
			'MusicBeatState' => MusicBeatState,
			'PlayState' => PlayState,
			'Alphabet' => fnf.ui.Alphabet, // ui
			'HealthIcon' => fnf.ui.HealthIcon,
			'CoolUtil' => CoolUtil, // utils
			'Paths' => Paths,

			// Custom Functions //
			'addBehindObject' => (obj:FlxBasic, ?behindThis:FlxBasic = null, ?into:Dynamic) -> {
				if (script == null || script.parent == null)
					return trace('addBehindObject: Script parent not found.');
				var resolvedGroup = @:privateAccess FlxTypedGroup.resolveGroup(obj);
				if (resolvedGroup == null) resolvedGroup = script.parent;
				final group:Dynamic = into == null ? resolvedGroup : into;
				if (behindThis != null) group.insert(group.members.indexOf(behindThis), obj);
			},
			'disableScript' => () -> {
				if (script != null)
					script.active = false;
			},

			// self //
			'self' => script
		];
	}

	public function set(variable:String, value:Dynamic):Void interp.variables.set(variable, value);
	public function get(variable):Dynamic return interp.variables.get(variable);

	public function call(funcName:String, args:Array<Dynamic>):Dynamic {
		if (!interp.variables.exists(funcName) || interp == null) return null;

		final func = interp.variables.get(funcName);
		if (func != null && Reflect.isFunction(func))
			try {return Reflect.callMethod(null, func, args);}
			catch (e:haxe.Exception) trace('Error while trying to call function $funcName: $e');

		return null;
	}

	public var parent(get, set):Dynamic;
	inline function set_parent(value:Dynamic):Dynamic return interp.scriptObject = value;
	inline function get_parent():Dynamic return interp.scriptObject;

	public function setPublicVars(map:Map<String, Dynamic>) interp.publicVars = map;

	override public function destroy():Void {
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
			trace('Error while parsing script: $e');
		}
	}
}