package imaginative.objects.ui.cameras;

typedef TargetOffset = Void->Position;

class BaseCamera extends FlxCamera {
	/**
	 * .
	 */
	public var targetOffsets:Array<TargetOffset> = [];
	/**
	 * .
	 */
	public var namedTargetOffsets:Map<String, TargetOffset> = [];
	/**
	 * Returns the position that adds all the offsets together.
	 * @param includeMainTarget If false, this won't include the main target point in the math.
	 * @return `Position` ~ The final position.
	 */
	public function getTargetPosition(includeMainTarget:Bool = true):Position {
		var result:Position = new Position();

		if (includeMainTarget) {
			result.x += target?.x ?? 0;
			result.y += target?.y ?? 0;
		}
		result.x += targetOffset?.x ?? 0;
		result.y += targetOffset?.y ?? 0;

		for (offset in targetOffsets) {
			var data:Position = offset();
			result.x += data?.x ?? 0;
			result.y += data?.y ?? 0;
		}
		for (offset in namedTargetOffsets) {
			var data:Position = offset();
			result.x += data?.x ?? 0;
			result.y += data?.y ?? 0;
		}

		return targetPosition = result;
	}
	var targetPosition:Position;

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
			_point.addPoint(getTargetPosition(false).toFlxPoint());
			focusOn(_point);
		} else {
			var edge:Float;
			getTargetPosition();
			var targetX:Float = targetPosition.x;
			var targetY:Float = targetPosition.y;

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

			if (target is Character) {
				var camPos:Position = cast(target, Character).getCamPos();
				_lastTargetPosition ??= FlxPoint.get(camPos.x, camPos.y);

				_scrollTarget.x += (camPos.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (camPos.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = camPos.x;
				_lastTargetPosition.y = camPos.y;
			} else if (target is FlxSprite) {
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
	inline public function updateZoom(elapsed:Float):Void
		zoom = FunkinUtil.lerp(zoom, defaultZoom, zoomLerp * zoomSpeed);

	@:deprecated('Use setFollow instead.') // override used just for this lol
	override public function follow(target:FlxObject, ?style:FlxCameraFollowStyle, ?lerp:Float):Void
		super.follow(target, style, lerp);

	/**
	 * Snaps the camera to the default zoom target.
	 */
	inline public function snapZoom():Void
		zoom = defaultZoom; // will eventually include offsets

	/**
	 * Sets the main follow data.
	 * @param target The main target object to follow.
	 * @param lerp The lerp amount.
	 * @param speed The lerp multiplier.
	 * @param style The camera follow style.
	 * @param resetOffsets If true, it will clear all offsets.
	 */
	inline public function setFollow(target:FlxObject, lerp:Float = 0.2, speed:Float = 1, style:FlxCameraFollowStyle = LOCKON, resetOffsets:Bool = false):Void {
		follow(target, style, lerp ?? 60);
		followSpeed = speed;
		if (resetOffsets)
			targetOffsets = [];
	}
	/**
	 * Adds extra follow data.
	 * @param target The extra target object to follow.
	 * @param lerp The lerp amount.
	 * @param speed The lerp multiplier.
	 */
	inline public function addFollow(target:FlxObject, lerp:Float = 0.2, speed:Float = 1):Void {
		//
	}

	/**
	 * Sets the main zooming data.
	 * @param target The target zoom to follow.
	 * @param lerp The lerp amount.
	 * @param speed The lerp multiplier.
	 * @param resetOffsets If true, it will clear all offsets.
	 */
	inline public function setZooming(target:Float, lerp:Float = 0.16, speed:Float = 1, resetOffsets:Bool = false):Void {
		defaultZoom = target;
		zoomLerp = lerp;
		zoomSpeed = speed;
		// if (resetOffsets)
	}
	/**
	 * Adds extra zooming data.
	 * @param target A multiplier for target zoom.
	 * @param lerp The lerp amount.
	 * @param speed The lerp multiplier.
	 */
	inline public function addZooming(target:Float, lerp:Float = 0.16, speed:Float = 1):Void {
		//
	}

	inline override function set_followLerp(value:Float):Float
		return followLerp = value;
}