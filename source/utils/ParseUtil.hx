package utils;

import utils.SpriteUtil.TypeSpriteData;
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

	inline public static function object(path:String, type:ObjectType = BASE, pathType:FunkinPath = ANY):TypeSpriteData {
		var data:Dynamic = json('content/objects/$path', pathType);

		switch (type) {
			case CHARACTER:
				var gottenData:objects.sprites.Character.CharacterParse;
				var typeData:CharacterSpriteData = json('content/objects/$path', pathType);
				try {
					gottenData = json('content/objects/$path', pathType).character;
					typeData.character.color = FlxColor.fromString(FunkinUtil.getDefault(gottenData.color, '#8000ff'));
				} catch(e) trace(e);
				data = {
					character: {
						camera: {x: FunkinUtil.getDefault(typeData.character.camera.x, 0), y: FunkinUtil.getDefault(typeData.character.camera.y, 0)},
						color: typeData.character.color,
						icon: FunkinUtil.getDefault(typeData.character.icon, 'face'),
						singlength: FunkinUtil.getDefault(typeData.character.singlength, 0)
					},
					beat: {
						invertal: FunkinUtil.getDefault(typeData.beat.invertal, 0),
						skipnegative: FunkinUtil.getDefault(typeData.beat.skipnegative, false)
					},
					offsets: {
						position: {x: FunkinUtil.getDefault(typeData.offsets.position.x, 0), y: FunkinUtil.getDefault(typeData.offsets.position.y, 0)},
						flip: {x: FunkinUtil.getDefault(typeData.offsets.flip.x, false), y: FunkinUtil.getDefault(typeData.offsets.flip.y, false)},
						scale: {x: FunkinUtil.getDefault(typeData.offsets.scale.x, 0), y: FunkinUtil.getDefault(typeData.offsets.scale.y, 0)}
					},
					asset: typeData.asset,
					animations: [
						for (anim in typeData.animations) {
							asset: FunkinUtil.getDefault(anim.asset, typeData.asset),
							name: anim.name,
							tag: FunkinUtil.getDefault(anim.tag, anim.name),
							dimensions: {x: FunkinUtil.getDefault(anim.dimensions.x, 0), y: FunkinUtil.getDefault(anim.dimensions.y, 0)},
							indices: FunkinUtil.getDefault(anim.indices, []),
							offset: {x: FunkinUtil.getDefault(anim.offset.x, 0), y: FunkinUtil.getDefault(anim.offset.y, 0)},
							flip: {x: FunkinUtil.getDefault(anim.flip.x, false), y: FunkinUtil.getDefault(anim.flip.y, false)},
							loop: FunkinUtil.getDefault(anim.loop, false),
							fps: FunkinUtil.getDefault(anim.fps, 24)
						}
					],
					position: {x: FunkinUtil.getDefault(typeData.position.x, 0), y: FunkinUtil.getDefault(typeData.position.y, 0)},
					flip: {x: FunkinUtil.getDefault(typeData.flip.x, false), y: FunkinUtil.getDefault(typeData.flip.y, false)},
					scale: {x: FunkinUtil.getDefault(typeData.scale.x, 0), y: FunkinUtil.getDefault(typeData.scale.y, 0)},
					antialiasing: FunkinUtil.getDefault(typeData.antialiasing, true)
				}
			case BEAT:
				var typeData:BeatSpriteData = json('content/objects/$path', pathType);
				data = {
					beat: {
						invertal: FunkinUtil.getDefault(typeData.beat.invertal, 0),
						skipnegative: FunkinUtil.getDefault(typeData.beat.skipnegative, false)
					},
					offsets: {
						position: {x: FunkinUtil.getDefault(typeData.offsets.position.x, 0), y: FunkinUtil.getDefault(typeData.offsets.position.y, 0)},
						flip: {x: FunkinUtil.getDefault(typeData.offsets.flip.x, false), y: FunkinUtil.getDefault(typeData.offsets.flip.y, false)},
						scale: {x: FunkinUtil.getDefault(typeData.offsets.scale.x, 0), y: FunkinUtil.getDefault(typeData.offsets.scale.y, 0)}
					},
					asset: typeData.asset,
					animations: [
						for (anim in typeData.animations) {
							asset: FunkinUtil.getDefault(anim.asset, typeData.asset),
							name: anim.name,
							tag: FunkinUtil.getDefault(anim.tag, anim.name),
							dimensions: {x: FunkinUtil.getDefault(anim.dimensions.x, 0), y: FunkinUtil.getDefault(anim.dimensions.y, 0)},
							indices: FunkinUtil.getDefault(anim.indices, []),
							offset: {x: FunkinUtil.getDefault(anim.offset.x, 0), y: FunkinUtil.getDefault(anim.offset.y, 0)},
							flip: {x: FunkinUtil.getDefault(anim.flip.x, false), y: FunkinUtil.getDefault(anim.flip.y, false)},
							loop: FunkinUtil.getDefault(anim.loop, false),
							fps: FunkinUtil.getDefault(anim.fps, 24)
						}
					],
					position: {x: FunkinUtil.getDefault(typeData.position.x, 0), y: FunkinUtil.getDefault(typeData.position.y, 0)},
					flip: {x: FunkinUtil.getDefault(typeData.flip.x, false), y: FunkinUtil.getDefault(typeData.flip.y, false)},
					scale: {x: FunkinUtil.getDefault(typeData.scale.x, 0), y: FunkinUtil.getDefault(typeData.scale.y, 0)},
					antialiasing: FunkinUtil.getDefault(typeData.antialiasing, true)
				}
			case BASE:
				var typeData:SpriteData = json('content/objects/$path', pathType);
				data = {
					offsets: {
						position: {x: FunkinUtil.getDefault(typeData.offsets.position.x, 0), y: FunkinUtil.getDefault(typeData.offsets.position.y, 0)},
						flip: {x: FunkinUtil.getDefault(typeData.offsets.flip.x, false), y: FunkinUtil.getDefault(typeData.offsets.flip.y, false)},
						scale: {x: FunkinUtil.getDefault(typeData.offsets.scale.x, 0), y: FunkinUtil.getDefault(typeData.offsets.scale.y, 0)}
					},
					asset: typeData.asset,
					animations: [
						for (anim in typeData.animations) {
							asset: FunkinUtil.getDefault(anim.asset, typeData.asset),
							name: anim.name,
							tag: FunkinUtil.getDefault(anim.tag, anim.name),
							dimensions: {x: FunkinUtil.getDefault(anim.dimensions.x, 0), y: FunkinUtil.getDefault(anim.dimensions.y, 0)},
							indices: FunkinUtil.getDefault(anim.indices, []),
							offset: {x: FunkinUtil.getDefault(anim.offset.x, 0), y: FunkinUtil.getDefault(anim.offset.y, 0)},
							flip: {x: FunkinUtil.getDefault(anim.flip.x, false), y: FunkinUtil.getDefault(anim.flip.y, false)},
							loop: FunkinUtil.getDefault(anim.loop, false),
							fps: FunkinUtil.getDefault(anim.fps, 24)
						}
					],
					position: {x: FunkinUtil.getDefault(typeData.position.x, 0), y: FunkinUtil.getDefault(typeData.position.y, 0)},
					flip: {x: FunkinUtil.getDefault(typeData.flip.x, false), y: FunkinUtil.getDefault(typeData.flip.y, false)},
					scale: {x: FunkinUtil.getDefault(typeData.scale.x, 0), y: FunkinUtil.getDefault(typeData.scale.y, 0)},
					antialiasing: FunkinUtil.getDefault(typeData.antialiasing, true)
				}
		}

		return data;
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