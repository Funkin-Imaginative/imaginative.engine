package imaginative.backend.utils;

class ArrayUtil {
	/**
	 * Returns a clean displayed list for quickly tracing a list.
	 * @param array The array.
	 * @param clearArray If true, it resizes the array to 0.
	 * @return String
	 */
	inline public static function cleanDisplayList(array:Array<String>, clearArray:Bool = true):String {
		var result = '${[for (i => item in array) (i == (array.length - 2) && !array.empty()) ? '"$item" and' : '"$item"'].join(', ').replace('and,', 'and')}';
		if (clearArray) array.resize(0);
		return result;
	}

	/**
	 * Shortcut for "haxe.ds.ArraySort.sort".
	 * @param array The array.
	 * @param method The sort method.
	 */
	inline public static function arraySort<T>(array:Array<T>, method:(T, T)->Int):Void
		haxe.ds.ArraySort.sort(array, method);
}