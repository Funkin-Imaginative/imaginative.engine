package imaginative.objects.ui.cameras;

@:forward(x, y, set, toFlxPoint, toString)
abstract CameraTarget(Position) from Position to Position {
	/**
	 * Converts a FlxObject to a Position.
	 * @param from The FlxObject to intake.
	 * @return `Position`
	 */
	@:from inline public static function fromFlxObject(from:FlxObject):CameraTarget
		return new Position(from.x, from.y);
	/**
	 * Converts a FlxPoint to a Position.
	 * @param from The FlxPoint to intake.
	 * @return `Position`
	 */
	@:from inline public static function fromFlxPoint(from:FlxPoint):CameraTarget
		return Position.fromFlxPoint(from);
}

@:structInit class TargetSetup<T> {
	/**
	 * If true, when calculating it with others it will multiply instead of adding.
	 */
	public var multiply:Bool;
	/**
	 * The target the setup sticks to.
	 */
	public var target:T;
	/**
	 * The lerp speed to the target.
	 */
	public var lerp:Float;
	/**
	 * The multiplier for the lerp speed.
	 */
	public var mult:Float;

	public function new(multiply:Bool = false, target:T, lerp:Float, mult:Float = 1) {
		this.multiply = multiply;
		this.target = target;
		this.lerp = lerp;
		this.mult = mult;
	}
}

@SuppressWarnings('checkstyle:CodeSimilarity')
class FollowTargetSetup {
	/**
	 * The targets used for calculations.
	 */
	public var setup(default, null):Array<Void->TargetSetup<CameraTarget>> = [];
	/**
	 * Named targets used for calculations.
	 */
	public var named(default, never):Map<String, Void->TargetSetup<CameraTarget>> = new Map<String, Void->TargetSetup<CameraTarget>>();

	var loadTargets(default, null):Bool->TargetSetup<CameraTarget>;
	public function new(preAddedTargets:Bool->TargetSetup<CameraTarget>) {
		loadTargets = preAddedTargets;
	}

	/**
	 * Adds a target to use for calculations.
	 * @param tag The tag name. This is optional.
	 * @param func The function that returns the calculations to add.
	 * @return `FollowTargetSetup` ~ Current instance for chaining.
	 */
	public function add(?tag:String, func:Void->TargetSetup<CameraTarget>):FollowTargetSetup {
		if (tag == null) {
			if ([for (func2 in setup) Reflect.compare(func, func2) != 0].contains(true))
				setup.push(func);
		} else {
			if (named.exists(tag))
				named.set(tag, func);
		}
		return this;
	}
	/**
	 * Removes a target from calculations.
	 * @param tag The tag name. This is optional.
	 * @param func The function that should be removed from calculations. If using a tag, this argument is optional.
	 * @return `FollowTargetSetup` ~ Current instance for chaining.
	 */
	public function remove(?tag:String, ?func:Void->TargetSetup<CameraTarget>):FollowTargetSetup {
		if (tag == null) {
			if ([for (func2 in setup) Reflect.compare(func, func2) == 0].contains(true))
				setup.remove(func);
		} else {
			if (named.exists(tag))
				named.remove(tag);
		}
		return this;
	}

	/**
	 * Returns the final value that adds or multiplies all the targets together.
	 * @param includeMain If false, it won't include the main target in the calculations.
	 * @return `CameraTarget` ~ The final calculation.
	 */
	public function getFinalValue(includeMain:Bool = true):TargetSetup<CameraTarget> {
		var result:TargetSetup<CameraTarget> = loadTargets(includeMain);

		var points:Array<TargetSetup<CameraTarget>> = [];
		for (func in setup)
			points.push(func());
		for (func in named)
			points.push(func());

		for (target in points) {
			if (target.multiply) {
				result.target.x *= target.target?.x ?? 1;
				result.target.y *= target.target?.y ?? 1;
				result.lerp *= target.lerp;
				result.mult *= target.mult;
			} else {
				result.target.x += target.target?.x ?? 0;
				result.target.y += target.target?.y ?? 0;
				result.lerp += target.lerp;
				result.mult += target.mult;
			}
		}

		return result;
	}

	/**
	 * Resets certain data.
	 */
	public function reset():Void {
		setup = [];
		named.clear();
	}
}

class ZoomTargetSetup {
	/**
	 * The targets used for calculations.
	 */
	public var setup(default, null):Array<Void->TargetSetup<Float>> = [];
	/**
	 * Named targets used for calculations.
	 */
	public var named(default, never):Map<String, Void->TargetSetup<Float>> = new Map<String, Void->TargetSetup<Float>>();

