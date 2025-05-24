package imaginative.objects.ui.cameras;

class BaseCamera extends FlxCamera {
	/**
	 * Offsets for the camera target.
	 */
	public var targetOffsets:Array<Void->Array<Float>> = [];
	function getTargetOffsets():Position {
		var result:Position = new Position();
		for (offset in targetOffsets) {
			var data:Array<Float> = offset();
			result.x += data[0];
			result.y += data[1];
		}
		return result;
	}

	/**
	 * The camera follow multiplier.
	 */
	public var followSpeed:Float = 1;

	/**
	 * Used to smoothly zoom the camera.
	 */
	public var zoomLerp:Float = 1;
	/**
	 * The camera zoom multiplier.
	 */
	public var zoomSpeed:Float = 1;
	/**
	 * Whenever target zooming is enabled. Defaults to `false`.
	 */
	public var zoomEnabled:Bool = false;

	/**
	 * The default zoom to update to.
	 */
	public var defaultZoom:Float = 1;

	override public function new(x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, zoom:Float = 0) {
		super(x, y, width, height, zoom);
		defaultZoom = this.zoom;
	}

	override public function update(elapsed:Float):Void {
		if (zoomEnabled && !paused)
			updateZoom(elapsed);
		super.update(elapsed);
	}

	override public function updateFollow():Void {
		if (deadzone == null) {
			target.getMidpoint(_point);
			_point.addPoint(targetOffset);
			focusOn(_point);
		} else {
			var edge:Float;
			var targetX:Float = target.x + targetOffset.x + getTargetOffsets().x;
			var targetY:Float = target.y + targetOffset.y + getTargetOffsets().y;

			if (style == SCREEN_BY_SCREEN) {
				if (targetX >= (scroll.x + width))
					_scrollTarget.x += width;
				else if (targetX < scroll.x)
					_scrollTarget.x -= width;

				if (targetY >= (scroll.y + height))
					_scrollTarget.y += height;
				else if (targetY < scroll.y)
					_scrollTarget.y -= height;
			} else {
				edge = targetX - deadzone.x;
				if (_scrollTarget.x > edge)
					_scrollTarget.x = edge;
				edge = targetX + target.width - deadzone.x - deadzone.width;
				if (_scrollTarget.x < edge)
					_scrollTarget.x = edge;

				edge = targetY - deadzone.y;
				if (_scrollTarget.y > edge)
					_scrollTarget.y = edge;
				edge = targetY + target.height - deadzone.y - deadzone.height;
				if (_scrollTarget.y < edge)
					_scrollTarget.y = edge;
			}

			if (target is FlxSprite) {
				_lastTargetPosition ??= FlxPoint.get(target.x, target.y);

				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}

			if ((followLerp * followSpeed) == Math.POSITIVE_INFINITY)
				scroll.copyFrom(_scrollTarget);
			else {
				scroll.x = FunkinUtil.lerp(scroll.x, _scrollTarget.x, followLerp * followSpeed);
				scroll.y = FunkinUtil.lerp(scroll.y, _scrollTarget.y, followLerp * followSpeed);
			}
		}
	}

	/**
	 * Updates the camera zoom.
	 * @param elapsed The elapsed time between frames.
	 */
	public function updateZoom(elapsed:Float):Void
		zoom = FunkinUtil.lerp(zoom, defaultZoom, zoomLerp * zoomSpeed);

	override public function follow(target:FlxObject, ?style:FlxCameraFollowStyle, ?lerp:Float):Void
		super.follow(target, style, lerp ?? 60);

	inline override function set_followLerp(value:Float):Float
		return followLerp = value;
}