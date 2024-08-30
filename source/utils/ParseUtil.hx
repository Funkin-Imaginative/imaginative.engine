package utils;

typedef LevelSection = {
	var title:String;
	var songs:Array<String>;
	var startingDiff:Int;
	var difficulties:Array<String>;
	var objects:Array<String>;
	var color:String;
}
typedef LevelData = {
	var title:String;
	var songs:Array<String>;
	var startingDiff:Int;
	var difficulties:Array<String>;
	var objects:Array<String>;
	var color:FlxColor;
}
typedef DifficultyData = {
	var display:String;
	var variant:Null<String>;
	var scoreMult:Float;
}

class ParseUtil {
	inline public static function json(path:String, ?pathType:FunkinPath):Dynamic
		return haxe.Json.parse(Paths.getFileContent(Paths.json(path, pathType)));

	inline public static function difficulty(name:String, ?pathType:FunkinPath):DifficultyData
		return cast json('content/difficulties/$name', pathType);

	inline public static function level(name:String, ?pathType:FunkinPath):LevelData {
		var contents:LevelSection = json('content/levels/$name', pathType);
		return cast {
			title: contents.title,
			songs: contents.songs,
			startingDiff: contents.startingDiff,
			difficulties: [for (d in contents.difficulties) d.toLowerCase()],
			objects: contents.objects,
			color: FlxColor.fromString(contents.color),
		}
	}
}