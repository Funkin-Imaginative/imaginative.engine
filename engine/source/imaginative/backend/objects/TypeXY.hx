package imaginative.backend.objects;

import hxjsonast.Json;

// TODO: Rethink this classes existence.
/**
 * This class is adaptable since it utilizes <T> to change it's type definition.
 */
class TypeXY<T> {
	public static function _jsonParse(val:Json, name:String):TypeXY<Dynamic> {
		inline function getJValue(value:JsonValue):Dynamic {
			return switch (value) {
				case JString(string): string;
				case JNumber(num): Std.parseFloat(num);
				case JBool(bool): bool;
				default: null;
			}
		}
		return switch (val.value) {
			case JObject(fields):
				var pos = new TypeXY<Dynamic>(null, null);
				for (field in fields)
					if (field.name == 'x') pos.x = getJValue(field.value.value);
					else if (field.name == 'y') pos.y = getJValue(field.value.value);
				pos;
			case JArray(data): fromArray([for (value in data) getJValue(value.value)]);
			default: null;
		}
	}
	public static function _jsonWrite<T>(data:TypeXY<T>):Array<T>
		return data.toArray();

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
}