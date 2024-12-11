package imaginative.backend.scripting.events;

final class PointEvent extends ScriptEvent {
	/**
	 * The point itself.
	 */
	public var point:Position;
	/**
	 * The x position of the point.
	 */
	public var x(get, set):Float;
	inline function get_x():Float
		return point.x;
	inline function set_x(value:Float):Float
		return point.x = value;
	/**
	 * The y position of the point.
	 */
	public var y(get, set):Float;
	inline function get_y():Float
		return point.y;
	inline function set_y(value:Float):Float
		return point.y = value;

	override public function new(x:Float, y:Float, ?point:Position) {
		super();
		this.point = point == null ? new Position(x, y) : point.set(x ?? point.x, y ?? point.y);
	}
}