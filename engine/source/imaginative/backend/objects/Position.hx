package imaginative.backend.objects;

import hxjsonast.Json;

// TODO: Rethink this classes existence.
/**
 * Basically TypeXY but forced to be a Float.
 */
class Position {
	/**
	 * The x position.
	 */
	public var x(default, set):Float = 0;
	@SuppressWarnings('checkstyle:FieldDocComment')
	public dynamic function set_x(value:Float):Float
		return x = value;
	/**
	 * The y position.
	 */
	public var y(default, set):Float = 0;
	@SuppressWarnings('checkstyle:FieldDocComment')
	public dynamic function set_y(value:Float):Float
		return y = value;

	public function new(x:Float = 0, y:Float = 0)
		set(x, y);

	/**
	 * Sets the x and y position.
	 * @param x The new x position.
	 * @param y The new y position.
	 * @return Position ~ Current instance for chaining.
	 */
	public dynamic function set(x:Float = 0, y:Float = 0):Position {
		this.x = x ?? 0;
		this.y = y ?? 0;
		return this;
	}

	/**
	 * Copies from another 'Position' instance.
	 * @param from 'Position' instance.
	 * @return Position ~ Current instance for chaining.
	 */
	inline public function copyFrom(from:Position):Position
		return set(from.x, from.y);

	/**
	 * Gets the midpoint of an object.
	 * @param obj The object to get a midpoint from.
	 * @return Position ~ Current instance for chaining.
	 */
	inline public static function getObjMidpoint(obj:FlxObject):Position {
		return new Position(obj.x + obj.width * 0.5, obj.y + obj.height * 0.5);
	}

	/**
	 * Creates a 'Position' instance from the x, y of a 'FlxPoint' instance.
	 * @param point The 'FlxPoint' to get the position of.
	 * @param position An optional 'Position' to apply it to.
	 *                 If you put a 'Position' it won't create a new one.
	 * @return Position ~ The created 'Position' instance.
	 */
	inline public static function fromFlxPoint(point:FlxPoint, ?position:Position):Position
		return position == null ? new Position(point.x, point.y) : position.set(point.x, point.y);
	/**
	 * Creates a 'FlxPoint' instance from the x, y of a 'Position' instance.
	 * @param point An optional 'FlxPoint' to apply it to.
	 *              If you put a 'FlxPoint' it won't create a new one.
	 * @return FlxPoint ~ The created 'FlxPoint' instance.
	 */
	inline public function toFlxPoint(?point:FlxPoint):FlxPoint
		return point == null ? FlxPoint.get(x, y) : point.set(x, y);

	/**
	 * Creates a 'Position' instance from the x, y of an array.
	 * @param array The array to get the position of.
	 * @param position An optional 'Position' to apply it to.
	 *                 If you put a 'Position' it won't create a new one.
	 * @return Position ~ The created 'Position' instance.
	 */
	inline public static function fromArray(array:Array<Float>, ?position:Position):Position
		return position == null ? new Position(array[0], array[1]) : position.set(array[0], array[1]);
	/**
	 * Creates an array from the x, y of this 'Position' instance.
	 * @return Array<Float> ~ The created array.
	 */
	inline public function toArray():Array<Float>
		return [x, y];

	inline public function toString():String
		return '{x: $x, y: $y}';

	// json2object parse and write shit
	/**
	 * Json2Object custom parse for the Position class.
	 * @param json The json variable.
	 * @param name The variable name.
	 * @return Position ~ The parsed data.
	 */
	public static function _parse(json:Json, name:String):Position {
		inline function getJNumber(value:JsonValue):Float {
			return switch (value) {
				case JNumber(number): Std.parseFloat(number);
				default: 0;
			}
		}
		return switch (json.value) {
			case JObject(fields):
				var data = new Position();
				for (field in fields)
					if (field.name == 'x') data.x = getJNumber(field.value.value);
					else if (field.name == 'y') data.y = getJNumber(field.value.value);
				data;
			case JArray(array): fromArray([for (slot in array) getJNumber(slot.value)]);
			default: null;
		}
	}
	/**
	 * Json2Object custom parse for the Position class.
	 * This version is for when it forces to state 'Null' return.
	 * @param json The json variable.
	 * @param name The variable name.
	 * @return Position ~ The parsed data.
	 */
	public static function _parseOp(json:Json, name:String):Null<Position>
		return _parse(json, name);
	/**
	 * Json2Object custom write for the Position class.
	 * @param data The data to convert to a string.
	 * @return String ~ The written output.
	 */
	public static function _write(data:Position):String
		return _writeOp(data);
	/**
	 * Json2Object custom write for the Position class.
	 * This version is for when it forces to state 'Null' input.
	 * @param data The data to convert to a string.
	 * @return String ~ The written output.
	 */
	public static function _writeOp(?data:Position):String
		return data == null ? 'null' : '[${data.toArray().formatArray()}]';
}