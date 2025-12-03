package imaginative.backend;

import hxjsonast.Json;

@SuppressWarnings('checkstyle:FieldDocComment')
class Tools {
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
			default: cast null;
		};
	}
	public static function _writeColor(data:FlxColor):String
		return data.toWebString();

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
	public static function _writeSongData(data:Array<SongData>):Array<String>
		return [for (song in data) song.folder];
}