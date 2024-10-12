package backend.system;

import lime.app.Application;
import lime.ui.Window;
import openfl.system.Capabilities;

typedef TitleParts = {
	var prefix:String;
	var main:String;
	var suffix:String;
}

class WindowBounds extends FlxSprite {
	public var parent:FlxWindow;

	override public function new(parent:FlxWindow) {
		this.parent = parent;
		super(parent.x, parent.y);
		makeSolid(Math.ceil(parent.width), Math.ceil(parent.height));
	}

	override function set_x(value:Float):Float return parent.x = x = value;
	override function set_y(value:Float):Float return parent.y = y = value;
	override function set_width(value:Float):Float return parent.width = width = value;
	override function set_height(value:Float):Float return parent.height = height = value;
}

class FlxWindow implements IFlxDestroyable {
	public var preventClosing:Bool = true;
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

	public var x(get, set):Float;
	inline function get_x():Float
		return self.x;
	inline function set_x(value:Float):Float
		return self.x = Math.ceil(value);

	public var y(get, set):Float;
	inline function get_y():Float
		return self.y;
	inline function set_y(value:Float):Float
		return self.y = Math.ceil(value);

	public var width(get, set):Float;
	inline function get_width():Float
		return self.width;
	inline function set_width(value:Float):Float
		return self.width = Math.ceil(value);

	public var height(get, set):Float;
	inline function get_height():Float
		return self.height;
	inline function set_height(value:Float):Float
		return self.height = Math.ceil(value);

	public var alpha(get, set):Float;
	inline function get_alpha():Float
		return self.opacity;
	inline function set_alpha(value:Float):Float
		return self.opacity = value;

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

	public static function init():Void {
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
		title.main = startTitle == null ? self.title : startTitle;
		onPreClose = (window:FlxWindow) -> {
			window.borderless = true;
			FlxTween.tween(window.bounds.scale, {x: 0, y: 0}, 2, {
				ease: FlxEase.elasticIn,
				onComplete: (tween:FlxTween) -> window.destroy()
			});
		}
		self.onClose.add(() -> {
			if (preventClosing) {
				self.onClose.cancel();
				if (onPreClose != null)
					onPreClose(this);
			} else {
				if (onClose != null)
					onClose(this);
			}
		});
	}

	public function centerWindow():Void {
		x = Math.round((Capabilities.screenResolutionX / 2) - (width / 2));
		y = Math.round((Capabilities.screenResolutionY / 2) - (height / 2));
	}

	public function destroy():Void {
		preventClosing = true;
		self.close();
		bounds.destroy();
	}
}