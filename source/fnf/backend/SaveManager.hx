package fnf.backend;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

// hate typing a ton of bs
typedef Bind = Null<FlxKey>;
typedef BindsArray = Array<Bind>;
typedef BindArrays = Array<BindsArray>;

class SaveManager {
	// Please use the set and get funcs as the set funcs will apply the data after setting.
	public static var modOptionsMap:Map<String, Dynamic> = new Map<String, Dynamic>(); // is public instead since, ya know... mods.
	private static var optionsMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	private static var initialized:Bool = false;
	private static var theSave:FlxSave;

	/**
	 * Set's the save data for the specified directory.
	 * @param dir ex: `graphics.qualityLevel`
	 * @param value ex: `0.56`
	 * @return Dynamic `value`
	 */
	public static function setOption(dir:String, value:Dynamic):Dynamic {
		var path:Array<String> = dir.split('.');
		if (path[0] == 'controls') {trace('setOption: Please use setBind or setKeyBind.'); return null;}
		if (path[1] == null) {trace('setOption: Please put something.'); return null;}
		optionsMap.get(path[0]).set(path[1], value); // Make system for making sure you don't set Int as String and etc.
		applySave();
		switch (path[path.length - 1]) {
			case 'autoPause': FlxG.autoPause = value;
			case 'showFpsCounter': Main.fpsCounter.visible = value;
		}
		return value;
	}
	/**
	 * Get's the save data for the specified directory.
	 * @param dir ex: `graphics.qualityLevel`
	 * @return Dynamic `value`
	 */
	public static function getOption(dir:String):Dynamic {
		var result:Dynamic;
		var path:Array<String> = dir.split('.');
		if (path[0] == 'controls') {trace('getOption: Please use getBind or getKeyBind.'); return null;}
		if (path[1] == null) result = optionsMap.get(path[0]);
		else result = optionsMap.get(path[0]).get(path[1]);
		return result;
	}

	/**
	 * Set's the save data for a bind.
	 * @param dir ex: `menus.reset`
	 * @param index a number silly
	 * @param key the new input
	 * @return Bind
	 */
	public static function setBind(dir:String, index:Int, key:Bind):Bind {
		var path:Array<String> = dir.split('.');
		if (path[0] == 'binds' || path[1] == 'navBinds') {trace('setBind: Please use setKeyBind.'); return null;}
		if (path[1] == null) optionsMap.get('controls').get(path[0])[index] = key;
		else optionsMap.get('controls').get(path[0]).get(path[1])[index] = key;
		applySave();
		return key;
	}
	/**
	 * Get's the save data for a bind.
	 * @param dir ex: `menus.reset`
	 * @return BindsArray
	 */
	public static function getBind(dir:String):BindsArray {
		var result:BindsArray;
		var path:Array<String> = dir.split('.');
		if (path[0] == 'binds' || path[1] == 'navBinds') {trace('getBind: Please use getKeyBind.'); return null;}
		if (path[1] == null) result = optionsMap.get('controls').get(path[0]);
		else result = optionsMap.get('controls').get(path[0]).get(path[1]);
		return result;
	}

	// keyBind versions is for song controls (hitting notes/ui navigation)
	/**
	 * Set's a keybind.
	 * @param type `notes` or `menus`
	 * @param indexs first is set, second is noteData
	 * @param key the new input
	 * @return Bind
	 */
	public static function setKeyBind(type:String, indexs:Array<Int>, key:Bind):Bind {
		switch (type) {
			case 'notes': optionsMap.get('controls').get('binds')[indexs[0]][indexs[1]] = key;
			case 'menus': optionsMap.get('controls').get('menus').get('navBinds')[indexs[0]][indexs[1]] = key;
			default: trace('setBind: $type is invaild, do "notes" or "menus".');
			return null;
		}
		applySave();
		return key;
	}
	/**
	 * Get's your keybinds.
	 * @param type `notes` or `menus`
	 * @return BindArrays
	 */
	public static function getKeyBind(type:String):BindArrays {
		switch (type) {
			case 'notes': return optionsMap.get('controls').get('binds');
			case 'menus': return optionsMap.get('controls').get('menus').get('navBinds');
			default: trace('getBind: $type is invaild, do "notes" or "menus".');
			return null;
		}
	}

	// haxe was being a bitch so I had to do it this way
	public static function loadDefault():Map<String, Dynamic> {
		var defaultMap:Map<String, Dynamic> = new Map<String, Dynamic>();
		/*
			ModName:
				options:
					autoDodge => false
				binds:
					dodge => [Key1, Key2]
		*/
		// prefs
		defaultMap.set('prefs', new Map<String, Dynamic>()); var page:Map<String, Dynamic> = defaultMap.get('prefs');
		page.set('autoPause', true);
		page.set('showFpsCounter', false);
		page.set('pauseOnLostFocus', false);

		// gameplay
		defaultMap.set('gameplay', new Map<String, Dynamic>()); page = defaultMap.get('gameplay');
		page.set('strumShift', false);
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
		page.set('lights', true);

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
			theSave.data.modOptions = theSave.data.modOptions == null ? new Map<String, Dynamic>() : theSave.data.modOptions;
			theSave.data.options = theSave.data.options == null ? loadDefault() : theSave.data.options;
			theSave.flush();
			modOptionsMap = theSave.data.modOptions;
			optionsMap = theSave.data.options;
			initialized = true;
			// trace(theSave.data.options);
		}
	}

	public static function applySave():Void {
		theSave.data.modOptions = modOptionsMap;
		theSave.data.options = optionsMap;
		theSave.flush();
	}
}