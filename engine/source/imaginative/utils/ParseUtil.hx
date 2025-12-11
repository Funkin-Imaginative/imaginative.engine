package imaginative.utils;

import json2object.JsonParser;
import imaginative.states.editors.ChartEditor.ChartData;

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
	 * @return Dynamic ~ The parsed json.
	 */
	inline public static function json(file:ModPath):Dynamic {
		var jsonPath:ModPath = Paths.json(file);
		return Assets.json(removeJsonComments(Assets.text(jsonPath)), jsonPath);
	}

	/**
	 * Parses a difficulty json.
	 * @param key The difficulty key.
	 * @return DifficultyData ~ The parsed difficulty json.
	 */
	inline public static function difficulty(key:String):DifficultyData {
		var jsonPath:ModPath = Paths.difficulty(key);
		var contents:DifficultyData = new JsonParser<DifficultyData>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format());
		contents.display = contents.display ?? key;
		return contents;
	}

	/**
	 * Parses a level json.
	 * @param name The level json name.
	 * @return LevelData ~ The parsed level json.
	 */
	public static function level(name:ModPath):LevelData {
		var jsonPath:ModPath = Paths.level(name);
		var contents:LevelData = new JsonParser<LevelData>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format());
		for (i => data in contents.objects) {
			data.flip ??= ((i + 1) > Math.floor(contents.objects.length / 2));
			data.willHey ??= (i == Math.floor(contents.objects.length / 2));
		}
		for (song in contents.songs)
			song.color = song.color == null ? contents.color : song.color;
		return {
			name: name.path,
			title: contents.title,
			songs: contents.songs,
			startingDiff: contents.startingDiff ?? (Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [
				for (difficulty in contents.difficulties)
					difficulty.toLowerCase()
			],
			variants: [
				for (variant in contents.variants ?? [
					for (difficulty in contents.difficulties)
						FunkinUtil.getDifficultyVariant(difficulty)
				])
					variant.toLowerCase()
			],
			objects: contents.objects,
			color: contents.color ?? 0xFFF9CF51
		}
	}

	/**
	 * Parses an object json.
	 * @param file The object json name.
	 * @param type The sprite type.
	 * @return SpriteData ~ The parsed object json.
	 */
	public static function object(file:ModPath, type:SpriteType):SpriteData {
		var jsonPath:ModPath = Paths.object(file);
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
	inline public static function chart(song:String, difficulty:String = 'normal', variant:String = 'normal'):ChartData {
		var jsonPath:ModPath = Paths.chart(song, difficulty, variant);
		return new JsonParser<ChartData>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format());
	}

	/**
	 * Parses a SpriteText json.
	 * @param font The font json file name.
	 * @return SpriteTextSetup ~ The parsed font json.
	 */
	inline public static function spriteFont(font:ModPath):SpriteTextSetup {
		var jsonPath:ModPath = Paths.spriteFont(font);
		return new JsonParser<SpriteTextSetup>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format());
	}

	/**
	 * Parses a songs meta json.
	 * @param name The song folder name.
	 * @return SongData ~ The parsed meta json.
	 */
	public static function song(name:ModPath):SongData {
		var jsonPath:ModPath = Paths.json('content/songs/${name.path}/meta');
		var contents:SongData = new JsonParser<SongData>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format());
		return {
			name: json('content/songs/${name.path}/audio').name,
			folder: name.path,
			icon: contents.icon,
			startingDiff: contents.startingDiff ?? (Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [
				for (difficulty in contents.difficulties)
					difficulty.toLowerCase()
			],
			variants: [
				for (variant in contents.variants ?? [
					for (difficulty in contents.difficulties)
						FunkinUtil.getDifficultyVariant(difficulty)
				])
					variant.toLowerCase()
			],
			color: contents.color,
			allowedModes: contents.allowedModes
		}
	}
}