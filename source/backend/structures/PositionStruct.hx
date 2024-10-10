package backend.structures;

@:structInit class TypeXY<T> {
	public var x:T;
	public var y:T;

	public function new(x:T, y:T)
		set(x, y);

	inline public function set(x:T, y:T):TypeXY<T> {
		this.x = FunkinUtil.getDefault(x, this.x);
		this.y = FunkinUtil.getDefault(y, this.y);
		return this;
	}

	public function copyFrom(from:TypeXY<T>):TypeXY<T>
		return set(from.x, from.y);

	inline public function toString():String
		return '{x: $x, y: $y}';
}

@:structInit class PositionStruct {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(x:Float = 0, y:Float = 0)
		set(x, y);

	inline public function set(x:Float = 0, y:Float = 0):PositionStruct {
		this.x = x;
		this.y = y;
		return this;
	}

	public function copyFrom(from:PositionStruct):PositionStruct
		return set(from.x, from.y);

	inline public static function getObjMidpoint<T:FlxObject>(obj:T):PositionStruct {
		return new PositionStruct(obj.x + obj.width * 0.5, obj.y + obj.height * 0.5);
	}

	inline public function toString():String
		return '{x: $x, y: $y}';
}
