package fnf.backend.metas;

@:struct @:structInit class PositionMeta {
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0) set(this.x = x, this.y = y); // lol
	public function set(x:Float = 0, y:Float = 0) {this.x = x; this.y = y;}
	// public function copy():PositionMeta return {x: x, y: y} // Null Object Reference
}