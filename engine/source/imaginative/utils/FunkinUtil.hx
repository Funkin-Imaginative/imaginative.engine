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
}

/**
 * Utilities for this funkin engine.
 */
class FunkinUtil {
	/**
	 * Adds missing folders to your mod.
	 * If you realize certain folders don't show up, please tell me.
	 * @param path The path to the mod folder.
	 */
	@:noUsing inline public static function addMissingFolders(path:String):Void {
		var folders:Array<String> = [
			// content
				'content/difficulties',
				'content/events',
				'content/levels',
				// objects
					'content/objects/characters',
					'content/objects/icons',
				'content/scripts',
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
			if (!Paths.folderExists('root:$path/$folder'))
				FileSystem.createDirectory('$path/$folder');
	}

	/**
	 * Plays a menu sound effect.
	 * @param sound The sound.
	 * @param volume The volume.
	 * @param subFolder Sub folder path/name.
	 * @param onComplete "FlxG.sound.play"s onComplete function.
	 * @return FlxSound ~ The menu sound.
	 */
	@:noUsing inline public static function playMenuSFX(sound:MenuSFX, volume:Float = 1, ?subFolder:String, ?onComplete:Void->Void):FlxSound {
		var menuSound:FlxSound = FlxG.sound.play(Assets.sound('menu${subFolder == null ? '' : '/$subFolder'}/$sound'), volume, onComplete);
		menuSound.persist = true;
		return menuSound;
	}

	/**
	 * Gets the song folder names.
	 * @param sortOrderByLevel If true it sort the songs via the order txt.
	 * @param pathType The mod path you want the function to look through.
	 * @return Array<ModPath>
	 */
	@:noUsing public static function getSongFolderNames(sortOrderByLevel:Bool = true, pathType:ModType = ANY):Array<ModPath> {
		// Level Grab
		var levels:Array<ModPath> = [];
		try {
			if (sortOrderByLevel)
				for (name in Paths.readFolderOrderTxt('$pathType:content/levels', 'json', false))
					for (song in ParseUtil.level(name).songs)
						levels.push('${name.type}:${song.folder}');
		} catch(error:haxe.Exception)
			log('Missing level json.', WarningMessage);
		for (file in levels)
			file.type = ModType.simplifyType(file, 'content/levels');

		// Song Grab
		var songs:Array<ModPath> = [];
		for (folder in Paths.readFolder('$pathType:content/songs', false))
			if (FilePath.extension(folder).isNullOrEmpty())
				songs.push(folder);
		for (file in songs)
			file.type = ModType.simplifyType(file, 'content/songs');

		// Results
		var results:Array<ModPath> = levels ?? []; // jic
		for (file in songs)
			if (!results.contains(file))
				results.push(file);
		return results;
	}

	/**
	 * Returns a clean displayed list for quickly tracing a list.
	 * @param list The list to convert.
	 * @return String ~ "a", "b" and "c"
	 */
	inline public static function cleanDisplayList(list:Array<String>):String {
		return '${[for (i => item in list) (i == (list.length - 2) && !list.empty()) ? '"$item" and' : '"$item"'].join(', ').replace('and,', 'and')}';
	}

	/**
	 * Returns the song display name.
	 * @param name The song folder name.
	 * @return String ~ The songs display name.
	 */
	@:noUsing inline public static function getSongDisplay(name:String):String
		return ParseUtil.song(name).name;
	/**
	 * Returns the difficulty display name.
	 * @param diff The difficulty json name.
	 * @return String ~ The difficulties display name.
	 */
	@:noUsing inline public static function getDifficultyDisplay(diff:String):String
		return ParseUtil.difficulty(diff).display ?? diff;
	/**
	 * Returns the default variant of a difficulty
	 * @param diff The difficulty json name.
	 * @return String ~ The difficulties default variant.
	 */
	@:noUsing inline public static function getDifficultyVariant(diff:String):String
		return ParseUtil.difficulty(diff).variant ?? 'normal';

	/**
	 * Is basically an array's split function but each array slot is trimmed.
	 * @param text The string to split.
	 * @param delimiter The splitter key.
	 * @return Array<String> ~ Trimmed array.
	 */
	inline public static function trimSplit(text:String, delimiter:String):Array<String> {
		var daList:Array<String> = text.split(delimiter);
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
	}

	/**
	 * Returns the linear interpolation of two numbers if ratio is between 0 and 1, and the linear extrapolation otherwise.
	 * @param a Number "A".
	 * @param b Number "B".
	 * @param ratio The amount of interpolation.
	 * @param fpsSensitive If true the ratio will be checked to run at the same speed, no matter the fps rate.
	 * @return Float ~ The result.
	 */
	@:noUsing inline public static function lerp(a:Float, b:Float, ratio:Float, fpsSensitive:Bool = true):Float
		return FlxMath.lerp(a, b, fpsSensitive ? getElapsedRatio(ratio) : ratio);
	/**
	 * Returns the linear interpolation of two colors if ratio is between 0 and 1, and the linear extrapolation otherwise.
	 * @param a Color "A".
	 * @param b Color "B".
	 * @param ratio The amount of interpolation.
	 * @param fpsSensitive If true the ratio will be checked to run at the same speed, no matter the fps rate.
	 * @return FlxColor ~ The result.
	 */
	@:noUsing inline public static function colorLerp(a:FlxColor, b:FlxColor, ratio:Float, fpsSensitive:Bool = true):FlxColor {
		return FlxColor.fromRGBFloat(
			lerp(a.redFloat, b.redFloat, ratio, fpsSensitive),
			lerp(a.greenFloat, b.greenFloat, ratio, fpsSensitive),
			lerp(a.blueFloat, b.blueFloat, ratio, fpsSensitive),
			lerp(a.alphaFloat, b.alphaFloat, ratio, fpsSensitive)
		);
	}
	/**
	 * Applies a ratio to a number.
	 * @param ratio The ratio.
	 * @param fps The FPS target to match. This argument is optional and is best left at 60.
	 * @return Float ~ The resulting ratio.
	 */
	@:noUsing inline public static function getElapsedRatio(ratio:Float, fps:Float = 60):Float
		return FlxMath.bound(ratio * fps * FlxG.elapsed, 0, 1);

	/**
	 * Uses the arguments value and max to create a number that ranges the argument range. ex: toPercent(4, 10, 1) returns 0.4
	 * @param value The current value of the percentage. ex: 4
	 * @param max The max value of the the percentage. ex: 10
	 * @param range The format of the percentage. ex: 1
	 * @return Float ~ The percentage. ex: 0.4
	 */
	@:noUsing inline public static function toPercent(value:Float, max:Float, range:Float = 1):Float {
		return (value / max) * range;
	}
	/**
	 * Uses the arguments percent and max to create a number that ranges the argument range. ex: undoPercent(0.4, 10, 1) returns 4
	 * @param percent The current percentage of the value. ex: 0.4
	 * @param max The max percentage of the the value. ex: 10
	 * @param range The format of the value. ex: 1
	 * @return Float ~ The value. ex: 4
	 */
	@:noUsing inline public static function undoPercent(percent:Float, max:Float, range:Float = 100):Float {
		return (percent * max) / range;
	}
}