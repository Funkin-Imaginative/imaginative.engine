package utils;

enum abstract MenuSFX(String) to String from String {
	var CONFIRM = 'confirm';
	var CANCEL = 'cancel';
	var SCROLL = 'scroll';
}

class CoolUtil {
	inline public static function getAsset(path:String, type:String = 'image', pathType:FunkinPath = ANY):String {
		return switch (type) {
			case 'txt': Paths.txt(path, pathType);
			case 'xml': Paths.xml(path, pathType);
			case 'json': Paths.json(path, pathType);
			default: Paths.image(path, pathType);
		}
	}

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

	inline public static function playMenuSFX(sound:MenuSFX, volume:Float = 1, ?onComplete:Void->Void):FlxSound {
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
		for (folder in Paths.readFolder('content/songs', pathType)) {
			if (haxe.io.Path.extension(folder) == '')
				if (!results.contains(folder))
					results.push(folder);
		}
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

	inline public static function getDominantColor(sprite:FlxSprite):FlxColor {
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth) {
			for (row in 0...sprite.frameHeight) {
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0) {
					if (countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for (key in countByColor.keys()) {
			if (countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor = [];
		return FlxColor.fromInt(maxKey);
	}

	inline public static function getClassName(direct:Dynamic, provideFullPath:Bool = false):String {
		if (provideFullPath)
			return cast Type.getClassName(Type.getClass(direct));
		else {
			var path:Array<String> = Type.getClassName(Type.getClass(direct)).split('.');
			return cast path[path.length - 1];
		}
	}

	/**
	 * Is basically FlxTypedGroup.resolveGroup().
	 * @param obj
	 * @return FlxGroup
	 */
	inline public static function getGroup(obj:FlxBasic):FlxGroup {
		var resolvedGroup:FlxGroup = @:privateAccess FlxTypedGroup.resolveGroup(obj);
		if (resolvedGroup == null)
			resolvedGroup = FlxG.state.persistentUpdate ? FlxG.state : FlxG.state.subState;
		return resolvedGroup;
	}

	inline public static function addInfrontOf(obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup):Void {
		final group:FlxGroup = into == null ? getGroup(obj) : into;
		group.insert(group.members.indexOf(fromThis) + 1, obj);
	}

	inline public static function addBehind(obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup):Void {
		final group:FlxGroup = into == null ? getGroup(obj) : into;
		group.insert(group.members.indexOf(fromThis), obj);
	}
}