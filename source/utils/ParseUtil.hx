package utils;

import json2object.JsonParser;

typedef AllowedModesTyping = {
	@:default(false) var playAsEnemy:Bool;
	@:default(false) var p2AsEnemy:Bool;
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
		catch(error:haxe.Exception) trace(error.message);
		return content;
	}

	public static function difficulty(name:String, pathType:FunkinPath = ANY):DifficultyData {
		// final contents:DifficultyData = new JsonParser<DifficultyData>().fromJson(Paths.getFileContent(Paths.json('content/difficulties/$name', pathType)), Paths.json('content/difficulties/$name', pathType));
		final contents:DifficultyData = json('content/difficulties/$name', pathType);
		return {
			display: contents.display,
			variant: FunkinUtil.getDefault(contents.variant, 'normal'),
			scoreMult: FunkinUtil.getDefault(contents.scoreMult, 1),
		}
	}

	public static function level(name:String, pathType:FunkinPath = ANY):LevelData {
		// var contents:LevelParse = new JsonParser<LevelParse>().fromJson(Paths.getFileContent(Paths.json('content/levels/$name', pathType)), Paths.json('content/levels/$name', pathType));
		var contents:LevelParse = json('content/levels/$name', pathType);
		for (i => data in contents.objects) {
			data.flip = FunkinUtil.reflectDefault(data, 'flip', (i + 1) > Math.floor(contents.objects.length / 2));
			data.offsets = FunkinUtil.reflectDefault(data, 'offsets', new PositionStruct());
			data.size = FunkinUtil.reflectDefault(data, 'size', 1);
			data.willHey = FunkinUtil.getDefault(data.willHey, i == Math.floor(contents.objects.length / 2));
		}
		return {
			name: name,
			title: contents.title,
			songs: [for (sog in contents.songs) song(sog, pathType)],
			startingDiff: FunkinUtil.getDefault(contents.startingDiff, Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (d in contents.difficulties) d.toLowerCase()], // jic
			variants: [for (v in FunkinUtil.getDefault(contents.variants, [for (d in contents.difficulties) FunkinUtil.getDifficultyVariant(d)])) v.toLowerCase()],
			objects: contents.objects,
			color: FlxColor.fromString(contents.color), // 0xfff9cf51
		}
	}

	public static function object(path:String, objType:ObjectType, pathType:FunkinPath = ANY):TypeSpriteData {
		// TODO: Get this shit to use json2object.
		// final parseSprite:Void->SpriteData = () -> return new JsonParser<SpriteData>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));
		// final parseBeat:Void->BeatSpriteData = () -> return new JsonParser<BeatSpriteData>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));
		// final parseChar:Void->CharacterSpriteData = () -> return new JsonParser<CharacterSpriteData>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));

		final parseSprite:Void->SpriteData = () -> return json('content/objects/$path', pathType);
		final parseBeat:Void->BeatSpriteData = () -> return json('content/objects/$path', pathType);
		final parseChar:Void->CharacterSpriteData = () -> return json('content/objects/$path', pathType);

		final tempData:Dynamic = json('content/objects/$path', pathType);

		var charData:CharacterData = null;
		if (objType.canBop && (objType == CHARACTER && Reflect.hasField(tempData, 'character'))) {
			var gottenData:CharacterParse = null;
			trace('parseChar ~ 1');
			var typeData:CharacterSpriteData = parseChar();
			trace('parseChar ~ 2');
			try {
				gottenData = new JsonParser<CharacterParse>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));
				typeData.character.color = FlxColor.fromString(FunkinUtil.getDefault(gottenData.color, '#8000ff'));
			} catch(error:haxe.Exception) trace(error.message);
			charData = {
				camera: FunkinUtil.getDefault(typeData.character.camera, new PositionStruct()),
				color: typeData.character.color,
				icon: FunkinUtil.getDefault(typeData.character.icon, 'face'),
				singlength: FunkinUtil.getDefault(typeData.character.singlength, 4)
			}
		}

		var beatData:BeatData = null;
		if (objType.canBop && Reflect.hasField(tempData, 'beat')) {
			trace('parseBeat ~ 1');
			var typeData:BeatData = parseBeat().beat;
			trace('parseBeat ~ 2');
			beatData = {
				invertal: FunkinUtil.getDefault(typeData.invertal, 0),
				skipnegative: FunkinUtil.getDefault(typeData.skipnegative, false)
			}
		}

		trace('parseSprite ~ 1');
		final typeData:SpriteData = parseSprite();
		trace('parseSprite ~ 2');

		var data:Dynamic = {}
		if (Reflect.hasField(typeData, 'offsets'))
			try {
				data.offsets = {
					position: FunkinUtil.getDefault(typeData.offsets.position, new PositionStruct()),
					flip: FunkinUtil.getDefault(typeData.offsets.flip, new TypeXY<Bool>(false, false)),
					scale: FunkinUtil.getDefault(typeData.offsets.scale, new PositionStruct())
				}
			} catch(error:haxe.Exception) {
				trace('offsets were fucked');
				data.offsets = {
					position: new PositionStruct(),
					flip: new TypeXY<Bool>(false, false),
					scale: new PositionStruct()
				}
			}
		else
			data.offsets = {
				position: new PositionStruct(),
				flip: new TypeXY<Bool>(false, false),
				scale: new PositionStruct()
			}
		data.asset = typeData.asset;
		data.animations = [];
		for (anim in typeData.animations) {
			var slot:AnimationTyping = cast {}
			slot.asset = FunkinUtil.reflectDefault(anim, 'asset', data.asset);
			slot.name = anim.name;
			if (Reflect.hasField(anim, 'tag')) slot.tag = FunkinUtil.getDefault(anim.tag, slot.name);
			if (Reflect.hasField(anim, 'dimensions')) slot.dimensions = FunkinUtil.getDefault(anim.dimensions, new TypeXY<Int>(0, 0));
			slot.indices = FunkinUtil.getDefault(anim.indices, []);
			slot.offset = FunkinUtil.getDefault(anim.offset, new PositionStruct());
			slot.flip = FunkinUtil.getDefault(anim.flip, new TypeXY<Bool>(false, false));
			slot.loop = FunkinUtil.getDefault(anim.loop, false);
			slot.fps = FunkinUtil.getDefault(anim.fps, 24);
			data.animations.push(slot);
		}
		if (Reflect.hasField(typeData, 'position'))
			try {
				data.position = new PositionStruct(typeData.position.x, typeData.position.y);
			}
		if (Reflect.hasField(typeData, 'flip'))
			try {
				data.flip = new TypeXY<Bool>(typeData.flip.x, typeData.flip.y);
			}
		if (Reflect.hasField(typeData, 'scale'))
			try {
				data.scale = new PositionStruct(typeData.scale.x, typeData.scale.y);
			}
		data.antialiasing = FunkinUtil.getDefault(typeData.antialiasing, true);

		if (charData != null) data.character = charData;
		if (beatData != null) data.beat = beatData;

		return data;
	}

	public static function song(name:String, pathType:FunkinPath = ANY):SongData {
		// final contents:SongParse = new JsonParser<SongParse>().fromJson(Paths.getFileContent(Paths.json('content/songs/$name/meta', pathType)), Paths.json('content/songs/$name/meta', pathType));
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