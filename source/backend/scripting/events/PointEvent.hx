package backend.scripting.events;

final class PointEvent extends ScriptEvent {
	public var x:Float;
	public var y:Float;

	override public function new(x:Float, y:Float) {
		super();
		this.x = x;
		this.y = y;
	}
}