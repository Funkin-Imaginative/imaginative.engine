package imaginative.utils;

import imaginative.states.editors.ChartEditor;

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
		final contents:DifficultyData = json(Paths.difficulty(id), true);
		contents.display = contents.display ?? id;
		return contents;
	}

	/**
	 * Parses a level json.
	 * @param name The level json name.
	 * @return LevelData ~ The parsed level json.
	 */
	public static function level(name:ModPath):LevelData {
		return LevelData.fromRaw(name.path, json(Paths.level(name.path), true));
	}

	/**
	 * Parses an object json.
	 * @param file The object json name.
	 * @param type The sprite type.
	 * @return SpriteData ~ The parsed object json.
	 */
	public static function object(file:ModPath, type:SpriteType = IsBaseSprite):SpriteData {
		return SpriteData.fromRaw(json(Paths.object(file), true), type);
	}

	/**
	 * Parses a chart json.
	 * @param song The song folder name.
	 * @param difficulty The difficulty key.
	 * @param variant The variant key.
	 * @return ChartData ~ The parsed chart json.
	 */
	inline public static function chart(song:String, difficulty:String, ?variant:String):ChartData {
		var chartPath:ModPath = Paths.chart(song, difficulty, variant);
		if (!chartPath.isFile) {
			_log('[ParseUtil.chart] Chart file "${chartPath.format()}" doesn\'t exist.', WarningMessage);
			return null;
		}
		return ChartData.fromRaw(json(chartPath, true));
	}

	/**
	 * Parses a SpriteText json.
	 * @param font The font json file name.
	 * @return SpriteTextSetup ~ The parsed font json.
	 */
	inline public static function spriteFont(font:ModPath):SpriteTextSetup {
		/* var jsonPath:ModPath = Paths.spriteFont(font); if (!jsonPath.isFile) return null;
		return new JsonParser<SpriteTextSetup>().fromJson(removeJsonComments(Assets.text(jsonPath)), jsonPath.format()); */
		return {name: 'null lol', fps: 24, characters: [], spaceWidth: 50}
	}

	/**
	 * Parses a songs meta json.
	 * @param name The song folder name.
	 * @return SongData ~ The parsed meta json.
	 */
	public static function song(name:ModPath):SongData {
		return SongData.fromRaw(name.path, json('content/songs/${name.path}/meta', true));
	}
}