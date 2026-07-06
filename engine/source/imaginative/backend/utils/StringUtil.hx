package imaginative.backend.utils;

import haxe.iterators.StringIterator;
import haxe.iterators.StringKeyValueIterator;

class StringUtil {
	inline public static function contains(string:String, value:String):Bool
		return StringTools.contains(string, value);

	inline public static function startsWith(string:String, value:String):Bool
		return StringTools.startsWith(string, value);
	inline public static function endsWith(string:String, value:String):Bool
		return StringTools.endsWith(string, value);

	inline public static function isSpace(string:String, pos:Int):Bool
		return StringTools.isSpace(string, pos);
	inline public static function isBlank(string:String):Bool
		return string.trim() == '' || string == null;

	inline public static function trim(string:String):String
		return StringTools.trim(string);

	inline public static function leftTrim(string:String):String
		return StringTools.ltrim(string);
	inline public static function rightTrim(string:String):String
		return StringTools.rtrim(string);

	inline public static function leftPad(string:String, pad:String, length:Int):String
		return StringTools.lpad(string, pad, length);
	inline public static function rightPad(string:String, pad:String, length:Int):String
		return StringTools.rpad(string, pad, length);

	inline public static function replace(string:String, sub:String, by:String):String
		return StringTools.replace(string, sub, by);

	public static inline function iterator(s:String):StringIterator
		return new StringIterator(s);
	public static inline function keyValueIterator(s:String):StringKeyValueIterator
		return new StringKeyValueIterator(s);
}