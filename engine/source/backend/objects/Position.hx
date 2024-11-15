package backend.objects;

/**
 * Basically TypeXY but forced to be a Float.
 */
@:structInit class Position {
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
	 * @param x The new X position.
	 * @param y The new Y position.
	 * @return `Position` ~ Current instance for chaining.
	 */
	inline public function set(x:Float = 0, y:Float = 0):Position {
		this.x = x.getDefault(0);
		this.y = y.getDefault(0);
		return this;
	}

	/**
	 * Copies from another Position instance.
	 * @param from Position instance.
	 * @return `Position` ~ Current instance for chaining.
	 */
	inline public function copyFrom(from:Position):Position
		return set(from.x, from.y);

	/**
	 * Get's the midpoint of an object.
	 * @param obj The object to get a midpoint from.
	 * @return `Position` ~ Current instance for chaining.
	 */
	inline public static function getObjMidpoint<T:FlxObject>(obj:T):Position {
		return new Position(obj.x + obj.width * 0.5, obj.y + obj.height * 0.5);
	}

	/**
	 * Creates a Position instance from the x, y of this FlxPoint instance.
	 * @param x The X position.
	 * @param y The Y position.
	 * @param point An optional Position to apply it to.
	 *              If you put a Position it won't create a new one.
	 * @return `Position` ~ The created Position instance.
	 */
	inline public static function fromFlxPoint(x:Float = 0, y:Float = 0, ?point:Position):Position
		return point == null ? new Position(x, y) : point.set(x, y);
	/**
	 * Creates a FlxPoint instance from the x, y of this Position instance.
	 * @param point An optional FlxPoint to apply it to.
	 *              If you put a FlxPoint it won't create a new one.
	 * @return `FlxPoint` ~ The created FlxPoint instance.
	 */
	inline public function toFlxPoint(?point:FlxPoint):FlxPoint
		return point == null ? FlxPoint.get(x, y) : point.set(x, y);

	inline public function toString():String
		return '{x: $x, y: $y}';
}