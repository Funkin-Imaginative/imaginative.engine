package fnf.backend.metas;

@:struct @:structInit class PositionMeta {
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0) set(this.x = x, this.y = y); // lol
	inline public function set(x:Float = 0, y:Float = 0) {this.x = x; this.y = y;}
	inline public static function get(x:Float = 0, y:Float = 0) return new PositionMeta(x, y);

	inline public function toString():String return '{x: $x, y: $y}';
}