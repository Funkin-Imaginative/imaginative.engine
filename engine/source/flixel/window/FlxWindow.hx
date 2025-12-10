package flixel.window;

import lime.app.Application;
import lime.ui.Window;

/**
 * Used for automatically updating the window title.
 */
class TitleParts {
	/**
	 * Self explanatory.
	 */
	var parentWindow:FlxWindow;

	/**
	 * Dispatches when a title part is updated.
	 */
	public var onPartUpdate:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();
	/**
	 * The item that shows up between each title part.
	 */
	public var partJoiner(default, set):String = ' ';
	inline function set_partJoiner(value:String):String {
		partJoiner = value;
		onPartUpdate.dispatch(toString());
		return value;
	}

	/**
	 * Prefix part of the title.
	 */
	public var prefix(default, set):String;
	inline function set_prefix(value:String):String {
		prefix = value;
		onPartUpdate.dispatch(toString());
		return value;
	}
	/**
	 * Main part of the title.
	 */
	public var main(default, set):String;
	inline function set_main(value:String):String {
		main = value;
		onPartUpdate.dispatch(toString());
		return value;
	}
	/**
	 * Suffix part of the title.
	 */
	public var suffix(default, set):String;
	inline function set_suffix(value:String):String {
		suffix = value;
		onPartUpdate.dispatch(toString());
		return value;
	}

	@:allow(flixel.window.FlxWindow)
	inline function new(parent:FlxWindow, title:String) {
		parentWindow = parent;
		onPartUpdate.add((title:String) -> parent.self.title = title);
		main = title;
	}

	public function toString():String {
		var result:Array<String> = [];
		for (i in 0...2) {
			var part:String = [prefix, main, suffix][i] ?? '';
			if (!part.isNullOrEmpty())
				result.push(part);
		}
		return result.join(partJoiner);
	}
}

/**
 * Flixel doesn't have a window class so... I made one myself!
 */
@:access(lime.ui.Window)
class FlxWindow implements IFlxDestroyable {
	/**
	 * If true the window can close.
	 */
	public var allowClose:Bool = true;
	/**
	 * What happens before the window closes.
	 */
	public var onPreClose:FlxTypedSignal<(FlxWindow, ScriptEvent) -> Void> = new FlxTypedSignal<(FlxWindow, ScriptEvent) -> Void>();
	/**
	 * What happens when the window closes.
	 */
	public var onClose:FlxTypedSignal<(FlxWindow, ScriptEvent) -> Void> = new FlxTypedSignal<(FlxWindow, ScriptEvent) -> Void>();

	/**
	 * The title of the window.
	 */
	public var title:TitleParts;

	// TODO: Finish this.
	public var relPos(default, null):FlxCallbackPoint;

	/**
	 * The width of the monitor resolution the window resides in.
	 */
	public var monitorWidth(get, never):Float;
	inline function get_monitorWidth():Float
		return self.display.bounds.width;
	/**
	 * The height of the monitor resolution the window resides in.
	 */
	public var monitorHeight(get, never):Float;
	inline function get_monitorHeight():Float
		return self.display.bounds.height;

	/**
	 * The x position of the window.
	 */
	public var x(get, set):Float;
	inline function get_x():Float
		return self.x;
	inline function set_x(value:Float):Float
		return self.x = Math.ceil(value);
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
	 * Used for the bounds.
	 */
	public var __height(default, null):Float;

	/**
	 * How wide the window is.
	 */
	public var width(get, set):Float;
	inline function get_width():Float
		return self.width;
	inline function set_width(value:Float):Float
		return self.width = Math.ceil(value);
	/**
	 * How tall the window is.
	 */
	public var height(get, set):Float;
	inline function get_height():Float
		return self.height;
	inline function set_height(value:Float):Float
		return self.height = Math.ceil(value);

	/**
	 * The window opacity.
	 */
	public var alpha(get, set):Float;
	inline function get_alpha():Float
		return self.opacity;
	inline function set_alpha(value:Float):Float
		return self.opacity = value;

	/**
	 * If false the window can't be seen.
	 */
	public var hidden(get, set):Bool;
	inline function get_hidden():Bool
		return self.hidden;
	inline function set_hidden(value:Bool):Bool
		return self.__hidden = value;

