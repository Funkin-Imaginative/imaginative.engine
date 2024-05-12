package fnf.backend.scripting;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

class Script {
	var interp:Interp;
	var parser:Parser;
	var expr:Expr;

	var scriptCode:String = '';

	var canExecute:Bool = false;

	public var scriptName:String = '';

	public function new(file:String):Void {
		interp = new Interp();
		parser = new Parser();

		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		interp.allowStaticVariables = interp.allowPublicVariables = true;

		scriptName = haxe.io.Path.withoutDirectory(Paths.script(file));

		try {
			if (sys.FileSystem.exists(file)) scriptCode = sys.io.File.getContent(file);
		}
		catch (e:haxe.Exception) {
			scriptCode = '';
			trace('Error while trying to initialize script: $e');
		}

		loadCodeFromString(scriptCode);
		if (canExecute) {
			setVariables();

			try {
				interp.execute(expr);
			}
			catch (e:haxe.Exception) trace('Error while trying to execute script: $e');
		}
	}

	private function setVariables():Void {
		// Haxe
		set('Std', Std);
		set('Math', Math);
		set('Date', Date);
		set('Type', Type);
		set('StringTools', StringTools);
		set('Json', haxe.Json);
		set('Reflect', Reflect);
		set('Main', Main);

		// Lime + OpenFL
		set('Assets', openfl.utils.Assets);
		set('Application', lime.app.Application);
		set('window', lime.app.Application.current.window);

		// Flixel
		set('FlxG', FlxG);
		set('FlxBasic', FlxBasic);
		set('FlxObject', FlxObject);
		set('FlxSprite', FlxSprite);
		set('FlxText', FlxText);
		set('FlxCamera', FlxCamera);
		set('FlxMath', FlxMath);
		set('FlxTween', FlxTween);
		set('FlxEase', FlxEase);
		set('FlxGroup', FlxGroup);
		set('FlxTypedGroup', FlxTypedGroup);
		set('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
		set('FlxTypedSpriteGroup', FlxTypedSpriteGroup);
		set('FlxTimer', FlxTimer);
		set('FlxSound', FlxSound);
		set('FlxColor', Type.resolveClass('flixel.util.FlxColor_HSC'));
		set('FlxAxes', Type.resolveClass('flixel.util.FlxAxes_HSC'));
		set('FlxPoint', Type.resolveClass('flixel.math.FlxPoint_HSC'));

		// Radient Engine
		set('Alphabet', fnf.ui.Alphabet);
		set('Note', fnf.objects.note.Note);
		set('Strumline', fnf.objects.note.groups.StrumGroup);
		set('Strum', fnf.objects.note.Strum);
		set('Character', fnf.objects.Character);
		set('HealthIcon', fnf.ui.HealthIcon);
		set('Paths', Paths);
		set('MusicBeatState', fnf.states.MusicBeatState);
		set('MusicBeatSubstate', fnf.states.sub.MusicBeatSubstate);
		set('PlayState', PlayState);
		set('game', PlayState.direct);
		set('Conductor', Conductor);
		set('Controls', Controls);

		// Custom Functions
		set('addBehindObject', (obj:FlxBasic, ?behindThis:FlxBasic = null, ?into:Dynamic) -> {
			final group:Dynamic = into == null ? PlayState.direct : into;
			if (behindThis != null) group.insert(group.members.indexOf(behindThis), obj);
		});
	}

	public function set(variable:String, value:Dynamic):Void
		interp.variables.set(variable, value);

	public function get(variable):Dynamic
		return interp.variables.get(variable);

	public function call(funcName:String, args:Array<Dynamic>):Dynamic {
		if (!interp.variables.exists(funcName) || interp == null) return null;

		final func = interp.variables.get(funcName);

		if (func != null && Reflect.isFunction(func))
			try {
				final call = Reflect.callMethod(null, func, args);
				return call;
			} catch (e:haxe.Exception) trace('Error while trying to call function $funcName: $e');

		return null;
	}

	public function setScriptParent(parent:Dynamic):Void
		interp.scriptObject = parent;

	public function destroy():Void {
		interp = null;
		parser = null;
	}

	private function loadCodeFromString(code:String):Void {
		try {
			if (code != null && code.trim() != '') {
				expr = parser.parseString(code);
				canExecute = true;
			}
		}
		catch (e:haxe.Exception) {
			canExecute = false;
			trace('Error while parsing script: $e');
		}
	}
}