	var loadTargets(default, null):Bool->TargetSetup<Float>;
	public function new(preAddedTargets:Bool->TargetSetup<Float>) {
		loadTargets = preAddedTargets;
	}

	/**
	 * Adds a target to use for calculations.
	 * @param tag The tag name. This is optional.
	 * @param func The function that returns the calculations to add.
	 * @return `ZoomTargetSetup` ~ Current instance for chaining.
	 */
	public function add(?tag:String, func:Void->TargetSetup<Float>):ZoomTargetSetup {
		if (tag == null) {
			if ([for (func2 in setup) Reflect.compare(func, func2) != 0].contains(true))
				setup.push(func);
		} else {
			if (named.exists(tag))
				named.set(tag, func);
		}
		return this;
	}
	/**
	 * Removes a target from calculations.
	 * @param tag The tag name. This is optional.
	 * @param func The function that should be removed from calculations. If using a tag, this argument is optional.
	 * @return `ZoomTargetSetup` ~ Current instance for chaining.
	 */
	public function remove(?tag:String, ?func:Void->TargetSetup<Float>):ZoomTargetSetup {
		if (tag == null) {
			if ([for (func2 in setup) Reflect.compare(func, func2) == 0].contains(true))
				setup.remove(func);
		} else {
			if (named.exists(tag))
				named.remove(tag);
		}
		return this;
	}

	/**
	 * Returns the final value that adds or multiplies all the targets together.
	 * @param includeMain If false, it won't include the main target in the calculations.
	 * @return `Float` ~ The final calculation.
	 */
	public function getFinalValue(includeMain:Bool = true):TargetSetup<Float> {
		var result:TargetSetup<Float> = loadTargets(includeMain);

		var points:Array<TargetSetup<Float>> = [];
		for (func in setup)
			points.push(func());
		for (func in named)
			points.push(func());

		for (target in points) {
			if (target.multiply) {
				result.target *= target.target ?? 1;
				result.lerp *= target.lerp;
				result.mult *= target.mult;
			} else {
				result.target += target.target ?? 0;
				result.lerp += target.lerp;
				result.mult += target.mult;
			}
		}

		return result;
	}

	/**
	 * Resets certain data.
	 */
	public function reset():Void {
		setup = [];
		named.clear();
	}
}

class BaseCamera extends FlxCamera {
	/**
	 * The camera **id**, used for debugging purposes.
	 */
	public var id(default, null):String;

	/**
	 * The camera follow targets.
	 */
	public var followTargets(default, null):FollowTargetSetup;
	/**
	 * The camera zoom targets.
	 */
	public var zoomTargets(default, null):ZoomTargetSetup;

	inline override function set_followLerp(value:Float):Float
		return followLerp = FlxMath.bound(value, 0, value);

	/**
	 * The camera follow multiplier.
	 */
	public var followSpeed(default, set):Float = 1;
	inline function set_followSpeed(value:Float):Float
		return followSpeed = FlxMath.bound(value, 0, value);

	/**
	 * Used to smoothly zoom the camera.
	 */
	public var zoomLerp(default, set):Float = 1;
	inline function set_zoomLerp(value:Float):Float
		return zoomLerp = FlxMath.bound(value, 0, value);
	/**
	 * The camera zoom multiplier.
	 */
	public var zoomSpeed(default, set):Float = 1;
	inline function set_zoomSpeed(value:Float):Float
		return zoomSpeed = FlxMath.bound(value, 0, value);
	/**
	 * Whenever target zooming is enabled. Defaults to `false`.
	 */
	public var zoomEnabled:Bool = false;

	/**
	 * The default zoom to lerp to when **zoomEnabled** is true.
	 */
	public var defaultZoom:Float = 1;

	override public function new(id:String = 'Unknown', x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, zoom:Float = 0) {
		this.id = id;
		super(x, y, width, height, zoom);
		defaultZoom = this.zoom;
		initVars();
	}

	@:noCompletion function initVars():Void {
		followTargets = new FollowTargetSetup(
			(includeMain:Bool) -> {
				var pos:Position = new Position();
				if (includeMain && target != null) {
					pos.x += target.x;
					pos.y += target.y;
				}
				pos.x += targetOffset.x;
				pos.y += targetOffset.y;
				return new TargetSetup<CameraTarget>(pos, followLerp, followSpeed);
			}
		);
		zoomTargets = new ZoomTargetSetup(
			(includeMain:Bool) -> {
				return new TargetSetup<Float>(includeMain ? 1 : defaultZoom, zoomLerp, zoomSpeed);
			}
		);
	}

