package backend.structures;

@:structInit class PositionStruct {
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0)
		set(x, y);

	inline public function set(x:Float = 0, y:Float = 0):PositionStruct {
		this.x = x;
		this.y = y;
		return this;
	}

	inline public static function getObjMidpoint<Object:FlxObject>(obj:Object):PositionStruct {
		return {
			x: obj.x + obj.width * 0.5,
			y: obj.y + obj.height * 0.5
		}
	}

	inline public function toString():String
		return '{x: $x, y: $y}';
}
