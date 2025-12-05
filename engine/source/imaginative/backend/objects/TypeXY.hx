package imaginative.backend.objects;

import hxjsonast.Json;

// TODO: Rethink this classes existence.
/**
 * This class is adaptable since it utilizes <T> to change it's type definition.
 */
class TypeXY<T> {
	/**
	 * The x value.
	 */
	public var x(default, set):T;
	@SuppressWarnings('checkstyle:FieldDocComment')
	public dynamic function set_x(value:T):T
		return x = value;
	/**
	 * The y value.
	 */
	public var y(default, set):T;
	@SuppressWarnings('checkstyle:FieldDocComment')
	public dynamic function set_y(value:T):T
		return y = value;

	public function new(x:T, y:T)
		set(x, y);

	/**
	 * Sets the x and y value.
	 * @param x The new x value.
	 * @param y The new y value.
	 * @return TypeXY<T> ~ Current instance for chaining.
	 */
	public dynamic function set(x:T, y:T):TypeXY<T> {
		this.x = x ?? this.x;
		this.y = y ?? this.y;
		return this;
	}

	/**
	 * Copies from another 'TypeXY' instance.
	 * @param from 'TypeXY' instance.
	 * @return TypeXY<T> ~ Current instance for chaining.
	 */
	inline public function copyFrom(from:TypeXY<T>):TypeXY<T>
		return set(from.x, from.y);

	/**
	 * Creates a 'TypeXY' instance from the x, y of an array.
	 * @param array The array to get the value of.
	 * @param value An optional 'TypeXY' to apply it to.
	 *                 If you put a 'TypeXY' it won't create a new one.
	 * @return TypeXY ~ The created 'TypeXY' instance.
	 */
	inline public static function fromArray<T>(array:Array<T>, ?value:TypeXY<T>):TypeXY<T>
		return value == null ? new TypeXY<T>(array[0], array[1]) : value.set(array[0], array[1]);
	/**
	 * Creates an array from the x, y of this 'TypeXY' instance.
	 * @return Array<T> ~ The created array.
	 */
	inline public function toArray():Array<T>
		return [x, y];

	inline public function toString():String
		return '{x: $x, y: $y}';

	// json2object parse and write shit
	/**
	 * Json2Object custom parse for the TypeXY class but 'Bool' specific.
	 * @param json The json variable.
	 * @param name The variable name.
	 * @return TypeXY<Bool> ~ The parsed data.
	 */
	public static function _parseBool(json:Json, name:String):TypeXY<Bool> {
		inline function getJBool(value:JsonValue):Bool {
			return cast switch (value) {
				case JBool(bool): bool;
				default: false;
			}
		}
		return cast switch (json.value) {
			case JObject(fields):
				var data = new TypeXY<Bool>(false, false);
				for (field in fields)
					if (field.name == 'x') data.x = getJBool(field.value.value);
					else if (field.name == 'y') data.y = getJBool(field.value.value);
				data;
			case JArray(array): fromArray([for (slot in array) getJBool(slot.value)]);
			default: null;
		}
	}
	/**
	 * Json2Object custom parse for the TypeXY class but 'Bool' specific.
	 * This version is for when it forces to state 'Null' return.
	 * @param json The json variable.
	 * @param name The variable name.
	 * @return TypeXY<Bool> ~ The parsed data.
	 */
	public static function _parseBoolOp(json:Json, name:String):Null<TypeXY<Bool>>
		return _parseBool(json, name);
	/**
	 * Json2Object custom parse for the TypeXY class but 'Int' specific.
	 * @param json The json variable.
	 * @param name The variable name.
	 * @return TypeXY<Int> ~ The parsed data.
	 */
	public static function _parseInt(json:Json, name:String):TypeXY<Int> {
		inline function getJNumber(value:JsonValue):Int {
			return switch (value) {
				case JNumber(number): Std.parseInt(number);
				default: 0;
			}
		}
		return cast switch (json.value) {
			case JObject(fields):
				var data = new TypeXY<Int>(0, 0);
				for (field in fields)
					if (field.name == 'x') data.x = getJNumber(field.value.value);
					else if (field.name == 'y') data.y = getJNumber(field.value.value);
				data;
			case JArray(array): fromArray([for (slot in array) getJNumber(slot.value)]);
			default: null;
		}
	}
	/**
	 * Json2Object custom parse for the TypeXY class but 'Int' specific.
	 * This version is for when it forces to state 'Null' return.
	 * @param json The json variable.
	 * @param name The variable name.
	 * @return TypeXY<Int> ~ The parsed data.
	 */
	public static function _parseIntOp(json:Json, name:String):Null<TypeXY<Int>>
		return _parseInt(json, name);
	/**
	 * Json2Object custom write for the TypeXY class but 'Bool' specific.
	 * @param data The data to convert to a string.
	 * @return String ~ The written output.
	 */
	public static function _writeBool(data:TypeXY<Bool>):String
		return _writeBoolOp(data);
	/**
	 * Json2Object custom write for the TypeXY class but 'Bool' specific.
	 * This version is for when it forces to state 'Null' input.
	 * @param data The data to convert to a string.
	 * @return String ~ The written output.
	 */
	public static function _writeBoolOp(?data:TypeXY<Bool>):String
		return data == null ? 'null' : '[${data.toArray().formatArray()}]';
	/**
	 * Json2Object custom write for the TypeXY class but 'Int' specific.
	 * @param data The data to convert to a string.
	 * @return String ~ The written output.
	 */
	public static function _writeInt(data:TypeXY<Int>):String
		return _writeIntOp(data);
	/**
	 * Json2Object custom write for the TypeXY class but 'Int' specific.
	 * This version is for when it forces to state 'Null' input.
	 * @param data The data to convert to a string.
	 * @return String ~ The written output.
	 */
	public static function _writeIntOp(?data:TypeXY<Int>):String
		return data == null ? 'null' : '[${data.toArray().formatArray()}]';
}