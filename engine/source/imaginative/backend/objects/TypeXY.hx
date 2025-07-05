package imaginative.backend.objects;

/**
 * This class is adaptable since it utilizes <T> to change it's type definition.
 */
class TypeXY<T> {
	/**
	 * The X value.
	 */
	public var x(default, set):T;
	@SuppressWarnings('checkstyle:FieldDocComment')
	public dynamic function set_x(value:T):T
		return x = value;
	/**
	 * The Y value.
	 */
	public var y(default, set):T;
	@SuppressWarnings('checkstyle:FieldDocComment')
	public dynamic function set_y(value:T):T
		return y = value;

	public function new(x:T, y:T)
		set(x, y);

	/**
	 * Sets the X and Y value.
	 * @param x The new X value.
	 * @param y The new Y value.
	 * @return `TypeXY<T>` ~ Current instance for chaining.
	 */
	public dynamic function set(x:T, y:T):TypeXY<T> {
		this.x = x ?? this.x;
		this.y = y ?? this.y;
		return this;
	}

	/**
	 * Copies from another TypeXY instance.
	 * @param from TypeXY instance.
	 * @return `TypeXY<T>` ~ Current instance for chaining.
	 */
	inline public function copyFrom(from:TypeXY<T>):TypeXY<T>
		return set(from.x, from.y);

	/**
	 * Creates a TypeXY instance from the x, y of an array.
	 * @param array The array to get the value of.
	 * @param value An optional TypeXY to apply it to.
	 *                 If you put a TypeXY it won't create a new one.
	 * @return `TypeXY` ~ The created TypeXY instance.
	 */
	inline public static function fromArray<T>(array:Array<T>, ?value:TypeXY<T>):TypeXY<T>
		return value == null ? new TypeXY<T>(array[0], array[1]) : value.set(array[0], array[1]);
	/**
	 * Creates an array from the x, y of this TypeXY instance.
	 * @return `Array<T>` ~ The created array.
	 */
	inline public function toArray():Array<T>
		return [x, y];

	inline public function toString():String
		return '{x: $x, y: $y}';
}