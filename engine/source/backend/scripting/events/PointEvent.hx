package backend.scripting.events;

final class PointEvent extends ScriptEvent {
	/**
	 * The x position of the point.
	 */
	public var x:Float;
	/**
	 * The y position of the point.
	 */
	public var y:Float;

	override public function new(x:Float, y:Float) {
		super();
		this.x = x;
		this.y = y;
	}
}