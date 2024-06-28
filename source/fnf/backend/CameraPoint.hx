package fnf.backend;

import flixel.util.FlxStringUtil;

typedef VoidORFloat = flixel.util.typeLimit.OneOfTwo<Void->Float, Float>;

enum abstract SnapPoint(String) from String to String {
	var POINT = 'point';
	var OFFSET = 'offset';
	var BOTH = 'Why isn\'t this null? I don\'t really care.';
}

class CameraPoint extends BareCameraPoint {
	// these are the positions, the non follow versions are now what these lerp to
	public var pointFollow(default, never):FlxPoint = new FlxPoint();
	public var offsetFollow(default, never):FlxPoint = new FlxPoint();
	public var realPosFollow(default, never):FlxObject = new FlxObject(); // this is what you set as the camera target

	// lerp math
	public var lerpMult:Float = 1;
	public var pointLerp(get, default):Dynamic; // VoidORFloat
	inline function get_pointLerp():Float return lerpTranslate(pointLerp, 0.04);
	public var offsetLerp(get, default):Dynamic; // VoidORFloat
	inline function get_offsetLerp():Float return lerpTranslate(offsetLerp, pointLerp);

	inline private static function lerpTranslate(followLerp:Dynamic, ifNull:Float = 0.04):Float {
		var output:Float;
		if (Std.isOfType(followLerp, Void->Float)) output = followLerp();
		else if (Std.isOfType(followLerp, Float)) output = followLerp;
		return !(output is Float) || output <= 0 ? ifNull : output;
	}

	override public function new(startX:Float = 0, startY:Float = 0, followLerp:Float = 0.04) {
		super(startX, startY);
		pointFollow.set(startX, startY);
		pointLerp = followLerp;
	}

	inline public function snapPoint(which:SnapPoint = BOTH) {
		switch (which) {
			case POINT:
				point.set(pointFollow.x, pointFollow.y);
			case OFFSET:
				offset.set(offsetFollow.x, offsetFollow.y);
			default:
				point.set(pointFollow.x, pointFollow.y);
				offset.set(offsetFollow.x, offsetFollow.y);
		}
	}

	override public function update(elapsed:Float) { // have to do Std.parseFloat('$pointLerp') them because, `fnf.backend.VoidORFloat should be Int For function argument 'ratio'` like wtf, so the vars themselves have to be Dynamic to prevent this.
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
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('Upcoming Point Position', point),
			LabelValuePair.weak('Upcoming Offset Position', offset),
			LabelValuePair.weak('Upcoming Current Position', FlxStringUtil.getDebugString([
				LabelValuePair.weak('x', x),
				LabelValuePair.weak('y', y)
			])),
			LabelValuePair.weak('Current Point Position', pointFollow),
			LabelValuePair.weak('Current Offset Position', offsetFollow),
			LabelValuePair.weak('Current Current Position', FlxStringUtil.getDebugString([
				LabelValuePair.weak('x', realPosFollow.x),
				LabelValuePair.weak('y', realPosFollow.y)
			])),
			LabelValuePair.weak('Lerp Multiplier', lerpMult),
			LabelValuePair.weak('Point Lerp', pointLerp),
			LabelValuePair.weak('Offset Lerp', offsetLerp)
		]);
	}
}