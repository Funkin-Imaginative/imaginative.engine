package imaginative.states;

import moonchart.Moonchart;

class EngineProcess extends BeatState {
	override public function new() {
		super(false);
	}

	override public function create():Void {
		Moonchart.CASE_SENSITIVE_DIFFS = true;
		Moonchart.SPACE_SENSITIVE_DIFFS = true;
		Moonchart.DEFAULT_DIFF = 'normal';
		Moonchart.DEFAULT_ARTIST = 'Unassigned';
		Moonchart.DEFAULT_ALBUM = 'Unknown';
		Moonchart.DEFAULT_CHARTER = 'Unassigned';
		Moonchart.DEFAULT_TITLE = 'Unknown';

		FlxG.fixedTimestep = false;
		FlxSprite.defaultAntialiasing = true; // this ain't a pixel game... yeah ik week 6 exists!
		Console.init();
		Assets.init();
		Conductor.init();
		GlobalScript.init();
		Settings.init();
		Controls.init();
		FileUtil.init();

		super.create();

		#if CHECK_FOR_UPDATES
		if (Settings.setup.checkForUpdates) {
			/* var http:haxe.Http = new haxe.Http("https://raw.githubusercontent.com/Funkin-Imaginative/imaginative.engine.dev/refs/heads/main/project.xml?token=GHSAT0AAAAAACW7FJHPLYQBPTHCRFLHZ2R2ZZU3VRA");

			http.onData = (data:String) -> {
				latestVersion = new haxe.xml.Access(Xml.parse(data).firstElement()).node.app.att.version;
				if (engineVersion < latestVersion) {
					log('New version available!', WarningMessage);
					updateAvailable = true;
				}
			}

			http.onError = (error:String) ->
				log('error: $error', ErrorMessage);

			http.request(); */
		}
		#end

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerClass(FlxWindow);
		FlxG.game.debugger.console.registerClass(Scoring);
		FlxG.game.debugger.console.registerClass(Conductor);
		FlxG.game.debugger.console.registerClass(Assets);
		#if MOD_SUPPORT
		FlxG.game.debugger.console.registerClass(Modding);
		#end
		FlxG.game.debugger.console.registerClass(Paths);
		FlxG.game.debugger.console.registerClass(SaveData);
		FlxG.game.debugger.console.registerClass(Settings);
		FlxG.game.debugger.console.registerClass(Controls);
		FlxG.game.debugger.console.registerClass(ArrowField);
		FlxG.game.debugger.console.registerFunction('resetState', () -> BeatState.resetState());
		FlxG.game.debugger.console.registerFunction('setCameraToCharacter', (camera:FlxCamera, char:Character) -> {
			var camPos = char.getCamPos();
			camera.target.setPosition(camPos.x, camPos.y);
			camera.snapToTarget();
		});
		var QuickSave = {} // for quick access to all saves in the debug console
		for (name => save in @:privateAccess SaveData.saveInstances)
			QuickSave._set(name, save);
		FlxG.game.debugger.console.registerObject('QuickSave', QuickSave);
		#end

		FlxG.signals.preUpdate.add(() -> {
			if (Settings.setup.debugMode) {
				if (Controls.global.botplay) {
					ArrowField.botplay = !ArrowField.botplay;
					_log('Botplay has been ${ArrowField.botplay ? 'enabled' : 'disabled'}.');
				}

				if (Controls.global.resetState) {
					_log('Reseting state...');
					BeatState.resetState();
					_log('Reset state successfully!');
				}

				if (Controls.global.shortcutState) {
					_log('Heading to the MainMenu...');
					BeatState.switchState(() -> new imaginative.states.menus.MainMenu());
					_log('Successfully entered the MainMenu!');
				}

				// TODO: Code this in.
				// if (Controls.global.reloadGame)
			}
		});

		BeatState.switchState(() -> new StartScreen());
	}
}