	override public function update(elapsed:Float):Void {
		if (zoomEnabled && !paused)
			updateZoom(elapsed);
		super.update(elapsed);
	}

	override public function updateFollow():Void {
		if (deadzone == null) {
			target.getMidpoint(_point);
			_point.addPoint(followTargets.getFinalValue(false).target.toFlxPoint());
			focusOn(_point);
		} else {
			var edge:Float;
			var finalValue:TargetSetup<CameraTarget> = followTargets.getFinalValue();
			var targetPosition:Position = finalValue.target;
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

			/* if (target is Character) {
				var camPos:Position = cast(target, Character).getCamPos();
				_lastTargetPosition ??= FlxPoint.get(camPos.x, camPos.y);

				_scrollTarget.x += (camPos.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (camPos.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = camPos.x;
				_lastTargetPosition.y = camPos.y;
			} else */ if (target is FlxSprite) {
				_lastTargetPosition ??= FlxPoint.get(target.x, target.y);

				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}

			if ((followLerp * followSpeed) == Math.POSITIVE_INFINITY)
				scroll.copyFrom(_scrollTarget);
			else {
				scroll.x = FunkinUtil.lerp(scroll.x, _scrollTarget.x, finalValue.lerp * finalValue.mult);
				scroll.y = FunkinUtil.lerp(scroll.y, _scrollTarget.y, finalValue.lerp * finalValue.mult);
			}
		}
	}

	/**
	 * Updates the camera zoom.
	 * @param elapsed The elapsed time between frames.
	 */
	public function updateZoom(elapsed:Float):Void {
		var finalValue:TargetSetup<Float> = zoomTargets.getFinalValue();
		zoom = FunkinUtil.lerp(zoom, finalValue.target, finalValue.lerp * finalValue.mult);
	}

	// @:deprecated('Use setFollow instead.') // override used just for this lol
	@:noCompletion override public function follow(target:FlxObject, ?style:FlxCameraFollowStyle, ?lerp:Float):Void
		super.follow(target, style, lerp);

	/**
	 * Snaps the camera to the default zoom.
	 */
	inline public function snapZoom():Void
		zoom = zoomTargets.getFinalValue().target;

	/**
	 * Sets the main follow data.
	 * @param target The main target object to follow.
	 * @param lerp The lerp amount.
	 * @param speed The lerp multiplier.
	 * @param style The camera follow style.
	 * @param resetOffsets If true, it will clear all offsets.
	 */
	inline public function setFollow(target:FlxObject, lerp:Float = 0.2, speed:Float = 1, style:FlxCameraFollowStyle = LOCKON, resetOffsets:Bool = false):Void {
		if (resetOffsets) followTargets.reset();
		follow(target, style, lerp ?? 60);
		followSpeed = speed;
	}
	/**
	 * Adds extra follow data.
	 * @param target The extra target object to follow.
	 * @param lerp The lerp amount.
	 * @param speed The lerp multiplier.
	 */
	inline public function addFollow(target:CameraTarget, lerp:Float = 0.2, speed:Float = 1):Void {
		if (target == targetOffset) {
			log('$id: The cameras "targetOffset" variable is already in use, you don\'t need to add it again.', WarningMessage);
			return;
		}
		followTargets.add(() -> return new TargetSetup<CameraTarget>(target, lerp, speed));
	}

	/**
	 * Sets the main zooming data.
	 * @param target The target zoom to follow.
	 * @param lerp The lerp amount.
	 * @param speed The lerp multiplier.
	 * @param resetOffsets If true, it will clear all offsets.
	 */
	inline public function setZooming(target:Float, lerp:Float = 0.16, speed:Float = 1, resetOffsets:Bool = false):Void {
		if (resetOffsets) zoomTargets.reset();
		defaultZoom = target;
		zoomLerp = lerp;
		zoomSpeed = speed;
	}
	/**
	 * Adds extra zooming data.
	 * @param target A multiplier for target zoom.
	 * @param lerp The lerp amount.
	 * @param speed The lerp multiplier.
	 */
	inline public function addZooming(target:Float, lerp:Float = 0.16, speed:Float = 1):Void
		zoomTargets.add(() -> return new TargetSetup<Float>(target, lerp, speed));
}