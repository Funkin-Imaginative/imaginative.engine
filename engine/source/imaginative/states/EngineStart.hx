package imaginative.states;

#if MOD_SUPPORT
import imaginative.backend.system.Modding;
#end
import moonchart.Moonchart;
import moonchart.backend.Util as MoonUtil;
#if ANIMATE_SUPPORT
import animate.FlxAnimateAssets;
#end

/**
 * Run this class when you want to reload the engine.
 */
class EngineStart extends BeatState {
	/**
	 * A simple reload.
	 */
	inline public static function reload():Void
		fullReload(#if MOD_SUPPORT Modding.curSolo, Modding.modList, Modding.globalMods #end);
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

			Moonchart.DEFAULT_DIFF = 'normal';
			Moonchart.DEFAULT_ARTIST = Moonchart.DEFAULT_CHARTER = 'Unassigned';
			Moonchart.SPACE_SENSITIVE_DIFFS = Moonchart.CASE_SENSITIVE_DIFFS = true;
			Moonchart.init();

			MoonUtil.readFolder = (folder:String) -> [for (file in Paths.readFolder('root:$folder')) file.format()];
			MoonUtil.isFolder = (folder:String) -> Paths.folderExists('root:$folder');
			// MoonUtil.saveBytes = (path:String, bytes:Bytes);
			// MoonUtil.saveText = (path:String, text:String);
			// MoonUtil.getBytes = (path:String);
			MoonUtil.getText = (path:String) -> Assets.text('root:$path');

			#if ANIMATE_SUPPORT
			FlxAnimateFrames.exists = (path:String, type:openfl.utils.AssetType) -> return Paths.fileExists('root:$path');
			FlxAnimateFrames.getText = MoonUtil.getText;
			// FlxAnimateFrames.getBytes = MoonUtil.getBytes;
			FlxAnimateFrames.getBitmapData = (path:String) -> Assets.image('root:$path').bitmap;
			function newLister(path:String, ?type:openfl.utils.AssetType, ?library:String, includeSubDirectories:Bool = false):Array<String> {
				var list:Array<String> = Paths.readFolder('root:$path');
				if (includeSubDirectories)
					for (item in list)
						if (Paths.folderExists('root:$item'))
							list.concat(newLister(item, true));
				return list;
			}
			FlxAnimateFrames.list = newLister;
			#end

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
					if (Controls.global.botplay)
						try {
							ArrowField.botplay = !ArrowField.botplay;
							_log('[EngineStart] Botplay has been ${ArrowField.botplay ? 'enabled' : 'disabled'}.');
						} catch(error:haxe.Exception)
							_log('[EngineStart] Somehow Failed to trigger Botplay??');

					if (Controls.global.resetState)
						try {
							_log('[EngineStart] Reseting state...');
							BeatState.resetState();
							_log('[EngineStart] Reset state successfully!');
						} catch(error:haxe.Exception)
							_log('[EngineStart] Reset state failed.');

					if (Controls.global.shortcutState)
						try { // TODO: Use createInstance for non scripted states.
							_log('[EngineStart] Heading to the MainMenu...');
							BeatState.switchState(() -> new imaginative.states.menus.MainMenu());
							_log('[EngineStart] Successfully entered the MainMenu!');
						} catch(error:haxe.Exception)
							_log('[EngineStart] Failed to enter the MainMenu.');

					if (Controls.global.reloadGame)
						try {
							_log('[EngineStart] Reloading the game...');
							reload();
							_log('[EngineStart] Reload successfully!');
						} catch(error:haxe.Exception)
							_log('[EngineStart] Reload failed.');
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