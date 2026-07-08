package imaginative.backend.utils;

import haxe.iterators.StringIterator;
import haxe.iterators.StringKeyValueIterator;

class StringUtil {
	// Custom Stuff
	/**
	 * Is basically an array's split function but each array slot is trimmed.
	 * @param string The string.
	 * @param delimiter The splitter key.
	 * @return Array<String>
	 */
	inline public static function trimSplit(string:String, delimiter:String):Array<String> {
		var daList:Array<String> = string.split(delimiter);
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
	}

	/**
	 * Checks if a string is blank.
	 * @param string The string.
	 * @return Bool
	 */
	inline public static function isBlank(string:String):Bool
		return string.trim() == '' || string == null;
	/**
	 * Checks if a string is blank, if so, choose what to replace it with.
	 * @param string The string.
	 * @param newString The new string.
	 * @return Null<String>
	 */
	inline public static function ifBlankReplace(string:String, ?newString:String):Null<String>
		return string.isBlank() ? newString : string;

	// From StringTools
	/**
	 * Checks if a string contains a set value.
	 * @param string The string.
	 * @param value The content to check for.
	 * @return Bool
	 */
	inline public static function contains(string:String, value:String):Bool
		return StringTools.contains(string, value);

	/**
	 * Checks if a string starts with a set value.
	 * @param string Ths string.
	 * @param value The content to check for.
	 * @return Bool
	 */
	inline public static function startsWith(string:String, value:String):Bool
		return StringTools.startsWith(string, value);
	/**
	 * Checks if a string ends with a set value.
	 * @param string Ths string.
	 * @param value The content to check for.
	 * @return Bool
	 */
	inline public static function endsWith(string:String, value:String):Bool
		return StringTools.endsWith(string, value);

	inline public static function isSpace(string:String, pos:Int):Bool
		return StringTools.isSpace(string, pos);

	/**
	 * Trims blank space on both sides of a string.
	 * @param string The string.
	 * @return String
	 */
	inline public static function trim(string:String):String
		return StringTools.trim(string);
	/**
	 * Trims blank space on the left side of a string.
	 * @param string The string.
	 * @return String
	 */
	inline public static function leftTrim(string:String):String
		return StringTools.ltrim(string);
	/**
	 * Trims blank space on the right side of a string.
	 * @param string The string.
	 * @return String
	 */
	inline public static function rightTrim(string:String):String
		return StringTools.rtrim(string);

	inline public static function leftPad(string:String, content:String, length:Int):String
		return StringTools.lpad(string, content, length);
	inline public static function rightPad(string:String, content:String, length:Int):String
		return StringTools.rpad(string, content, length);

	/**
	 * Replaces set parts of a string with a set value.
	 * @param string The string.
	 * @param sub The content to replace.
	 * @param by The content to use instead.
	 * @return String
	 */
	inline public static function replace(string:String, sub:String, by:String):String
		return StringTools.replace(string, sub, by);

	inline static function iterator(string:String):StringIterator
		return new StringIterator(string);
	inline static function keyValueIterator(string:String):StringKeyValueIterator
		return new StringKeyValueIterator(string);
}