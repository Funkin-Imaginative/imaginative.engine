package imaginative.backend.data;

abstract StringedArray(String) from String to String {
	inline static final DELIMITER:String = '---[STRINGED_ARRAY_DELIMITER]---';

	public var length(get, never):Int;
	inline function get_length():Int
		return this.getSliceCount(DELIMITER);

	inline public function new(?string:String, ?delimiter:String, ?array:Array<Any>) {
		if (array == null)
			this = string.replace(delimiter, DELIMITER);
		else this = fromArray(array);
	}

	inline public function iterator():StringedArrayIterator {
		return new StringedArrayIterator(this);
	}
	inline public function keyValueIterator():StringedArrayKeyValueIterator {
		return new StringedArrayKeyValueIterator(this);
	}

	@:from inline public static function fromArray(value:Array<Any>):StringedArray {
		var result = value.join(DELIMITER);
		value.resize(0); // ON PURPOSE
		return result;
	}
	@:to inline public function toArray():Array<String>
		return this.split(DELIMITER);

	inline public function toInt():Array<Int>
		return [for (i in abstract) Std.parseInt(i)];
	inline public function toFloat():Array<Float>
		return [for (i in abstract) Std.parseFloat(i)];
}

@:access(imaginative.backend.data.StringedArray)
final class StringedArrayIterator {
	var string:String;
	var offset:Int = 0;

	public inline function new(string:String)
		this.string = string;

	public inline function hasNext()
		return offset < string.getSliceCount(StringedArray.DELIMITER);
	public inline function next()
		return string.getSlice(StringedArray.DELIMITER, offset++);
}

@:access(imaginative.backend.data.StringedArray)
final class StringedArrayKeyValueIterator {
	var string:String;
	var offset:Int = 0;

	public inline function new(string:String)
		this.string = string;

	public inline function hasNext()
		return offset < string.getSliceCount(StringedArray.DELIMITER);
	public inline function next()
		return {key: offset, value: string.getSlice(StringedArray.DELIMITER, offset++)};
}