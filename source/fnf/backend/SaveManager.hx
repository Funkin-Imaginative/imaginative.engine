package fnf.backend;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

class SaveManager {
	private static var initialized:Bool = false;
	public static var savesMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	private static var theSave:FlxSave;

	public static function setSave(page:String, sub:String):Dynamic {
		var result:Dynamic;
		result = savesMap.get(page).set(sub);
		applySave();
		return result;
	}
	public static function getSave(page:String, sub:String = 'nothing setup'):Dynamic {
		var result:Dynamic;
		if (sub == 'nothing setup') result = savesMap.get(page);
		else result = savesMap.get(page).get(sub);
		return result;
	}

	// haxe was being a bitch so I had to do it this way
	public static function loadDefault():Map<String, Dynamic> {
		var defaultMap:Map<String, Dynamic> = new Map<String, Dynamic>();

		// prefs
		defaultMap.set('prefs', new Map<String, Dynamic>()); var page:Map<String, Dynamic> = defaultMap.get('prefs');
		page.set('autoPause', true);
		page.set('showFpsCounter', false);

		// gameplay
		defaultMap.set('gameplay', new Map<String, Dynamic>()); page = defaultMap.get('gameplay');
		page.set('downscroll', false);
		page.set('ghostTapping', true);
		page.set('stopDeathKey', false);
		page.set('camZooming', true);
		page.set('doVwoosh', true);

		// graphics
		defaultMap.set('graphics', new Map<String, Dynamic>()); page = defaultMap.get('graphics');
		page.set('qualityLevel', 1);
		page.set('shaders', true);
		page.set('aliasing', true);
		page.set('cacheGPU', false);
		page.set('fpsType', 'Capped');
		page.set('fpsCap', 60);

		// sensitivity
		defaultMap.set('sensitivity', new Map<String, Dynamic>()); page = defaultMap.get('sensitivity');
		page.set('naughtiness', true);
		page.set('violence', true);
		page.set('lights', false);

		// controls
		defaultMap.set('controls', new Map<String, Dynamic>()); page = defaultMap.get('controls');
		page.set('binds', [
			[D, F, K, L], // kl for life lmao
			[LEFT, DOWN, UP, RIGHT]
		]);

		// controls, menus
		page.set('menus', new Map<String, Dynamic>()); var sub:Map<String, Dynamic> = page.get('menus');
		sub.set('navBinds', [
			[A, S, W, D],
			[LEFT, DOWN, UP, RIGHT]
		]);
		sub.set('accept', [ENTER, SPACE]);
		sub.set('back', [BACKSPACE, ESCAPE]);
		sub.set('reset', [R, null]);
		sub.set('pause', [ENTER, ESCAPE]);
		page.set('fullscreen', [F11, null]);

		// controls, volume
		page.set('volume', new Map<String, Dynamic>()); sub = page.get('volume');
		sub.set('mute', [ZERO, NUMPADZERO]);
		sub.set('raise', [PLUS, NUMPADPLUS]);
		sub.set('lower', [MINUS, NUMPADMINUS]);

		return defaultMap;
	}

	public static function init():Void {
		if (!initialized || theSave == null) {
			theSave = new FlxSave();
			theSave.bind('options');
			#if debug theSave.data.options = null; #end // for testing, comment out when done
			theSave.data.options = theSave.data.options == null ? loadDefault() : theSave.data.options;
			theSave.flush();
			savesMap = theSave.data.options;
			initialized = true;
			trace(theSave.data.options);
		}
	}

	public static function applySave():Void {
		theSave.data.options = savesMap;
		theSave.flush();
	}
}