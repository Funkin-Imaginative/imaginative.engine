package utils;

class PlatformUtil {
	/**
	 * Opens an URL in your browser.
	 * @param url
	 */
	inline public static function openURL(url:String):Void {
		try {
			#if linux
			Sys.command('/usr/bin/xdg-open', [url]);
			#else
			FlxG.openURL(url);
			#end
			trace('$url');
		} catch(e) trace(e);
	}

	inline public static function mouseJustMoved(relativeToScreen:Bool = true):Bool {
		if (relativeToScreen)
			@:privateAccess return FlxG.mouse._prevScreenX != FlxG.mouse.screenX || FlxG.mouse._prevScreenY != FlxG.mouse.screenY;
		else
			return FlxG.mouse.justMoved;
	}
}