package fnf.utils;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Paths {
	public static var SOUND_EXT:String = 'ogg'; // want to add wav support because yes

	static var currentLevel:String;

	public static function setCurrentLevel(name:String) currentLevel = name.toLowerCase();

	public static function getPath(file:String, type:AssetType, library:Null<String>) {
		if (library != null) return getLibraryPath(file, library);

		if (currentLevel != null) {
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	inline public static function getLibraryPath(file:String, library = "preload")
		return if (library == "preload" || library == "default")
			getPreloadPath(file);
		else getLibraryPathForce(file, library);

	inline static function getLibraryPathForce(file:String, library:String) return '$library:assets/$library/$file';

	inline static function getPreloadPath(file:String) return 'assets/$file';

	inline public static function file(file:String, type:AssetType = TEXT, ?library:String) return getPath(file, type, library);

	inline public static function txt(key:String, ?library:String) return getPath('data/$key.txt', TEXT, library);

	inline public static function xml(key:String, ?library:String) return getPath('data/$key.xml', TEXT, library);

	inline public static function yaml(key:String, ?library:String) return getPath('data/$key.yaml', TEXT, library);

	inline public static function json(key:String, ?library:String) return getPath('data/$key.json', TEXT, library);

	inline public static function script(key:String, ?library:String) {
		var scriptPath = getPath(key, TEXT, library);
		var p:String;
		for (ext in Script.exts) {
			p = '$scriptPath.$ext';
			if (FileSystem.exists(p)) {
				scriptPath = p;
				break;
			}
		}
		return scriptPath;
	}

	inline public static function sound(key:String, ?library:String) return getPath('sounds/$key.$SOUND_EXT', SOUND, library);

	inline public static function soundRandom(key:String, min:Int, max:Int, ?library:String) return sound(key + FlxG.random.int(min, max), library);

	inline public static function music(key:String, ?library:String) return getPath('music/$key.$SOUND_EXT', MUSIC, library);

	inline public static function voices(song:String) return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';

	inline public static function inst(song:String) return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';

	inline public static function image(key:String, ?library:String) return getPath('images/$key.png', IMAGE, library);

	inline public static function font(key:String) return 'assets/fonts/$key';

	inline public static function getContent(file:String):String return FileSystem.exists(file) ? File.getContent(file) : '';

	inline public static function getSparrowAtlas(key:String, ?library:String) return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));

	inline public static function getPackerAtlas(key:String, ?library:String) return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
}
