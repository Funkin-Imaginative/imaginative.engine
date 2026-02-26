package imaginative.states;

#if MOD_SUPPORT
import imaginative.backend.system.Modding;
#end
import moonchart.Moonchart;
import moonchart.backend.Util as MoonUtil;
#if ANIMATE_SUPPORT
import animate.FlxAnimateFrames;
#end

/**
 * Run this class when you want to reload the engine.
 */
class EngineStart extends BeatState {
	/**
	 * A simple reload.
	 */
	inline public static function reload():Void {
		#if MOD_SUPPORT
		fullReload(Modding.curSolo, Modding.modList, Modding.globalMods);
		#end
	}
	/**
	 * A full reload with the desired mods.
	 */
	inline public static function fullReload(?solo:String, ?modList:Array<String>, ?globalMods:Array<String>):Void {
		#if MOD_SUPPORT
		Modding.curSolo = solo ?? '';
		Modding.modList = modList ?? [];
		Modding.globalMods = globalMods ?? [];
		#end
		BeatState.switchState(() -> new EngineStart());
	}

	override public function new() {
		super(false);
	}

	static var doneInitLaunch:Bool = false;
	override public function create():Void {
		if (!doneInitLaunch) {
			Conductor.init();
			FileUtil.init();

			Moonchart.SPACE_SENSITIVE_DIFFS = Moonchart.CASE_SENSITIVE_DIFFS = true;
			Moonchart.DEFAULT_ARTIST = Moonchart.DEFAULT_CHARTER = 'Unassigned';
			Moonchart.DEFAULT_TITLE = Moonchart.DEFAULT_ALBUM = 'Unknown';
			Moonchart.DEFAULT_DIFF = 'normal';

			#if ANIMATE_SUPPORT
			@:privateAccess {
				FlxAnimateFrames.getTextFromPath = (path:String) -> return text('root:$path').replace(String.fromCharCode(0xFEFF), '');
				FlxAnimateFrames.existsFile = (path:String, type:openfl.utils.AssetType) -> return Paths.fileExists('root:$path');
				FlxAnimateFrames.listWithFilter = (path:String, filter:String->Bool) -> return [for (file in Paths.readFolder('root:$path')) file.format()].filter(filter);
				FlxAnimateFrames.getGraphic = (path:String) -> return image('root:$path');
			}
			#end

			MoonUtil.readFolder = (folder:String) -> [for (file in Paths.readFolder('root:$folder')) file.format()];
			MoonUtil.isFolder = (folder:String) -> Paths.folderExists('root:$folder');
			// MoonUtil.saveBytes = (path:String, bytes:Bytes);
			// MoonUtil.saveText = (path:String, text:String);
			// MoonUtil.getBytes = (path:String);
			MoonUtil.getText = (path:String) -> Assets.text('root:$path');

			FlxG.fixedTimestep = false;
			FlxSprite.defaultAntialiasing = true; // this ain't a pixel game... yeah ik week 6 exists!

			#if FLX_DEBUG
			for (cls in FunkinUtil.getClasses('imaginative')) FlxG.game.debugger.console.registerClass(cls);
			FlxG.game.debugger.console.registerClass(FlxWindow);
			FlxG.game.debugger.console.registerFunction('resetState', () -> BeatState.resetState());
			FlxG.game.debugger.console.registerFunction('setCameraToCharacter', (camera:FlxCamera, char:Character) -> {
				var camPos = char.getCamPos();
				camera.target.setPosition(camPos.x, camPos.y);
				camera.snapToTarget();
			});
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

					if (Controls.global.reloadGame) {
						_log('Reloading the game...');
						reload();
					}
				}
			});

			doneInitLaunch = true;
		}
		Assets.clearAll(true, true, true);
		GlobalScript.init();
		Settings.init();
		Controls.init();

		super.create();

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();

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

		BeatState.switchState(() -> new StartScreen());
	}
}