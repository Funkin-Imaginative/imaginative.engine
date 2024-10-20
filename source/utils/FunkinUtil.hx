package utils;

enum abstract MenuSFX(String) from String to String {
	var ConfirmSFX = 'confirm';
	var CancelSFX = 'cancel';
	var ScrollSFX = 'scroll';

	public function playSFX(volume:Float = 1, ?onComplete:Void->Void):FlxSound
		return FunkinUtil.playMenuSFX(this, volume, onComplete);
}

class FunkinUtil {
	@:noUsing inline public static function addMissingFolders(folderPath:String):Void {
		final folders:Array<String> = [
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
				FileSystem.createDirectory('$folderPath/$folder');
	}

	@:noUsing inline public static function playMenuSFX(sound:MenuSFX, volume:Float = 1, ?onComplete:Void->Void):FlxSound {
		var menuSound:FlxSound = FlxG.sound.play(Paths.sound('menu/$sound'), volume, onComplete.getDefault(() -> {}));
		menuSound.persist = true;
		return menuSound;
	}

	@:noUsing public static function getSongFolderNames(sortOrderByLevel:Bool = true, pathType:FunkinPath = ANY):Array<String> {
		var results:Array<String> = [];
		try {
			if (sortOrderByLevel)
				for (name in Paths.readFolderOrderTxt('content/levels', 'json'))
					for (song in ParseUtil.level(name).songs)
						results.push(song.folder);
		} catch(error:haxe.Exception)
			trace('Missing level json.');
		for (folder in Paths.readFolder('content/songs', pathType))
			if (FilePath.extension(folder) == '')
				if (!results.contains(folder))
					results.push(folder);
		return results;
	}

	/**
	 * Returns the song display name.
	 * @param name The song folder name.
	 * @return `String` ~ The songs display name.
	 */
	@:noUsing public static function getSongDisplay(name:String):String
		return ParseUtil.song(name).name;

	/**
	 * Returns the difficulty display name.
	 * @param diff The difficulty json name.
	 * @return `String` ~ The difficulties display name.
	 */
	@:noUsing inline public static function getDifficultyDisplay(diff:String):String
		return ParseUtil.difficulty(diff).display;

	/**
	 * Returns the default variant of a difficulty
	 * @param diff The difficulty json name.
	 * @return `String` ~ The difficulties default variant.
	 */
	@:noUsing inline public static function getDifficultyVariant(diff:String):String
		return ParseUtil.difficulty(diff).variant;

	inline public static function trimSplit(text:String, delimiter:String):Array<String> {
		var daList:Array<String> = text.split(delimiter);
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
	}

	/**
	 * It's like `getDefault` but it uses `Reflect` but it only supports structures.
	 * @param v
	 * @param defaultValue
	 * @return `T`
	 */
	inline public static function reflectDefault<T>(data:Dynamic, field:String, defaultValue:T):T
		return Reflect.hasField(data, field) ? Reflect.getProperty(data, field).getDefault(defaultValue) : defaultValue;

	// Using CNE's because mine was a bitch to use.
	/**
	 * Returns `v` if not null, `defaultValue` otherwise.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return `T`
	 * @author @FNF-CNE-Devs
	 */
	inline public static function getDefault<T>(v:Null<T>, defaultValue:T):T
		return (v == null || isNaN(v)) ? defaultValue : v;
	/**
	 * Whenever a value is NaN or not.
	 * @param v Value
	 * @return `Bool`
	 * @author @FNF-CNE-Devs
	 */
	@:noUsing inline public static function isNaN(v:Dynamic):Bool
		if (v is Float || v is Int)
			return Math.isNaN(cast(v, Float));
		else return false;
}