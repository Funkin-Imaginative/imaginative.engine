package utils;

typedef AllowedModesTyping = {
	var playAsEnemy:Bool;
	var p2AsEnemy:Bool;
}
typedef SongParse = {
	var folder:String;
	var icon:String;
	@:optional var startingDiff:Int;
	var difficulties:Array<String>;
	@:optional var variants:Array<String>;
	@:optional var color:String;
	var allowedModes:AllowedModesTyping;
}
typedef SongData = {
	var name:String;
	var folder:String;
	var icon:String;
	var startingDiff:Int;
	var difficulties:Array<String>;
	var variants:Array<String>;
	var color:FlxColor;
	var allowedModes:AllowedModesTyping;
}

typedef ExtraData = {
	var name:String;
	var data:Dynamic;
}

class ParseUtil {
	public static function json(path:String, pathType:FunkinPath = ANY):Dynamic {
		var content = {}
		try { content = haxe.Json.parse(Paths.getFileContent(Paths.json(path, pathType))); }
		catch(e) trace(e);
		return content;
	}

	public static function difficulty(name:String, pathType:FunkinPath = ANY):DifficultyObject.DifficultyData {
		final contents:DifficultyObject.DifficultyData = json('content/difficulties/$name', pathType);
		return {
			display: contents.display,
			variant: FunkinUtil.getDefault(contents.variant, 'normal'),
			scoreMult: FunkinUtil.getDefault(contents.scoreMult, 1),
		}
	}

	public static function level(name:String, pathType:FunkinPath = ANY):LevelObject.LevelData {
		var contents:LevelObject.LevelParse = json('content/levels/$name', pathType);
		for (i => data in contents.objects) {
			data.flip = FunkinUtil.getDefault(data.flip, (i + 1) > Math.floor(contents.objects.length / 2));
			data.offsets = FunkinUtil.getDefault(data.offsets, {x: 0, y: 0});
		}
		return cast {
			title: contents.title,
			songs: [for (s in contents.songs) song(s, pathType)],
			startingDiff: FunkinUtil.getDefault(contents.startingDiff, Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (d in contents.difficulties) d.toLowerCase()], // jic
			variants: [for (v in FunkinUtil.getDefault(contents.variants, [for (d in contents.difficulties) FunkinUtil.getDifficultyVariant(d)])) v.toLowerCase()],
			objects: contents.objects,
			color: FlxColor.fromString(contents.color), // 0xfff9cf51
		}
	}

