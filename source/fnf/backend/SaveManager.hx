package fnf.backend;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

// prefs page
typedef PrefsPage = {
	var showFpsCounter:Bool;
	var autoPause:Bool;
}

// gameplay page
typedef GameplayPage = {
	var stopDeathKey:Bool;
	var ghostTapping:Bool;
	var downscroll:Bool;
	var camZooming:Bool;
	var doVwoosh:Bool;
}

// sensitivity page
typedef SensitivityPage = {
	var censorlanguage:Bool;
	var eighteenPlus:Bool;
	var lights:Bool;
}

// controls page
typedef MenuControls = {
	var navBinds:Array<Array<FlxKey>>;
	var accept:Array<FlxKey>;
	var back:Array<FlxKey>;
	var reset:Array<FlxKey>;
	var pause:Array<FlxKey>;
}
typedef VolumeKeys = {
	var mute:Array<FlxKey>;
	var raise:Array<FlxKey>;
	var lower:Array<FlxKey>;
}
typedef ControlsPage = {
	var binds:Array<Array<FlxKey>>;
	var menus:MenuControls;
	var fullscreen:Array<FlxKey>;
	var volume:VolumeKeys;
}

// pages
typedef PageInfo = {
	var prefs:PrefsPage;
	var gameplay:GameplayPage;
	var sensitivity:SensitivityPage;
	var controls:ControlsPage;
}

class SaveManager {
	private static var initialized:Bool = false;
	public static var savesMap:PageInfo;
	private static var theSave:FlxSave;

	public static function setSave(page:String):Void {
		switch (page) {
			default:
				//
		}
		applySave();
	}
	public static function getSave():PageInfo return savesMap;

	public static function loadDefault():PageInfo {
		return {
			prefs: {
				showFpsCounter: false,
				autoPause: true,
			},
			gameplay: {
				stopDeathKey: false,
				ghostTapping: true,
				downscroll: false,
				camZooming: true,
				doVwoosh: true
			},
			sensitivity: {
				censorlanguage: false,
				eighteenPlus: true,
				lights: false
			},
			controls: {
				binds: [
					[D, F, K, L], // kl for life lmao
					[LEFT, DOWN, UP, RIGHT]
				],
				menus: {
					navBinds: [
						[A, S, W, D],
						[LEFT, DOWN, UP, RIGHT]
					],
					accept: [ENTER, SPACE],
					back: [BACKSPACE, ESCAPE],
					reset: [R, R],
					pause: [ENTER, ESCAPE],
				},
				fullscreen: [F11, F11],
				volume: {
					mute: [ZERO, NUMPADZERO],
					raise: [PLUS, NUMPADPLUS],
					lower: [MINUS, NUMPADMINUS]
				}
			}
		};
	}

	public static function initSaveManager():Void {
		if (!initialized || theSave == null) {
			theSave = new FlxSave();
			theSave.bind('options');
			theSave.data.options = theSave.data.options ?? theSave;
			initialized = true;
		}
	}

	public static function applySave():Void {
		theSave.data.options = savesMap;
		theSave.flush();
	}
}