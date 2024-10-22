package backend.system;

import lime.app.Application;
import lime.ui.Window;
import openfl.system.Capabilities;

typedef TitleParts = {
	/**
	 * Prefix part of the title.
	 */
	var prefix:String;
	/**
	 * Main part of the title.
	 */
	var main:String;
	/**
	 * Suffix part of the title.
	 */
	var suffix:String;
}

/**
 * Used to help FlxWindow's do nice movement.
 */
@:allow(backend.system.FlxWindow)
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
		makeSolid(Math.ceil(parent.width), Math.ceil(parent.height));
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

class FlxWindow implements IFlxDestroyable {
	/**
	 * If true, the window can close.
	 */
	public var allowClose:Bool = true;
	/**
	 * What happens before the window closes.
	 */
	public var onPreClose:FlxWindow->Void;
	/**
	 * What happens as the window closes.
	 */
	public var onClose:FlxWindow->Void;

	/**
	 * The title of the window.
	 */
	public var title(default, set):TitleParts = {
		prefix: '',
		main: '',
		suffix: ''
	}
	inline function set_title(value:TitleParts):TitleParts {
		self.title = title.prefix + title.main + title.suffix;
		return title = value;
	}

	// TODO: Finish this.
	public var relPos(default, null):FlxCallbackPoint;

	/**
	 * The width of the monitor resolution.
	 */
	public var __x(get, never):Float;
	inline function get___x():Float
		return Capabilities.screenResolutionX;

	/**
	 * The x position of the window.
	 */
	public var x(get, set):Float;
	inline function get_x():Float
		return self.x;
	inline function set_x(value:Float):Float
		return self.x = Math.ceil(value);

	/**
	 * The height of the monitor resolution.
	 */
	public var __y(get, never):Float;
	inline function get___y():Float
		return Capabilities.screenResolutionY;

	/**
	 * The y position of the window.
	 */
	public var y(get, set):Float;
	inline function get_y():Float
		return self.y;
	inline function set_y(value:Float):Float
		return self.y = Math.ceil(value);

	/**
	 * Used for the bounds.
	 */
	public var __width(default, null):Float;

	/**
	 * How wide the window is.
	 */
	public var width(get, set):Float;
	inline function get_width():Float
		return self.width;
	inline function set_width(value:Float):Float
		return self.width = Math.ceil(value);

	/**
	 * Used for the bounds.
	 */
	public var __height(default, null):Float;

	/**
	 * How tall the window is.
	 */
	public var height(get, set):Float;
	inline function get_height():Float
		return self.height;
	inline function set_height(value:Float):Float
		return self.height = Math.ceil(value);

	/**
	 * How much the window is visible.
	 */
	public var alpha(get, set):Float;
	inline function get_alpha():Float
		return self.opacity;
	inline function set_alpha(value:Float):Float
		return self.opacity = value;

	/**
	 * If false, the window can't be seen.
	 */
	public var visible(get, set):Bool;
	inline function get_visible():Bool
		return self.hidden;
	inline function set_visible(value:Bool):Bool
		return @:privateAccess self.__hidden = value;

	/**
	 * If true, the window will fullscreen using borderless instead.
	 */
	public static var borderlessFullscreen:Bool = false;

	var _fullscreen:Bool = false;
	/**
	 * If true, the window will fullscreen.
	 */
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool {
		return self.fullscreen;
	}
	inline function set_fullscreen(value:Bool):Bool {
		return self.fullscreen = value;
	}

	/**
	 * If true, the window won't have a border.
	 */
	public var borderless(get, set):Bool;
	inline function get_borderless():Bool
		return self.borderless;
	inline function set_borderless(value:Bool):Bool
		return self.borderless = value;

	/**
	 * The main window.
	 */
	public static var direct(default, null):FlxWindow;
	/**
	 * The lime window the class is attached to.
	 */
	public var self(default, null):Window;

	/**
	 * The bounds of the window. Good for interesting window movement.
	 */
	public var bounds:WindowBounds;

	@:allow(backend.system.Main)
	static function init():Void {
		FlxWindow.direct = new FlxWindow(Application.current.window, Application.current.meta.get('title'));
	}

	/**
	 * Attaches a lime window to this custom flx window.
	 * @param window If you have a window already just attach your lime window to this flx one!
	 * @param startTitle Set the starting title!
	 */
	public function new(window:Window, ?startTitle:String):Void {
		self = window;
		bounds = new WindowBounds(this);
		relPos = new FlxCallbackPoint(
			(point:FlxPoint) -> x = point.x,
			(point:FlxPoint) -> y = point.y,
			(point:FlxPoint) -> {}
		);

		title.main = startTitle.getDefault(self.title);
		__width = width;
		__height = height;

		self.onClose.add(() -> {
			if (allowClose) {
				if (onPreClose != null) onPreClose(this);
				if (onClose != null) onClose(this);
				bounds.destroy();
			} else self.onClose.cancel();
		});
	}

	/**
	 * Moves the window to the center of the screen.
	 */
	public function centerWindow():Void {
		x = Math.round((__x / 2) - (width / 2));
		y = Math.round((__y / 2) - (height / 2));
	}

	/**
	 * Closes this window instance.
	 */
	public function destroy():Void
		self.close();
}