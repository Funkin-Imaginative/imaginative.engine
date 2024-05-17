package fnf.utils;

class PlayUtil {
	public static var botplay(get, default):Bool = false;
	private static function get_botplay():Bool return enableP2 ? false : botplay;
	public static var opponentPlay:Bool = false;
	public static var enableP2:Bool = false; // prevents botplay btw
}