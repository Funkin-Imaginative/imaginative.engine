package utils;

import json2object.JsonParser;

typedef AllowedModesTyping = {
	/**
	 * If true, this song allows you to play as the enemy.
	 */
	@:default(false) var playAsEnemy:Bool;
	/**
	 * If true, this song allows you to go against another player.
	 */
	@:default(false) var p2AsEnemy:Bool;
}
@SuppressWarnings('checkstyle:FieldDocComment')
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
	/**
	 * The song display name.
	 */
	var name:String;
	/**
	 * The song folder name.
	 */
	var folder:String;
	/**
	 * The song icon.
	 */
	var icon:String;
	/**
	 * The starting difficulty.
	 */
	var startingDiff:Int;
	/**
	 * The difficulties listing.
	 */
	var difficulties:Array<String>;
	/**
	 * The variations listing.
	 */
	var variants:Array<String>;
	/**
	 * The song color.
	 */
	var color:FlxColor;
	/**
	 * Allowed modes for the song.
	 */
	var allowedModes:AllowedModesTyping;
}

typedef ExtraData = {
	/**
	 * Name of the data.
	 */
	var name:String;
	/**
	 * The data contents.
	 */
	var data:Dynamic;
}

/**
 * This util is for all your parsing needs.
 */
class ParseUtil {
	/**
	 * Parse's a json file.
	 * @param path The mod path.
	 * @param pathType The path type.
	 * @return `Dynamic` ~ The parsed json content.
	 */
	public static function json(path:String, pathType:FunkinPath = ANY):Dynamic {
		var content = {}
		try { content = haxe.Json.parse(Paths.getFileContent(Paths.json(path, pathType))); }
		catch(error:haxe.Exception) trace(error.message);
		return content;
	}

	/**
	 * Parse's difficulty json data.
	 * @param name The difficulty key.
	 * @param pathType The path type.
	 * @return `DifficultyData` ~ The parsed difficulty json content.
	 */
	public static function difficulty(name:String, pathType:FunkinPath = ANY):DifficultyData {
		// final contents:DifficultyData = new JsonParser<DifficultyData>().fromJson(Paths.getFileContent(Paths.json('content/difficulties/$name', pathType)), Paths.json('content/difficulties/$name', pathType));
		final contents:DifficultyData = json('content/difficulties/$name', pathType);
		return {
			display: contents.display,
			variant: contents.variant.getDefault('normal'),
			scoreMult: contents.scoreMult.getDefault(1),
		}
	}

	/**
	 * Parse's level json data.
	 * @param name The level key.
	 * @param pathType The path type.
	 * @return `LevelData` ~ The parsed level json content.
	 */
	public static function level(name:String, pathType:FunkinPath = ANY):LevelData {
		// var contents:LevelParse = new JsonParser<LevelParse>().fromJson(Paths.getFileContent(Paths.json('content/levels/$name', pathType)), Paths.json('content/levels/$name', pathType));
		var contents:LevelParse = json('content/levels/$name', pathType);
		for (i => data in contents.objects) {
			data.flip = data.reflectDefault('flip', (i + 1) > Math.floor(contents.objects.length / 2));
			data.offsets = data.reflectDefault('offsets', new PositionStruct());
			data.size = data.reflectDefault('size', 1);
			data.willHey = data.willHey.getDefault(i == Math.floor(contents.objects.length / 2));
		}
		return {
			name: name,
			title: contents.title,
			songs: [for (sog in contents.songs) song(sog, pathType)],
			startingDiff: contents.startingDiff.getDefault(Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (d in contents.difficulties) d.toLowerCase()], // jic
			variants: [for (v in contents.variants.getDefault([for (d in contents.difficulties) FunkinUtil.getDifficultyVariant(d)])) v.toLowerCase()],
			objects: contents.objects,
			color: FlxColor.fromString(contents.color), // 0xfff9cf51
		}
	}

