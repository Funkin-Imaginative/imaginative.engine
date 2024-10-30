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
	 * @param path The mod path.
	 * @param pathType The path type.
	 * @return `Dynamic` ~ The parsed json content.
	 */
	public static function json(path:String, pathType:ModType = ANY):Dynamic {
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
	public static function difficulty(name:String, pathType:ModType = ANY):DifficultyData {
		final contents:DifficultyData = new JsonParser<DifficultyData>().fromJson(Paths.getFileContent(Paths.json('content/difficulties/$name', pathType)), Paths.json('content/difficulties/$name', pathType));
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
	public static function level(name:String, pathType:ModType = ANY):LevelData {
		// var contents:LevelParse = new JsonParser<LevelParse>().fromJson(Paths.getFileContent(Paths.json('content/levels/$name', pathType)), Paths.json('content/levels/$name', pathType));
		var contents:LevelParse = json('content/levels/$name', pathType);
		for (i => data in contents.objects) {
			data.flip = data.flip.getDefault((i + 1) > Math.floor(contents.objects.length / 2));
			if (data.offsets == null) data.offsets = new Position();
			data.size = data.size.getDefault(1);
			data.willHey = data.willHey.getDefault(i == Math.floor(contents.objects.length / 2));
		}
		var songs:Array<SongData> = [for (song in contents.songs) ParseUtil.song(song)];
		for (song in songs)
			song.color = song.color == null ? FlxColor.fromString(contents.color) : song.color;
		return {
			name: name,
			title: contents.title,
			songs: songs,
			startingDiff: contents.startingDiff.getDefault(Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [
				for (d in contents.difficulties)
					d.toLowerCase()
			],
			variants: [
				for (v in contents.variants.getDefault([
					for (d in contents.difficulties)
						FunkinUtil.getDifficultyVariant(d)
				]))
					v.toLowerCase()
			],
			objects: contents.objects,
			color: FlxColor.fromString(contents.color)
		}
	}

	/**
	 * Parse's object json data.
	 * @param path The object json name.
	 * @param type The sprite type.
	 * @return `SpriteData` ~ The parsed object json.
	 */
	public static function object(path:String, type:SpriteType, pathType:ModType = ANY):SpriteData {
		final typeData:SpriteData = new JsonParser<SpriteData>().fromJson(Paths.getFileContent(Paths.json('content/objects/$path', pathType)), Paths.json('content/objects/$path', pathType));
		final tempData:Dynamic = json('content/objects/$path', pathType);

		var charData:CharacterData = null;
		if (type.isBeatType && (type == IsCharacterSprite && Reflect.hasField(tempData, 'character'))) {
			var gottenData:CharacterParse = null;
			var typeData:SpriteData = typeData;
			try {
				gottenData = json('content/objects/$path', pathType).character;
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
	 * Parse's a songs meta json.
	 * @param name The song folder name.
	 * @return `SongData` ~ The parsed meta json.
	 */
	public static function song(name:String, pathType:ModType = ANY):SongData {
		final contents:SongParse = new JsonParser<SongParse>().fromJson(Paths.getFileContent(Paths.json('content/songs/$name/meta', pathType)), Paths.json('content/songs/$name/meta', pathType));
		return {
			name: json('content/songs/$name/audio', pathType).name,
			folder: contents.folder,
			icon: contents.icon,
			startingDiff: contents.startingDiff.getDefault(Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [
				for (d in contents.difficulties)
					d.toLowerCase()
			],
			variants: [
				for (v in contents.variants.getDefault([
					for (d in contents.difficulties)
						FunkinUtil.getDifficultyVariant(d)
				]))
					v.toLowerCase()
			],
			color: contents.color != null ? FlxColor.fromString(contents.color) : null,
			allowedModes: contents.allowedModes
		}
	}
}