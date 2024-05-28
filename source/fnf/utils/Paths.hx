package fnf.utils;

import flixel.graphics.frames.FlxAtlasFrames;
import sys.io.File;

enum abstract FunkinPath(String) {
	var SOLO = 'solo';
	var MODS = 'mods';
	var BOTH = null;
}

class Paths {
	public static final soundExts:Array<String> = ['wav', 'ogg'];

	public static final invaildChars:Array<String> = ['\\'/* , '/' */, ':', '*', '?', '"', '<', '>', '|'/* , '.' */];
	public static function removeInvaildChars(string:String):String {
		for (i in 0...invaildChars.length) string.replace(invaildChars[i], '');
		return removeInvaildChars(string);
	}

	inline public static function getPath(file:String, pathType:FunkinPath = BOTH):String {
		var path:String = 'assets/$file';
		return path;
	}

	inline public static function file(file:String, pathType:FunkinPath = BOTH) return getPath(file, pathType);

	inline public static function txt(key:String, pathType:FunkinPath = BOTH) return getPath('$key.txt', pathType);

	inline public static function xml(key:String, pathType:FunkinPath = BOTH) return getPath('$key.xml', pathType);

	inline public static function yaml(key:String, pathType:FunkinPath = BOTH) return getPath('$key.yaml', pathType);

	inline public static function json(key:String, pathType:FunkinPath = BOTH) return getPath('$key.json', pathType);

	public static function script(key:String, pathType:FunkinPath = BOTH) {
		var scriptPath = getPath(key, pathType);
		var path:String;
		for (ext in Script.exts) {
			path = '$scriptPath.$ext';
			if (FileSystem.exists(path)) {
				scriptPath = path;
				break;
			}
		}
		return scriptPath;
	}

	public static function audio(key:String, pathType:FunkinPath = BOTH) {
		var soundPath = getPath(key, pathType);
		var path:String;
		for (ext in soundExts) {
			path = '$soundPath.$ext';
			if (FileSystem.exists(path)) {
				soundPath = path;
				break;
			}
		}
		return soundPath;
	}

	inline public static function sound(key:String, pathType:FunkinPath = BOTH) return audio('sounds/$key', pathType);

	inline public static function soundRandom(key:String, min:Int, max:Int, pathType:FunkinPath = BOTH) return sound(key + FlxG.random.int(min, max), pathType);

	inline public static function music(key:String, pathType:FunkinPath = BOTH) return audio('music/$key', pathType);

	inline public static function inst(song:String, variant:String = '') return audio('songs/${song.replace('.', '')}/audio/${variant.trim() == '' ? '' : '$variant/'}Inst');

	inline public static function voices(song:String, suffix:String = '', variant:String = '') return audio('songs/${song.replace('.', '')}/audio/${variant.trim() == '' ? '' : '$variant/'}Voices${suffix.trim() == '' ? '' : '-$suffix'}');

	inline public static function image(key:String, pathType:FunkinPath = BOTH) return getPath('images/$key.png', pathType);

	inline public static function font(key:String, pathType:FunkinPath = BOTH) return getPath('fonts/$key', pathType);

	inline public static function getContent(file:String):String return FileSystem.exists(file) ? File.getContent(file) : '';

	inline public static function getSparrowAtlas(key:String, pathType:FunkinPath = BOTH) return FlxAtlasFrames.fromSparrow(image(key, pathType), xml('images/$key', pathType));

	inline public static function getPackerAtlas(key:String, pathType:FunkinPath = BOTH) return FlxAtlasFrames.fromSpriteSheetPacker(image(key, pathType), txt('images/$key', pathType));
}
