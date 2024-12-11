package imaginative.utils;

/**
 * Used for easy menu sound effect bullshit.
 */
enum abstract MenuSFX(String) from String to String {
	/**
	 * Confirm sound effect.
	 */
	var ConfirmSFX = 'confirm';
	/**
	 * Cancel sound effect.
	 */
	var CancelSFX = 'cancel';
	/**
	 * Scroll sound effect.
	 */
	var ScrollSFX = 'scroll';

	/**
	 * Play's a menu sound effect.
	 * @param volume The volume
	 * @param subFolder Sub folder path/name.
	 * @param onComplete FlxG.sound.play's onComplete function.
	 * @return `FlxSound` ~ The menu sound.
	 */
	public function playSFX(volume:Float = 1, ?subFolder:String, ?onComplete:Void->Void):FlxSound
		return FunkinUtil.playMenuSFX(this, volume, subFolder, onComplete);
}

/**
 * Utilities for this funkin engine.
 */
class FunkinUtil {
	/**
	 * Add's missing folders to your mod.
	 * If you realize certain folders don't show up, please tell me.
	 * @param path The path to the mod folder.
	 */
	@:noUsing inline public static function addMissingFolders(path:String):Void {
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
				FileSystem.createDirectory('$path/$folder');
	}

	/**
	 * Play's a menu sound effect.
	 * @param sound The sound.
	 * @param volume The volume
	 * @param subFolder Sub folder path/name.
	 * @param onComplete FlxG.sound.play's onComplete function.
	 * @return `FlxSound` ~ The menu sound.
	 */
	@:noUsing inline public static function playMenuSFX(sound:MenuSFX, volume:Float = 1, ?subFolder:String, ?onComplete:Void->Void):FlxSound {
		var menuSound:FlxSound = FlxG.sound.play(Paths.sound('menu${subFolder == null ? '' : '/$subFolder'}/$sound').format(), volume, onComplete ?? () -> {});
		menuSound.persist = true;
		return menuSound;
	}

	/**
	 * Get's the song folder names.
	 * @param sortOrderByLevel If true, it sort the songs via the order txt.
	 * @return `Array<String>`
	 */
	@:noUsing public static function getSongFolderNames(sortOrderByLevel:Bool = true):Array<String> {
		var results:Array<String> = [];
		try {
			if (sortOrderByLevel)
				for (name in Paths.readFolderOrderTxt('content/levels', 'json', false))
					for (song in ParseUtil.level(name).songs)
						results.push(song.folder);
		} catch(error:haxe.Exception)
			log('Missing level json.', WarningMessage);
		for (folder in Paths.readFolder('content/songs', false))
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
		return ParseUtil.difficulty(diff).display ?? diff;

	/**
	 * Returns the default variant of a difficulty
	 * @param diff The difficulty json name.
	 * @return `String` ~ The difficulties default variant.
	 */
	@:noUsing inline public static function getDifficultyVariant(diff:String):String {
		try {
			return ParseUtil.difficulty(diff).variant ?? 'normal';
		} catch(error:haxe.Exception)
			return 'normal';
	}

	/**
	 * Is basically an array's split function but each array slot is trimmed.
	 * @param text The string to split.
	 * @param delimiter The splitter key.
	 * @return `Array<String>` ~ Trimmed array.
	 */
	inline public static function trimSplit(text:String, delimiter:String):Array<String> {
		var daList:Array<String> = text.split(delimiter);
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
	}

	/**
	 * Uses the arguments value and max to create a number that ranges the argument range. ex: toPercent(4, 10, 1) returns 0.4
	 * @param value The current value of the percentage. ex: 4
	 * @param max The max value of the the percentage. ex: 10
	 * @param range The format of the percentage. ex: 1
	 * @return `Float` ~ The percentage. ex: 0.4
	 */
	inline public static function toPercent(value:Float, max:Float, range:Float = 1):Float {
		return (value / max) * range;
	}
	/**
	 * Uses the arguments percent and max to create a number that ranges the argument range. ex: undoPercent(0.4, 10, 1) returns 4
	 * @param percent The current percentage of the value. ex: 0.4
	 * @param max The max percentage of the the value. ex: 10
	 * @param range The format of the value. ex: 1
	 * @return `Float` ~ The value. ex: 4
	 */
	inline public static function undoPercent(percent:Float, max:Float, range:Float = 100):Float {
		return (percent * max) / range;
	}
}