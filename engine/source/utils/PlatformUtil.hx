package utils;

/**
 * Used for when certain stuff doesn't account for platform differences.
 */
class PlatformUtil {
	/**
	 * Opens a URL in your browser.
	 * @param url The url.
	 * @return `Bool` ~ If it opened, this returns true.
	 */
	public static function openURL(url:String):Bool {
		try {
			lime.system.System.openURL(url);
			trace('$url');
			return true;
		} catch(error:haxe.Exception)
			trace(error.message);
		return false;
	}

	/**
	 * Detects if your mouse moved.
	 * @param relativeToScreen If true, this function does it's specialty!
	 * @return `Bool`
	 */
	@:access(flixel.input.mouse.FlxMouse)
	inline public static function mouseJustMoved(relativeToScreen:Bool = true):Bool {
		if (relativeToScreen)
			return FlxG.mouse._prevScreenX != FlxG.mouse.screenX || FlxG.mouse._prevScreenY != FlxG.mouse.screenY;
		else
			return FlxG.mouse.justMoved;
	}
}