package fnf.backend;

import flixel.util.FlxStringUtil;

class BareCameraPoint extends FlxBasic {
	// shortcut
	@:isVar public var x(get, set):Float;
	@:isVar public var y(get, set):Float;
	private function set_x(value:Float):Float return point.x = value;
	private function set_y(value:Float):Float return point.y = value;
	private function get_x():Float return realPos.x; // :D
	private function get_y():Float return realPos.y;

	// these are the internal positions, they're not private on purpose
	public var point(default, never):FlxPoint = new FlxPoint();
	public var offset(default, never):FlxPoint = new FlxPoint();
	// this is what you set as the camera target
	public var realPos(default, never):FlxObject = new FlxObject();

	override public function new(startX:Float = 0, startY:Float = 0) {
		super();
		point.set(startX, startY);
	}

	public function setPoint(x:Float = 0, y:Float = 0) point.set(x, y);
	public function setOffset(x:Float = 0, y:Float = 0) offset.set(x, y);

	override public function update(elapsed:Float) {
		super.update(elapsed);
		realPos.update(elapsed);
		realPos.setPosition(
			point.x + offset.x,
			point.y + offset.y
		);
	}

	override public function destroy() {
		point.put();
		offset.put();
		realPos.destroy();
		super.destroy();
	}

	override public function toString():String {
		var realPosString:String = FlxStringUtil.getDebugString([
			LabelValuePair.weak('x', x),
			LabelValuePair.weak('y', y)
		]);
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('Point Position', point),
			LabelValuePair.weak('Offset Position', offset),
			LabelValuePair.weak('Current Position', realPosString)
		]);
	}
}