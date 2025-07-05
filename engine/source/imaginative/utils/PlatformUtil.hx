package imaginative.utils;

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
			log('$url', SystemMessage);
			return true;
		} catch(error:haxe.Exception)
			log(error.message, ErrorMessage);
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
			return FlxG.mouse._prevViewX != FlxG.mouse.viewX || FlxG.mouse._prevViewY != FlxG.mouse.viewY;
		else
			return FlxG.mouse.justMoved;
	}
}