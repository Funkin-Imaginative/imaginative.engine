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
	var color:Null<FlxColor>;
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
	 * @param file The mod path.
	 * @return `Dynamic` ~ The parsed json.
	 */
	inline public static function json(file:ModPath):Dynamic {
		var content:Dynamic = {}
		try {
			var jsonPath:ModPath = Paths.json(file);
			content = haxe.Json.parse(Paths.getFileContent(jsonPath));
		} catch(error:haxe.Exception)
			trace('${file.format()}: ${error.message}');
		return content;
	}

	/**
	 * Parse's a difficulty json.
	 * @param key The difficulty key.
	 * @return `DifficultyData` ~ The parsed difficulty json.
	 */
	inline public static function difficulty(key:String):DifficultyData {
		final jsonPath:ModPath = Paths.difficulty(key);
		var contents:DifficultyData = new JsonParser<DifficultyData>().fromJson(Paths.getFileContent(jsonPath), jsonPath.format());
		contents.display = contents.display.getDefault(key);
		return contents;
	}

	/**
	 * Parse's a level json.
	 * @param name The level json name.
	 * @return `LevelData` ~ The parsed level json.
	 */
	public static function level(name:ModPath):LevelData {
		final jsonPath:ModPath = Paths.level(name);
		var contents:LevelParse = new JsonParser<LevelParse>().fromJson(Paths.getFileContent(jsonPath), jsonPath.format());
		for (i => data in contents.objects) {
			data.flip = data.flip.getDefault((i + 1) > Math.floor(contents.objects.length / 2));
			if (data.offsets == null) data.offsets = new Position();
			data.size = data.size.getDefault(1);
			data.willHey = data.willHey.getDefault(i == Math.floor(contents.objects.length / 2));
		}
		var songs:Array<SongData> = [
			for (song in contents.songs)
				ParseUtil.song(song)
		];
		for (song in songs)
			song.color = song.color == null ? FlxColor.fromString(contents.color) : song.color;
		return {
			name: name.path,
			title: contents.title,
			songs: songs,
			startingDiff: contents.startingDiff.getDefault(Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [
				for (difficulty in contents.difficulties)
					difficulty.toLowerCase()
			],
			variants: [
				for (variant in contents.variants.getDefault([
					for (difficulty in contents.difficulties)
						FunkinUtil.getDifficultyVariant(difficulty)
				]))
					variant.toLowerCase()
			],
			objects: contents.objects,
			color: FlxColor.fromString(contents.color)
		}
	}

	/**
	 * Parse's an object json.
	 * @param file The object json name.
	 * @param type The sprite type.
	 * @return `SpriteData` ~ The parsed object json.
	 */
	public static function object(file:ModPath, type:SpriteType):SpriteData {
		final jsonPath:ModPath = Paths.object(file);
		final typeData:SpriteData = new JsonParser<SpriteData>().fromJson(Paths.getFileContent(jsonPath), jsonPath.format());
		final tempData:Dynamic = json(jsonPath);

		var charData:CharacterData = null;
		if (type.isBeatType && (type == IsCharacterSprite && Reflect.hasField(tempData, 'character'))) {
			var gottenData:CharacterParse = null;
			var typeData:SpriteData = typeData;
			try {
				gottenData = json(jsonPath).character;
				typeData.character.color = FlxColor.fromString(gottenData.color);
			} catch(error:haxe.Exception)
				trace(error.message);
			charData = {
				camera: new Position(Reflect.getProperty(typeData.character.camera, 'x'), Reflect.getProperty(typeData.character.camera, 'y')),
				color: typeData.character.color,
				icon: typeData.character.icon,
				singlength: typeData.character.singlength
			}
		}

		var beatData:BeatData = null;
		if (type.isBeatType && Reflect.hasField(tempData, 'beat')) {
			var typeData:BeatData = typeData.beat;
			beatData = {
				interval: typeData.interval,
				skipnegative: typeData.skipnegative
			}
		}

		var data:Dynamic = {}
		if (Reflect.hasField(typeData, 'offsets'))
			try {
				data.offsets = {
					position: new Position(Reflect.getProperty(typeData.offsets.position, 'x'), Reflect.getProperty(typeData.offsets.position, 'y')),
					flip: new TypeXY<Bool>(Reflect.getProperty(typeData.offsets.flip, 'x'), Reflect.getProperty(typeData.offsets.flip, 'y')),
					scale: new Position(Reflect.getProperty(typeData.offsets.scale, 'x'), Reflect.getProperty(typeData.offsets.scale, 'y'))
				}
			} catch(error:haxe.Exception) {
				data.offsets = {
					position: new Position(),
					flip: new TypeXY<Bool>(false, false),
					scale: new Position(1, 1)
				}
			}
		else
			data.offsets = {
				position: new Position(),
				flip: new TypeXY<Bool>(false, false),
				scale: new Position(1, 1)
			}

		data.asset = typeData.asset;
		data.animations = [];
		for (anim in typeData.animations) {
			var slot:AnimationTyping = cast {}
			slot.asset = anim.asset.getDefault(data.asset);
			slot.name = anim.name;
			if (Reflect.hasField(anim, 'tag')) slot.tag = anim.tag.getDefault(slot.name);
			if (Reflect.hasField(anim, 'swapKey')) slot.swapKey = anim.swapKey.getDefault('');
			if (Reflect.hasField(anim, 'flipKey')) slot.flipKey = anim.flipKey.getDefault('');
			if (Reflect.hasField(anim, 'dimensions')) slot.dimensions = new TypeXY<Int>(Reflect.getProperty(anim.dimensions, 'x'), Reflect.getProperty(anim.dimensions, 'y'));
			slot.indices = anim.indices.getDefault([]);
			slot.offset = new Position(Reflect.getProperty(anim.offset, 'x'), Reflect.getProperty(anim.offset, 'y'));
			slot.flip = new TypeXY<Bool>(Reflect.getProperty(anim.flip, 'x'), Reflect.getProperty(anim.flip, 'y'));
			slot.loop = anim.loop.getDefault(false);
			slot.fps = anim.fps.getDefault(24);
			data.animations.push(slot);
		}

		if (Reflect.hasField(typeData, 'starting')) {
			try {
				data.starting = {
					position: new Position(Reflect.getProperty(typeData.starting.position, 'x'), Reflect.getProperty(typeData.starting.position, 'y')),
					flip: new TypeXY<Bool>(Reflect.getProperty(typeData.starting.flip, 'x'), Reflect.getProperty(typeData.starting.flip, 'y')),
					scale: new Position(Reflect.getProperty(typeData.starting.scale, 'x'), Reflect.getProperty(typeData.starting.scale, 'y'))
				}
			} catch(error:haxe.Exception) {}
		}

		data.swapAnimTriggers = typeData.swapAnimTriggers;
		data.flipAnimTrigger = typeData.flipAnimTrigger;
		data.antialiasing = typeData.antialiasing;

		if (charData != null) data.character = charData;
		if (beatData != null) data.beat = beatData;

		return data;
	}

	/**
	 * Parse's a SpriteText json.
	 * @param font The font json file name.
	 * @return `SpriteTextSetup` ~ The parsed font json.
	 */
	public static function spriteFont(font:ModPath):SpriteTextSetup {
		final jsonPath:ModPath = Paths.spriteFont(font);
		return new JsonParser<SpriteTextSetup>().fromJson(Paths.getFileContent(jsonPath), jsonPath.format());
	}

	/**
	 * Parse's a songs meta json.
	 * @param name The song folder name.
	 * @return `SongData` ~ The parsed meta json.
	 */
	public static function song(name:ModPath):SongData {
		final jsonPath:ModPath = Paths.json('content/songs/${name.path}/meta');
		final contents:SongParse = new JsonParser<SongParse>().fromJson(Paths.getFileContent(jsonPath), jsonPath.format());
		return {
			name: json('content/songs/${name.path}/audio').name,
			folder: contents.folder,
			icon: contents.icon,
			startingDiff: contents.startingDiff.getDefault(Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [
				for (difficulty in contents.difficulties)
					difficulty.toLowerCase()
			],
			variants: [
				for (variant in contents.variants.getDefault([
					for (difficulty in contents.difficulties)
						FunkinUtil.getDifficultyVariant(difficulty)
				]))
					variant.toLowerCase()
			],
			color: contents.color != null ? FlxColor.fromString(contents.color) : null,
			allowedModes: contents.allowedModes
		}
	}
}