	// TODO: Code this in!
	/**
	 * If true the window will fullscreen using borderless instead.
	 */
	public var borderlessFullscreen:Bool = false;

	var _fullscreen:Bool = false;
	/**
	 * If true the window will fullscreen.
	 */
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool
		return _fullscreen;
	inline function set_fullscreen(value:Bool):Bool {
		_fullscreen = value;
		self.fullscreen = borderlessFullscreen ? false : _fullscreen;
		#if EDIT_WINDOW_BORDER_COLOR
		hxwindowmode.WindowColorMode.setWindowCornerType(borderlessFullscreen && _fullscreen ? 1 : 0);
		hxwindowmode.WindowColorMode.redrawWindowHeader();
		#end
		return value;
	}

	/**
	 * If true the window won't have a border.
	 */
	public var borderless(get, set):Bool;
	inline function get_borderless():Bool
		return self.borderless;
	inline function set_borderless(value:Bool):Bool
		return self.borderless = value;

	/**
	 * The main window instance.
	 */
	public static var instance(default, null):FlxWindow;
	/**
	 * The "lime" window the 'FlxWindow' instance is attached to.
	 */
	public var self(default, null):Window;

	/**
	 * The bounds of the window. Good for interesting window movement.
	 */
	public var bounds:WindowBounds;

	@:allow(imaginative.backend.system.Main.new)
	inline static function init():Void {
		FlxWindow.instance = new FlxWindow(Application.current.window, Application.current.meta.get('title'));
		imaginative.backend.system.Native.fixScaling();
	}

	/**
	 * Attaches a "lime" window to this 'FlxWindow' instance.
	 * @param window If you have a window already just attach your "lime" window to this 'FlxWindow'!
	 * @param startTitle The starting title.
	 */
	public function new(window:Window, ?startTitle:String):Void {
		self = window;
		bounds = new WindowBounds(this);
		relPos = new FlxCallbackPoint(
			(point:FlxPoint) -> x = point.x,
			(point:FlxPoint) -> y = point.y,
			(point:FlxPoint) -> {}
		);

		title = new TitleParts(this, startTitle ?? self.title ?? 'No Title Entered');
		__width = width;
		__height = height;

		#if EDIT_WINDOW_BORDER_COLOR
		hxwindowmode.WindowColorMode.setDarkMode();
		hxwindowmode.WindowColorMode.redrawWindowHeader();
		#end

		self.onClose.add(() -> {
			if (allowClose) {
				var event:ScriptEvent = new ScriptEvent();
				onPreClose.dispatch(this, event);
				if (!event.prevented) {
					onClose.dispatch(this, event);
					if (event.prevented)
						self.onClose.cancel();
					else destroy();
				}
			} else self.onClose.cancel();
		});
	}

	/**
	 * Centers this 'FlxWindow' on the screen, either by the x axis, y axis, or both.
	 * @param axes On what axes to center the object (e.g. "X", "Y", "XY"), default is both.
	 * @return FlxWindow ~ Current instance for chaining.
	 */
	inline public function screenCenter(axes:FlxAxes = XY):FlxWindow {
		if (axes.x) x = (monitorWidth - width) / 2;
		if (axes.y) y = (monitorHeight - height) / 2;
		return this;
	}

	/**
	 * Helper function to set the coordinates of this window.
	 * Handy since it only requires one line of code.
	 * @param x The new x position.
	 * @param y The new y position.
	 */
	inline public function setPosition(?x:Float, ?y:Float):Void {
		if (x == null) screenCenter(X); else this.x = x;
		if (y == null) screenCenter(Y); else this.y = y;
	}

	/**
	 * Shortcut for setting both the window width and Height.
	 * @param width The new window width.
	 * @param height The new window height.
	 */
	inline public function setSize(width:Float, height:Float):Void {
		this.width = width;
		this.height = height;
	}

	/**
	 * Attempts to close this window instance.
	 * I say attempts of the "allowClose" shenanigans.
	 */
	inline public function close():Void
		self.close();
	/**
	 * Is called when this window instance gets destroyed.
	 */
	inline public function destroy():Void {
		title.onPartUpdate.destroy();
		bounds.destroy();
	}

	inline public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('title', title)
		]);
	}
}