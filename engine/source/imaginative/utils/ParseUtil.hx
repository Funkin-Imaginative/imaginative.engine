package imaginative.utils;

import json2object.JsonParser;
import imaginative.states.editors.ChartEditor.ChartData;

// TODO: Rework this.
typedef GamemodesTyping = {
	/**
	 * If true this song allows you to play as the enemy.
	 */
	@:default(false) var playAsEnemy:Bool;
	/**
	 * If true this song allows you to go against another player.
	 */
	@:default(false) var p2AsEnemy:Bool;
}

/**
 * This util is for all your parsing needs.
 */
class ParseUtil {
	/**
	 * Removes comments in json files, allowing for parsing commented json's!
	 * @param jsonContents The contents of the json file.
	 * @return String
	 * @author Made by @NebulaStellaNova, cleaned up by @rodney528.
	 */
	public static function removeJsonComments(jsonContents:String):String {
		var lineSplit:Array<String> = jsonContents.split('');
		var isComment:Bool = false;
		var isString:Bool = false;
		var result:String = '';
		for (i => char in lineSplit) {
			if (char == '"')
				isString = !isString;
			else if (!isString)
				if (char == '/' && lineSplit[i + 1] == '/')
					isComment = true;
			if (!isComment)
				result += char;
			else if (char == '\n') {
				isComment = false;
				result += char;
			}
		}
		return result;
	}

	/**
	 * Parses a json file.
	 * @param file The mod path.
	 * @param printWarning If true, if the json doesn't exist, a warning will be printed.
	 * @return Null<Dynamic> ~ The parsed json.
	 */
	inline public static function json(file:ModPath, printWarning:Bool = false):Null<Dynamic> {
		var jsonPath:ModPath = Paths.json(file);
		if (!jsonPath.isFile) {
			if (printWarning)
				_log('[ParseUtil.json] Json "${jsonPath.format()}" doesn\'t exist.', WarningMessage);
			return null;
		}
		return Assets.json(Assets.text(jsonPath), jsonPath);
	}

	// TODO: Rework this completely.
	/**
	 * Parses a difficulty json.
	 * @param id The difficulty id.
	 * @return DifficultyData ~ The parsed difficulty json.
	 */
	inline public static function difficulty(id:String):DifficultyData {
		final contents:DifficultyData = ParseUtil.json(Paths.difficulty(id), true);
		contents.display = contents.display ?? id;
		return contents;
	}

	/**
	 * Parses a level json.
	 * @param name The level json name.
	 * @return LevelData ~ The parsed level json.
	 */
	public static function level(name:ModPath):LevelData {
		final contents:RawLevelData = ParseUtil.json(Paths.level(name), true);
		final levelObjects:Array<ObjectTyping> = [
			for (i => data in contents.objects) {
				path: data.path,
				object: data.path == null ? null : data.object ?? ParseUtil.object(Paths.object(data.path), data.path.contains('character') ? IsCharacterSprite : IsBeatSprite),
				flip: data.flip ?? ((i + 1) > Math.floor(contents.objects.length / 2)),
				offsets: Position.fromArray(data.offsets ?? [0, 0]),
				size: data.size ?? 1,
				willHey: data.willHey ?? (i == Math.floor(contents.objects.length / 2))
			}
		];
		final levelColor:FlxColor = contents.color == null ? 0xFFF9CF51 : FlxColor.fromString(contents.color);
		final levelDiffs:Array<Array<String>> = [
			for (value in contents.difficulties) {
				var split:Array<String> = value.split(':');
				[split[0].toLowerCase(), split.length > 1 ? split[1].toLowerCase() : FunkinUtil.getDifficultyVariant(split[0].toLowerCase())];
			}
		];
		return {
			name: name.path,
			title: contents.title ?? '[Please Add a Title]',
			songs: [
				for (name in contents.songs) {
					var data = ParseUtil.song(name);
					data.color ??= levelColor;
					data;
				}
			],
			startingDiff: contents.startingDiff ?? (Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (value in levelDiffs) value[0]],
			variants: [for (value in levelDiffs) value[1]],
			objects: levelObjects,
			color: levelColor
		}
	}

	/**
	 * Parses an object json.
	 * @param file The object json name.
	 * @param type The sprite type.
	 * @return SpriteData ~ The parsed object json.
	 */
	public static function object(file:ModPath, type:SpriteType):SpriteData {
		var jsonPath:ModPath = Paths.object(file); if (!jsonPath.isFile) return null;
		var typeData:SpriteData = new JsonParser<SpriteData>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format());
		if (type != IsCharacterSprite) typeData._set('character', null);
		if (!type.isBeatType) typeData._set('beat', null);
		// trace('PRE WRITE (file:${file.format()}) ', haxe.Json.stringify(typeData, '\t'));
		// trace('POST WRITE (file:${file.format()}) ', new json2object.JsonWriter<SpriteData>(true).write(typeData, '\t'));
		return typeData;
	}

	/**
	 * Parses a chart json.
	 * @param song The song folder name.
	 * @param difficulty The difficulty key.
	 * @param variant The variant key.
	 * @return ChartData ~ The parsed chart json.
	 */
	inline public static function chart(song:String, difficulty:String, ?variant:String):ChartData {
		var jsonPath:ModPath = Paths.chart(song, difficulty, variant);
		if (!jsonPath.isFile) {
			_log('[ParseUtil.chart] Chart file "${jsonPath.format()}" doesn\'t exist.', WarningMessage);
			return null;
		}
		return new JsonParser<ChartData>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format());
	}

	/**
	 * Parses a SpriteText json.
	 * @param font The font json file name.
	 * @return SpriteTextSetup ~ The parsed font json.
	 */
	inline public static function spriteFont(font:ModPath):SpriteTextSetup {
		var jsonPath:ModPath = Paths.spriteFont(font); if (!jsonPath.isFile) return null;
		return new JsonParser<SpriteTextSetup>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format());
	}

	/**
	 * Parses a songs meta json.
	 * @param name The song folder name.
	 * @return SongData ~ The parsed meta json.
	 */
	public static function song(name:ModPath):SongData {
		final contents:RawSongData = ParseUtil.json(Paths.json('content/songs/${name.path}/meta'), true);
		final songDiffs:Array<Array<String>> = [
			for (value in contents.difficulties) {
				var split:Array<String> = value.split(':');
				[split[0].toLowerCase(), split.length > 1 ? split[1].toLowerCase() : FunkinUtil.getDifficultyVariant(split[0].toLowerCase())];
			}
		];
		return {
			name: json('content/songs/${name.path}/audio').name,
			folder: name.path,
			icon: contents.icon,
			startingDiff: contents.startingDiff ?? (Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [for (value in songDiffs) value[0]],
			variants: [for (value in songDiffs) value[1]],
			color: contents.color == null ? null : FlxColor.fromString(contents.color),
			allowedModes: contents.allowedModes
		}
	}
}