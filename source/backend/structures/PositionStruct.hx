package backend.structures;

class TypeXY<T> {
	public var x:T;
	public var y:T;

	public function new(x:T, y:T)
		set(x, y);

	inline public function set(x:T, y:T):TypeXY<T> {
		this.x = FunkinUtil.getDefault(x, this.x);
		this.y = FunkinUtil.getDefault(y, this.y);
		return this;
	}

	public function copyFrom(from:TypeXY<T>):TypeXY<T> {
		set(from.x, from.y);
		return this;
	}

	inline public function toString():String
		return '{x: $x, y: $y}';
}

class PositionStruct {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(x:Float = 0, y:Float = 0)
		set(x, y);

	inline public function set(x:Float = 0, y:Float = 0):PositionStruct {
		this.x = x;
		this.y = y;
		return this;
	}

	public function copyFrom(from:PositionStruct):PositionStruct {
		set(from.x, from.y);
		return this;
	}

	inline public static function getObjMidpoint<Object:FlxObject>(obj:Object):PositionStruct {
		return new PositionStruct(obj.x + obj.width * 0.5, obj.y + obj.height * 0.5);
	}

	inline public function toString():String
		return '{x: $x, y: $y}';
}
