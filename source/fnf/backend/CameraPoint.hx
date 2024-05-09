package fnf.backend;

import flixel.util.FlxStringUtil;

class CameraPoint extends BareCameraPoint {
	// these are the lerp positions
	public var pointFollow(default, never):FlxPoint = new FlxPoint();
	public var offsetFollow(default, never):FlxPoint = new FlxPoint();
	public var realPosFollow(default, never):FlxObject = new FlxObject();

	public var lerpMult:Float = 1;
	public var pointLerp(get, default):Dynamic = 0.04;
	private function get_pointLerp():Float return lerpTranslate(pointLerp, 0.04);
	public var offsetLerp(get, default):Dynamic = null;
	private function get_offsetLerp():Float return lerpTranslate(offsetLerp, pointLerp);

	private function lerpTranslate(followLerp:Dynamic, ifNull:Float = 0.04):Float {
		var output:Float;
		if (Std.string(followLerp) == '<function>') output = followLerp();
		else output = followLerp;
		return output is Float ? output : ifNull;
	}

	override public function new(startX:Float = 0, startY:Float = 0, followLerp:Float = 0.04) {
		super(startX, startY);
		pointFollow.set(startX, startY);
		pointLerp = followLerp;
	}

	public function snapPoint(which:String = 'Why this is a string? I don\'t really care.') {
		switch (which) {
			case 'point':
				point.set(pointFollow.x, pointFollow.y);
			case 'offset':
				offset.set(offsetFollow.x, offsetFollow.y);
			default:
				point.set(pointFollow.x, pointFollow.y);
				offset.set(offsetFollow.x, offsetFollow.y);
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		pointFollow.set(
			FlxMath.lerp(point.x, pointFollow.x, pointLerp * lerpMult),
			FlxMath.lerp(point.y, pointFollow.y, pointLerp * lerpMult)
		);
		offsetFollow.set(
			FlxMath.lerp(offset.x, offsetFollow.x, offsetLerp * lerpMult),
			FlxMath.lerp(offset.y, offsetFollow.y, offsetLerp * lerpMult)
		);
		realPosFollow.update(elapsed);
		realPosFollow.setPosition(
			pointFollow.x + offsetFollow.x,
			pointFollow.y + offsetFollow.y
		);
	}

	override public function destroy() {
		pointFollow.put();
		offsetFollow.put();
		realPosFollow.destroy();
		super.destroy();
	}

	override public function toString():String {
		var realPosString:String = FlxStringUtil.getDebugString([
			LabelValuePair.weak('x', x),
			LabelValuePair.weak('y', y)
		]);
		var realPosFollowString:String = FlxStringUtil.getDebugString([
			LabelValuePair.weak('x', realPosFollow.x),
			LabelValuePair.weak('y', realPosFollow.y)
		]);
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('Upcoming Point Position', point),
			LabelValuePair.weak('Upcoming Offset Position', offset),
			LabelValuePair.weak('Upcoming Current Position', realPosString),
			LabelValuePair.weak('Current Point Position', pointFollow),
			LabelValuePair.weak('Current Offset Position', offsetFollow),
			LabelValuePair.weak('Current Current Position', realPosFollowString),
			LabelValuePair.weak('Lerp Multiplier', lerpMult),
			LabelValuePair.weak('Point Lerp', pointLerp),
			LabelValuePair.weak('Offset Lerp', offsetLerp)
		]);
	}
}