	public static function object(path:String, pathType:FunkinPath = ANY):SpriteUtil.TypeSpriteData {
		final parse:Void->Dynamic = () -> return json('content/objects/$path', pathType);
		final tempData:Dynamic = parse();

		var charData:Character.CharacterData = null;
		if (Reflect.hasField(tempData, 'character')) {
			var gottenData:Character.CharacterParse = null;
			var typeData:SpriteUtil.CharacterSpriteData = cast parse();
			try {
				gottenData = cast parse().character;
				typeData.character.color = FlxColor.fromString(FunkinUtil.getDefault(gottenData.color, '#8000ff'));
			} catch(e) trace(e);
			charData = {
				camera: {x: FunkinUtil.getDefault(typeData.character.camera.x, 0), y: FunkinUtil.getDefault(typeData.character.camera.y, 0)},
				color: typeData.character.color,
				icon: FunkinUtil.getDefault(typeData.character.icon, 'face'),
				singlength: FunkinUtil.getDefault(typeData.character.singlength, 4)
			}
		}

		var beatData:BeatSprite.BeatData = null;
		if (Reflect.hasField(tempData, 'beat')) {
			var typeData:BeatSprite.BeatData = cast parse().beat;
			beatData = {
				invertal: FunkinUtil.getDefault(typeData.invertal, 0),
				skipnegative: FunkinUtil.getDefault(typeData.skipnegative, false)
			}
		}

		final typeData:SpriteUtil.SpriteData = cast tempData;

		var data:Dynamic = {}
		if (Reflect.hasField(typeData, 'offsets')) {
			try {
				data.offsets = {
					position: {x: FunkinUtil.getDefault(typeData.offsets.position.x, 0), y: FunkinUtil.getDefault(typeData.offsets.position.y, 0)},
					flip: {x: FunkinUtil.getDefault(typeData.offsets.flip.x, false), y: FunkinUtil.getDefault(typeData.offsets.flip.y, false)},
					scale: {x: FunkinUtil.getDefault(typeData.offsets.scale.x, 0), y: FunkinUtil.getDefault(typeData.offsets.scale.y, 0)}
				}
			} catch(e) {
				trace('offsets were fucked');
				data.offsets = {
					position: {x: 0, y: 0},
					flip: {x: false, y: false},
					scale: {x: 0, y: 0}
				}
			}
		} else {
			data.offsets = {
				position: {x: 0, y: 0},
				flip: {x: false, y: false},
				scale: {x: 0, y: 0}
			}
		}
		data.asset = typeData.asset;
		data.animations = [];
		for (anim in typeData.animations) {
			var slot:Dynamic = {};
			slot.asset = Reflect.hasField(anim, 'asset') ? FunkinUtil.getDefault(anim.asset, data.asset) : data.asset;
			slot.name = anim.name;
			if (Reflect.hasField(anim, 'tag')) slot.tag = FunkinUtil.getDefault(anim.tag, slot.name);
			if (Reflect.hasField(anim, 'dimensions')) slot.dimensions = {x: FunkinUtil.getDefault(anim.dimensions.x, 0), y: FunkinUtil.getDefault(anim.dimensions.y, 0)}
			slot.indices = FunkinUtil.getDefault(anim.indices, []);
			slot.offset = FunkinUtil.getDefault(anim.offset, new PositionStruct());
			slot.flip = FunkinUtil.getDefault(anim.flip, new PositionStruct.TypeXY<Bool>(false, false));
			slot.loop = FunkinUtil.getDefault(anim.loop, false);
			slot.fps = FunkinUtil.getDefault(anim.fps, 24);
			data.animations.push(slot);
		}
		if (Reflect.hasField(typeData, 'position'))
			try {
				data.position = {x: typeData.position.x, y: typeData.position.y}
			} catch(e) {
				trace('position got fucked');
				data.position = {x: null, y: null}
			}
		else
			data.position = {x: null, y: null}
		if (Reflect.hasField(typeData, 'flip'))
			try {
				data.flip = {x: typeData.flip.x, y: typeData.flip.y}
			} catch(e) {
				trace('flip got fucked');
				data.flip = {x: null, y: null}
			}
		else
			data.flip = {x: null, y: null}
		if (Reflect.hasField(typeData, 'scale'))
			try {
				data.scale = {x: typeData.scale.x, y: typeData.scale.y}
			} catch(e) {
				trace('scale got fucked');
				data.scale = {x: null, y: null}
			}
		else
			data.scale = {x: null, y: null}
		data.antialiasing = FunkinUtil.getDefault(typeData.antialiasing, true);

		if (charData != null) data.character = charData;
		if (beatData != null) data.beat = beatData;

		return data;
	}

	public static function song(name:String, pathType:FunkinPath = ANY):SongData {
		final contents:SongParse = json('content/songs/$name/meta', pathType);
		return {
			name: json('content/songs/$name/audio', pathType).name,
			folder: contents.folder,
			icon: contents.icon,
			startingDiff: FunkinUtil.getDefault(contents.startingDiff, Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (d in contents.difficulties) d.toLowerCase()], // jic
			variants: [for (v in FunkinUtil.getDefault(contents.variants, [for (d in contents.difficulties) FunkinUtil.getDifficultyVariant(d)])) v.toLowerCase()],
			color: FlxColor.fromString(contents.color),
			allowedModes: contents.allowedModes
		}
	}
}