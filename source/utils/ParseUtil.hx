package utils;

import utils.SpriteUtil.ObjectType;
import utils.SpriteUtil.CharacterSpriteData;
import utils.SpriteUtil.BeatSpriteData;
import utils.SpriteUtil.SpriteData;
import objects.DifficultyObject.DifficultyData;
import objects.LevelObject.LevelParse;
import objects.LevelObject.LevelData;

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

typedef ExtraData = {
	var name:String;
	var data:Dynamic;
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

	inline public static function object(path:String, pathType:FunkinPath = ANY):OneOfThree<SpriteData, BeatSpriteData, CharacterSpriteData> {
		var tempData:Dynamic = json('content/objects/$path', pathType);
		var type:ObjectType = BASE;
		if (Reflect.hasField(tempData, 'beat')) type = BEAT;
		if (Reflect.hasField(tempData, 'character')) type = CHARACTER;
		var data:OneOfThree<SpriteData, BeatSpriteData, CharacterSpriteData> = json('content/objects/$path', pathType);
		/* var charData:objects.sprites.Character.CharacterData = {
			camera: {x: data.character.camera.x, y: data.character.camera.y},
			color: FlxColor.fromString(data.character.color),
			icon: data.character.icon,
			singlength: data.character.singlength
		};
		var beatData:objects.sprites.BeatSprite.BeatData = {
			invertal: data.beat.invertal,
			skipnegative: data.beat.skipnegative
		};
		var objData:objects.sprites.BaseSprite.ObjectData = {
			asset: {image: data.asset.image, type: data.asset.type},
			animations: data.animations,
			antialiasing: data.antialiasing,
			flip: {x: data.flip.x, y: data.flip.y},
			scale: {x: data.scale.x, y: data.scale.y}
		}; */
		return cast {

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