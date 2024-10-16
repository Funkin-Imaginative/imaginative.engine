package backend.system;

import lime.app.Application;
import lime.ui.Window;
import openfl.system.Capabilities;

typedef TitleParts = {
	var prefix:String;
	var main:String;
	var suffix:String;
}

@:allow(backend.system.FlxWindow)
class WindowBounds extends FlxSprite {
	public var parent:FlxWindow;

	/**
	 * Recommended for cool window movement shiz.
	 */
	public var forceBounds:Bool = false;

	override function new(parent:FlxWindow) {
		this.parent = parent;
		super(parent.x, parent.y);
		makeSolid(Math.ceil(parent.width), Math.ceil(parent.height));
		FlxG.signals.postUpdate.add(() -> boundUpdate(FlxG.elapsed));
	}

	override function destroy():Void {
		FlxG.signals.postUpdate.remove(() -> boundUpdate(FlxG.elapsed));
		super.destroy();
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
}

class FlxWindow implements IFlxDestroyable {
	public var allowClose:Bool = true;
	public var onPreClose:FlxWindow->Void;
	public var onClose:FlxWindow->Void;

	public var title(default, set):TitleParts = {
		prefix: '',
		main: '',
		suffix: ''
	}
	inline function set_title(value:TitleParts):TitleParts {
		self.title = title.prefix + title.main + title.suffix;
		return title = value;
	}

	/**
	 * WIP
	 */
	public var relPos(default, null):FlxCallbackPoint;

	public var __x(get, never):Float;
	inline function get___x():Float
		return Capabilities.screenResolutionX;

	public var x(get, set):Float;
	inline function get_x():Float
		return self.x;
	inline function set_x(value:Float):Float
		return self.x = Math.ceil(value);

	public var __y(get, never):Float;
	inline function get___y():Float
		return Capabilities.screenResolutionY;

	public var y(get, set):Float;
	inline function get_y():Float
		return self.y;
	inline function set_y(value:Float):Float
		return self.y = Math.ceil(value);

	public var __width(default, null):Float;

	public var width(get, set):Float;
	inline function get_width():Float
		return self.width;
	inline function set_width(value:Float):Float {
		// if (!bounds.forceBounds) __width = Math.ceil(value);
		return self.width = Math.ceil(value);
	}

	public var __height(default, null):Float;

	public var height(get, set):Float;
	inline function get_height():Float
		return self.height;
	inline function set_height(value:Float):Float {
		// if (!bounds.forceBounds) __height = Math.ceil(value);
		return self.height = Math.ceil(value);
	}

	public var alpha(get, set):Float;
	inline function get_alpha():Float
		return self.opacity;
	inline function set_alpha(value:Float):Float
		return self.opacity = value;

	public var visible(get, set):Bool;
	inline function get_visible():Bool
		return self.hidden;
	inline function set_visible(value:Bool):Bool
		return @:privateAccess self.__hidden = value;

	public static var borderlessFullscreen:Bool = false;

	var _fullscreen:Bool = false;
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool {
		return self.fullscreen;
	}
	inline function set_fullscreen(value:Bool):Bool {
		return self.fullscreen = value;
	}

	public var borderless(get, set):Bool;
	inline function get_borderless():Bool
		return self.borderless;
	inline function set_borderless(value:Bool):Bool
		return self.borderless = value;

	public static var direct(default, null):FlxWindow;
	public var self(default, null):Window;

	public var bounds:WindowBounds;

	@:allow(backend.system.Main)
	static function init():Void {
		FlxWindow.direct = new FlxWindow(Application.current.window, Application.current.meta.get('title'));
	}

	/**
	 * Makes a new window unless you give it one.
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

		title.main = startTitle == null ? self.title : startTitle;
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

	public function centerWindow():Void {
		x = Math.round((__x / 2) - (width / 2));
		y = Math.round((__y / 2) - (height / 2));
	}

	public function destroy():Void
		self.close();
}