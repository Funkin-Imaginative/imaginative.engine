package imaginative.states;

class EngineProcess extends BeatState {
	override public function new() {
		super(false);
	}

	override public function create():Void {
		FlxSprite.defaultAntialiasing = true;
		Console.init();
		Assets.init();
		Conductor.init();
		GlobalScript.init();

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

		FlxG.mouse.useSystemCursor = true; // we use custom object lol

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
		FlxG.game.debugger.console.registerClass(Settings);
		FlxG.game.debugger.console.registerClass(Controls);
		FlxG.game.debugger.console.registerClass(ArrowField);
		FlxG.game.debugger.console.registerFunction('resetState', () -> BeatState.resetState());
		#end

		FlxG.signals.preUpdate.add(() -> {
			if (Settings.setup.debugMode) {
				if (Controls.resetState) {
					log('Reseting state...', SystemMessage);
					BeatState.resetState();
					log('Reset state successfully!', SystemMessage);
				}

				if (Controls.shortcutState) {
					log('Heading to the MainMenu...', SystemMessage);
					BeatState.switchState(new imaginative.states.menus.MainMenu());
					log('Successfully entered the MainMenu!', SystemMessage);
				}

				if (Controls.reloadGlobalScripts)
					if (GlobalScript.scripts.length > 0) {
						log('Reloading global scripts...', SystemMessage);
						GlobalScript.loadScript();
						log('Global scripts successfully reloaded.', SystemMessage);
					} else {
						log('Loading global scripts...', SystemMessage);
						GlobalScript.loadScript();
					}
			}
		});

		BeatState.switchState(new StartScreen());
	}
}