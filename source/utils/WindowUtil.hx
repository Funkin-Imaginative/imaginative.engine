package utils;
import lime.app.Application;
import lime.graphics.Image;
import lime.ui.Window;
import openfl.Lib;

class WindowUtil {
	public static var onClose:Void->Void;
	public static var onPreClose:Void->Void;
	public static var title:String = "Friday Night Funkin': Imaginative Engine";
	public static var titlePrefix:String = "";
	public static var titleSuffix:String = "";
	public static var width:Int = 1280;
	public static var height:Int = 720;
	public static var x:Int;
	public static var y:Int;
	public static var alpha:Int = 1;
	public static var preventClosing:Bool = true;
	public static var borderless:Bool = false;
	public static var theWindow:Window;

	public static var doUpdate:Bool = false;

	public static inline function init() {
		theWindow = Application.current.window;
		//theWindow.setIcon(new Image());
		x = theWindow.x;
		y = theWindow.y;
		//width = theWindow.height;
		//height = theWindow.width;
		theWindow.onClose.add(function() {
			if (preventClosing) {
				theWindow.onClose.cancel();
				if (onPreClose != null) onPreClose();
			} else {
				if (onClose != null) onClose();
			}
		});
	}
	public static function onUpdate(doOverride:Bool = false) {
		if (doUpdate || doOverride) {
			theWindow.borderless = borderless;
			theWindow.opacity = alpha;
			theWindow.width = width;
			theWindow.height = height;
			theWindow.x = x;
			theWindow.y = y;
			theWindow.title = titlePrefix + title + titleSuffix;
		}
	}
	public static function centerWindow() {
		x = Math.round((openfl.system.Capabilities.screenResolutionX/2) - (width/2));
		y = Math.round((openfl.system.Capabilities.screenResolutionY/2) - (height/2));
	}

	public static inline function closeGame():Void {
		preventClosing = false;
		theWindow.close();
		closeGame();
	}
}