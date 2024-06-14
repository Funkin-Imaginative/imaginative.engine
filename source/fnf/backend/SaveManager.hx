package fnf.backend;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

// hate typing a ton of bs
typedef Bind = Null<FlxKey>;
typedef BindsArray = Array<Bind>;
typedef BindArrays = Array<BindsArray>;

typedef OptionSetup = {
	var options:Map<String, Dynamic>;
	var binds:Map<String, Dynamic>;
}
typedef BindsSetup = {
	var menus:BindArrays;
	var notes:BindArrays;
}

class SaveManager {
	// Please use the set and get funcs as the set funcs will apply the data after setting.
	public static var modOptionsMap:Map<String, Dynamic> = new Map<String, Dynamic>(); // is public instead since, ya know... mods.
	private static var optionsMap:OptionSetup;
	private static var bindsStorage:BindsSetup;
	private static var initialized:Bool = false;
	private static var theSave:FlxSave;

	/**
	 * Set's the save data for the specified directory.
	 * @param option ex: `qualityLevel`
	 * @param value ex: `0.56`
	 * @return Dynamic `value`
	 */
	public static function setOption(option:String, value:Dynamic):Dynamic {
		optionsMap.options.set(option, value); // Maybe make system for making sure you don't set Int as String and etc.
		applySave();
		switch (option) {
			case 'autoPause': FlxG.autoPause = value;
			case 'showFpsCounter': Main.fpsCounter.visible = value;
		}
		return value;
	}
	/**
	 * Get's the save data for the specified directory.
	 * @param option ex: `qualityLevel`
	 * @return Dynamic `value`
	 */
	public static function getOption(option:String):Dynamic
		return optionsMap.options.get(option);

	// /**
	//  * Set's the save data for a bind.
	//  * @param bind ex: `menus.reset`
	//  * @param index a number silly
	//  * @param key the new input
	//  * @return Bind
	//  */
	// public static function setBind(bind:String, index:Int, key:Bind):Bind {
	// 	var path:Array<String> = bind.split('.');
	// 	if (path[0] == 'binds' || path[1] == 'navBinds') {trace('setBind: Please use setKeyBind.'); return null;}
	// 	if (path[1] == null) optionsMap.get('controls').get(path[0])[index] = key;
	// 	else optionsMap.get('controls').get(path[0]).get(path[1])[index] = key;
	// 	applySave();
	// 	return key;
	// }
	// /**
	//  * Get's the save data for a bind.
	//  * @param bind ex: `menus.reset`
	//  * @return BindsArray
	//  */
	// public static function getBind(bind:String):BindsArray {
	// 	var result:BindsArray;
	// 	var path:Array<String> = bind.split('.');
	// 	if (path[0] == 'binds' || path[1] == 'navBinds') {trace('getBind: Please use getKeyBind.'); return null;}
	// 	if (path[1] == null) result = optionsMap.get('controls').get(path[0]);
	// 	else result = optionsMap.get('controls').get(path[0]).get(path[1]);
	// 	return result;
	// }

	// // keyBind versions is for song controls (hitting notes/ui navigation)
	// /**
	//  * Set's a keybind.
	//  * @param type `notes` or `menus`
	//  * @param indexs first is set, second is noteData
	//  * @param key the new input
	//  * @return Bind
	//  */
	// public static function setKeyBind(type:String, indexs:Array<Int>, key:Bind):Bind {
	// 	switch (type) {
	// 		case 'notes': optionsMap.get('controls').get('binds')[indexs[0]][indexs[1]] = key;
	// 		case 'menus': optionsMap.get('controls').get('menus').get('navBinds')[indexs[0]][indexs[1]] = key;
	// 		default: trace('setBind: $type is invaild, do "notes" or "menus".');
	// 		return null;
	// 	}
	// 	applySave();
	// 	return key;
	// }
	// /**
	//  * Get's your keybinds.
	//  * @param type `notes` or `menus`
	//  * @return BindArrays
	//  */
	// public static function getKeyBind(type:String):BindArrays {
	// 	switch (type) {
	// 		case 'notes': return optionsMap.get('controls').get('binds');
	// 		case 'menus': return optionsMap.get('controls').get('menus').get('navBinds');
	// 		default: trace('getBind: $type is invaild, do "notes" or "menus".');
	// 		return null;
	// 	}
	// }

	// haxe was being a bitch so I had to do it this way
	public static function loadDefault():OptionSetup {
		/*
			ModName:
				options:
					autoDodge => false
				binds:
					dodge => [Key1, Key2]
		*/

		var menus:Map<String, Dynamic> = [
			'accept' => [ENTER, SPACE],
			'back' => [ENTER, SPACE],
			'reset' => [R, null],
			'pause' => [ENTER, ESCAPE]
		];
		var volume:Map<String, Dynamic> = [
			'mute' => [ZERO, NUMPADZERO],
			'raise' => [PLUS, NUMPADPLUS],
			'lower' => [MINUS, NUMPADMINUS]
		];

		return {
			options: [
				// prefs
				'autoPause' => true,
				'showFpsCounter' => false,
				'strumShift' => false,
				'sustainsUnderStrums' => false,
				'beatLoop' => true,

				// gameplay
				'downscroll' => false,
				'ghostTapping' => true,
				'stopDeathKey' => false,
				'camZooming' => true,
				'notesVwooshOnRestart' => true,

				// graphics
				'qualityLevel' => 1,
				'enableShaders' => true,
				'allowAliasing' => true,
				'cacheGPU' => false,
				'fpsType' => 'Capped',
				'fpsCap' => 60,

				// sensitivity
				'naughtiness' => true,
				'violence' => true,
				'flashingLights' => true
			],
			binds: [
				// controls
				'meuns' => menus,
				'fullscreen' => [F11, null],
				'volume' => volume
			]
		}
	}

	public static function init():Void {
		if (!initialized || theSave == null) {
			theSave = new FlxSave();
			theSave.bind('options');
			// theSave.data.modOptions = theSave.data.options = theSave.data.binds = null;
			modOptionsMap = theSave.data.modOptions = theSave.data.modOptions == null ? new Map<String, Dynamic>() : theSave.data.modOptions;
			optionsMap = theSave.data.options = theSave.data.options == null ? loadDefault() : theSave.data.options;
			bindsStorage = theSave.data.binds = theSave.data.binds == null ? {
				menus: [
					[A, S, W, D],
					[LEFT, DOWN, UP, RIGHT]
				],
				notes: [
					[D, F, K, L], // kl for life lmao
					[LEFT, DOWN, UP, RIGHT]
				],
			} : theSave.data.options;
			theSave.flush();
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