package imaginative.backend;

import hxjsonast.Json;

class Tools {
	/**
	 * Json2Object custom parse for colors.
	 * @param json The json variable.
	 * @param name The variable name.
	 * @return FlxColor ~ The parsed data.
	 */
	public static function _parseColor(json:Json, name:String):Null<FlxColor> {
		inline function getJNumber(value:JsonValue):Int {
			return switch (value) {
				case JNumber(number): Std.parseInt(number);
				default: 255;
			}
		}
		return switch (json.value) {
			case JString(string): FlxColor.fromString(string ?? 'white');
			case JNumber(number): FlxColor.fromInt(Std.parseInt(number ?? '-1'));
			case JArray(array):
				var output:Array<Int> = [for (slot in array) getJNumber(slot.value)];
				FlxColor.fromRGB(output[0], output[1], output[2], output[3]);
			default: null;
		}
	}
	/**
	 * Json2Object custom write for colors.
	 * @param data The data to convert to a string.
	 * @return String ~ The written output.
	 */
	public static function _writeColor(?data:FlxColor):String
		return data?.toWebString() ?? 'white';

	/**
	 * Json2Object custom parse for song lists.
	 * @param json The json variable.
	 * @param name The variable name.
	 * @return Array<SongData> ~ The parsed data.
	 */
	public static function _parseSongData(json:Json, name:String):Array<SongData> {
		inline function getJString(value:JsonValue):String {
			return switch (value) {
				case JString(string): string;
				default: null;
			}
		}
		return switch (json.value) {
			case JArray(array):
				var output:Array<String> = [for (slot in array) getJString(slot.value)].filter(song -> return !song.isNullOrEmpty());
				[for (song in output) ParseUtil.song(song)];
			default: [];
		}
	}
	/**
	 * Json2Object custom write for song lists.
	 * @param data The data to convert to a string.
	 * @return String ~ The written output.
	 */
	public static function _writeSongData(data:Array<SongData>):String
		return '[${[for (song in data) song.folder].formatArray()}]';
}