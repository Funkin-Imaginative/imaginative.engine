package utils;

typedef ObjectsTyping = {
	var object:String;
	@:optional var flip:Bool;
	@:optional var offsets:PositionStruct;
}
typedef LevelParse = {
	var title:String;
	var songs:Array<String>;
	@:optional var startingDiff:Int;
	var difficulties:Array<String>;
	var objects:Array<ObjectsTyping>;
	@:optional var color:String;
}
typedef LevelData = {
	var title:String;
	var songs:Array<SongData>;
	@:optional public var startingDiff:Int;
	var difficulties:Array<String>;
	var objects:Array<ObjectsTyping>;
	var color:FlxColor;
}

typedef AllowedModesTyping = {
	var playAsEnemy:Bool;
	var p2AsEnemy:Bool;
}
typedef SongParse = {
	var folder:String;
	var icon:String;
	@:optional var startingDiff:Int;
	var difficulties:Array<String>;
	@:optional var color:String;
	var allowedModes:AllowedModesTyping;
}
typedef SongData = {
	var name:String;
	var folder:String;
	var icon:String;
	var startingDiff:Int;
	var difficulties:Array<String>;
	var color:FlxColor;
	var allowedModes:AllowedModesTyping;
}

typedef DifficultyData = {
	var display:String;
	@:optional var variant:Null<String>;
	@:optional var scoreMult:Float;
}

class ParseUtil {
	inline public static function json(path:String, pathType:FunkinPath = ANY):Dynamic
		return haxe.Json.parse(Paths.getFileContent(Paths.json(path, pathType)));

	inline public static function difficulty(name:String, pathType:FunkinPath = ANY):DifficultyData {
		var contents:DifficultyData = json('content/difficulties/$name', pathType);
		return {
			display: contents.display,
			variant: contents.variant,
			scoreMult: FunkinUtil.getDefault(contents.scoreMult, 1),
		}
	}

	inline public static function level(name:String, pathType:FunkinPath = ANY):LevelData {
		var contents:LevelParse = json('content/levels/$name', pathType);
		for (i => data in contents.objects) {
			data.flip = FunkinUtil.getDefault(data.flip, (i + 1) > Math.floor(contents.objects.length / 2));
			data.offsets = FunkinUtil.getDefault(data.offsets, {x: 0, y: 0});
		}
		return cast {
			title: contents.title,
			songs: [for (s in contents.songs) song(s, pathType)],
			startingDiff: FunkinUtil.getDefault(contents.startingDiff, Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (d in contents.difficulties) d.toLowerCase()], // jic
			objects: contents.objects,
			color: FlxColor.fromString(contents.color), // 0xfff9cf51
		}
	}

	inline public static function song(name:String, pathType:FunkinPath = ANY):SongData {
		var contents:SongParse = json('content/songs/$name/meta', pathType);
		return {
			name: json('content/songs/$name/audio', pathType).name,
			folder: contents.folder,
			icon: contents.icon,
			startingDiff: FunkinUtil.getDefault(contents.startingDiff, Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (d in contents.difficulties) d.toLowerCase()], // jic
			color: FlxColor.fromString(contents.color),
			allowedModes: contents.allowedModes
		}
	}
}