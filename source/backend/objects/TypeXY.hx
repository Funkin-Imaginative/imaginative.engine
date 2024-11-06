package backend.objects;

/**
 * This class is adaptable since it utilizes <T> to change it's type definition.
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