	/**
	 * Parse's object json data.
	 * @param path The object json name.
	 * @param type The sprite type.
	 * @param pathType The path type.
	 * @return `TypeSpriteData` ~ The parsed object json content.
	 */
	public static function object(path:String, type:SpriteType, pathType:FunkinPath = ANY):TypeSpriteData {
		// TODO: Get this shit to use json2object.
		// final parseSprite:Void->SpriteData = () -> return new JsonParser<SpriteData>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));
		// final parseBeat:Void->BeatSpriteData = () -> return new JsonParser<BeatSpriteData>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));
		// final parseChar:Void->CharacterSpriteData = () -> return new JsonParser<CharacterSpriteData>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));

		final parseSprite:Void->SpriteData = () -> return json('content/objects/$path', pathType);
		final parseBeat:Void->BeatSpriteData = () -> return json('content/objects/$path', pathType);
		final parseChar:Void->CharacterSpriteData = () -> return json('content/objects/$path', pathType);

		final tempData:Dynamic = json('content/objects/$path', pathType);

		var charData:CharacterData = null;
		if (type.isBeatType && (type == isCharacterSprite && Reflect.hasField(tempData, 'character'))) {
			var gottenData:CharacterParse = null;
			trace('parseChar ~ 1');
			var typeData:CharacterSpriteData = parseChar();
			trace('parseChar ~ 2');
			try {
				gottenData = new JsonParser<CharacterParse>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));
				typeData.character.color = FlxColor.fromString(gottenData.color.getDefault('#8000ff'));
			} catch(error:haxe.Exception) trace(error.message);
			charData = {
				camera: typeData.character.camera.getDefault(new PositionStruct()),
				color: typeData.character.color,
				icon: typeData.character.icon.getDefault('face'),
				singlength: typeData.character.singlength.getDefault(4)
			}
		}

		var beatData:BeatData = null;
		if (type.isBeatType && Reflect.hasField(tempData, 'beat')) {
			trace('parseBeat ~ 1');
			var typeData:BeatData = parseBeat().beat;
			trace('parseBeat ~ 2');
			beatData = {
				invertal: typeData.invertal.getDefault(0),
				skipnegative: typeData.skipnegative.getDefault(false)
			}
		}

		trace('parseSprite ~ 1');
		final typeData:SpriteData = parseSprite();
		trace('parseSprite ~ 2');

		var data:Dynamic = {}
		if (Reflect.hasField(typeData, 'offsets'))
			try {
				data.offsets = {
					position: typeData.offsets.position.getDefault(new PositionStruct()),
					flip: typeData.offsets.flip.getDefault(new TypeXY<Bool>(false, false)),
					scale: typeData.offsets.scale.getDefault(new PositionStruct())
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
			slot.asset = anim.reflectDefault('asset', data.asset);
			slot.name = anim.name;
			if (Reflect.hasField(anim, 'tag')) slot.tag = anim.tag.getDefault(slot.name);
			if (Reflect.hasField(anim, 'dimensions')) slot.dimensions = anim.dimensions.getDefault(new TypeXY<Int>(1, 1));
			slot.indices = anim.indices.getDefault([]);
			slot.offset = anim.offset.getDefault(new PositionStruct());
			slot.flip = anim.flip.getDefault(new TypeXY<Bool>(false, false));
			slot.loop = anim.loop.getDefault(false);
			slot.fps = anim.fps.getDefault(24);
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
		data.antialiasing = typeData.antialiasing.getDefault(true);

		if (charData != null) data.character = charData;
		if (beatData != null) data.beat = beatData;

		return data;
	}

	/**
	 * Parse's a songs meta json.
	 * @param name The song folder name.
	 * @param pathType The path type.
	 * @return `SongData` ~ The parsed meta json content.
	 */
	public static function song(name:String, pathType:FunkinPath = ANY):SongData {
		// final contents:SongParse = new JsonParser<SongParse>().fromJson(Paths.getFileContent(Paths.json('content/songs/$name/meta', pathType)), Paths.json('content/songs/$name/meta', pathType));
		final contents:SongParse = json('content/songs/$name/meta', pathType);
		return {
			name: json('content/songs/$name/audio', pathType).name,
			folder: contents.folder,
			icon: contents.icon,
			startingDiff: contents.startingDiff.getDefault(Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (d in contents.difficulties) d.toLowerCase()], // jic
			variants: [for (v in contents.variants.getDefault([for (d in contents.difficulties) FunkinUtil.getDifficultyVariant(d)])) v.toLowerCase()],
			color: FlxColor.fromString(contents.color),
			allowedModes: contents.allowedModes
		}
	}
}