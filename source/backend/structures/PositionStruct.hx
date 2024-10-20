package backend.structures;

/**
 * This class is adaptable since it utilizes <> to change it's type definition.
 */
@:structInit class TypeXY<T> {
	/**
	 * X
	 */
	public var x:T;
	/**
	 * Y
	 */
	public var y:T;

	public function new(x:T, y:T)
		set(x, y);

	/**
	 * Set's the X and Y.
	 * @param x The new X.
	 * @param y The new Y.
	 * @return `TypeXY<T>` ~ Current instance for chaining.
	 */
	inline public function set(x:T, y:T):TypeXY<T> {
		this.x = x.getDefault(this.x);
		this.y = y.getDefault(this.y);
		return this;
	}

	/**
	 * Copies from another TypeXY instance.
	 * @param from TypeXY instance.
	 * @return `TypeXY<T>` ~ Current instance for chaining.
	 */
	inline public function copyFrom(from:TypeXY<T>):TypeXY<T>
		return set(from.x, from.y);

	inline public function toString():String
		return '{x: $x, y: $y}';
}

/**
 * Basically TypeXY but forced to be a Float.
 */
@:structInit class PositionStruct {
	/**
	 * The X position.
	 */
	public var x:Float = 0;
	/**
	 * The Y position.
	 */
	public var y:Float = 0;

	public function new(x:Float = 0, y:Float = 0)
		set(x, y);

	/**
	 * Set's the X and Y.
	 * @param x The new X.
	 * @param y The new Y.
	 * @return `PositionStruct` ~ Current instance for chaining.
	 */
	inline public function set(x:Float = 0, y:Float = 0):PositionStruct {
		this.x = x.getDefault(0);
		this.y = y.getDefault(0);
		return this;
	}

	/**
	 * Copies from another PositionStruct instance.
	 * @param from PositionStruct instance.
	 * @return `PositionStruct` ~ Current instance for chaining.
	 */
	inline public function copyFrom(from:PositionStruct):PositionStruct
		return set(from.x, from.y);

	/**
	 * Get's the midpoint of an object.
	 * @param obj The object to get a midpoint from.
	 * @return `PositionStruct` ~ Current instance for chaining.
	 */
	inline public static function getObjMidpoint<T:FlxObject>(obj:T):PositionStruct {
		return new PositionStruct(obj.x + obj.width * 0.5, obj.y + obj.height * 0.5);
	}

	/**
	 * Creates a FlxPoint instance from the x, y of this PositionStruct instance.
	 * @param point An optional FlxPoint to apply it to.
	 * 				If you put a FlxPoint it won't create a new one.
	 * @return `FlxPoint` ~ The created FlxPoint instance.
	 */
	inline public function toFlxPoint(?point:FlxPoint):FlxPoint
		return point == null ? FlxPoint.get(x, y) : point.set(x, y);

	inline public function toString():String
		return '{x: $x, y: $y}';
}
