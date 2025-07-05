package flixel.window;

/**
 * Used to help FlxWindow's do nice movement.
 * Might just have FlxWindow extend FlxObject or FlxSprite at some point instead.
 */
@:allow(flixel.window.FlxWindow)
class WindowBounds extends FlxSprite {
	/**
	 * The parent window.
	 */
	public var parent:FlxWindow;

	/**
	 * Forces the parent to the bounds state. Recommended for cool window movement.
	 */
	public var forceBounds:Bool = false;

	override public function set_x(value:Float):Float {
		if (x != value || forceBounds) parent.x = value;
		return super.set_x(value);
	}
	override public function set_y(value:Float):Float {
		if (y != value || forceBounds) parent.y = value;
		return super.set_y(value);
	}
	override public function set_width(value:Float):Float {
		if (width != value || forceBounds) parent.width = value;
		return super.set_width(value);
	}
	override public function set_height(value:Float):Float {
		if (height != value || forceBounds) parent.height = value;
		return super.set_height(value);
	}

	override function new(parent:FlxWindow) {
		this.parent = parent;
		super(parent.x, parent.y);
		this.makeSolid(parent.width, parent.height);
		FlxG.signals.postUpdate.add(() -> boundUpdate(FlxG.elapsed));
	}

	function boundUpdate(elapsed:Float):Void {
		if (exists) {
			update(elapsed);
			if (forceBounds) {
				parent.width = Math.min(parent.__width * scale.x, 100);
				parent.height = Math.min(parent.__height * scale.y, 100);
			}
		}
	}

	override function destroy():Void {
		FlxG.signals.postUpdate.remove(() -> boundUpdate(FlxG.elapsed));
		super.destroy();
	}
}