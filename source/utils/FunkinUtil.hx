package utils;

enum abstract MenuSFX(String) to String from String {
	var CONFIRM = 'confirm';
	var CANCEL = 'cancel';
	var SCROLL = 'scroll';
}

class FunkinUtil {
	inline public static function addMissingFolders(modFolderPath:String):Void {
		var folders:Array<String> = [
			'content',
			'content/difficulties',
			'content/events',
			'content/objects',
			'content/objects/characters',
			'content/objects/icons',
			'content/songs',
			'content/stages',
			'content/states',
			'fonts',
			'images',
			'music',
			'shaders',
			'sounds',
			'videos',
		];
		for (folder in folders)
			if (!Paths.folderExists(folder, false))
				FileSystem.createDirectory('$modFolderPath/$folder');
	}

	inline public static function playMenuSFX(sound:MenuSFX, volume:Float = 1, ?onComplete:()->Void):FlxSound {
		var menuSound:FlxSound = FlxG.sound.play(Paths.sound('menu/' + switch (sound) {
			case CONFIRM: 'confirm';
			case CANCEL: 'cancel';
			case SCROLL: 'scroll';
		}), volume, false, null, true, onComplete == null ? () -> {} : onComplete);
		menuSound.persist = true;
		return menuSound;
	}

	inline public static function mouseJustMoved(relativeToScreen:Bool = true):Bool {
		if (relativeToScreen)
			@:privateAccess return FlxG.mouse._prevScreenX != FlxG.mouse.screenX || FlxG.mouse._prevScreenY != FlxG.mouse.screenY;
		else
			return FlxG.mouse.justMoved;
	}

	public static function getSongFolderNames(sortOrderByLevel:Bool = true, pathType:FunkinPath = ANY):Array<String> {
		var results:Array<String> = [];
		try {
			if (sortOrderByLevel)
				for (name in Paths.readFolderOrderTxt('content/levels', 'json'))
					for (song in ParseUtil.level(name).songs)
						results.push(song.folder);
		} catch(e)
			trace('Missing level json.');
		for (folder in Paths.readFolder('content/songs', pathType))
			if (HaxePath.extension(folder) == '')
				if (!results.contains(folder))
					results.push(folder);
		return results;
	}

	inline public static function trimSplit(text:String):Array<String> {
		var daList:Array<String> = text.split('\n');
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
	}

	// Using CNE's because mine was a bitch to use.
	/**
	 * Returns `v` if not null, `defaultValue` otherwise.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return The return value
	 */
	public static inline function getDefault<T>(v:Null<T>, defaultValue:T):T
		return (v == null || isNaN(v)) ? defaultValue : v;
	/**
	 * Whenever a value is NaN or not.
	 * @param v Value
	 */
	public static inline function isNaN(v:Dynamic)
		if (v is Float || v is Int)
			return Math.isNaN(cast(v, Float));
		else return false;

	inline public static function getClassName(direct:Dynamic, provideFullPath:Bool = false):String {
		if (provideFullPath)
			return cast Type.getClassName(Type.getClass(direct));
		else {
			var path:Array<String> = Type.getClassName(Type.getClass(direct)).split('.');
			return cast path[path.length - 1];
		}
	}
}