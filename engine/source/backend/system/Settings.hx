package backend.system;

/**
 * Framerate cap types.
 */
enum abstract FpsType(String) from String to String {
	/**
	 * Allows the fpsCap Int to take affect.
	 */
	var Custom;
	/**
	 * Makes the fps go as high as it possibly can!
	 */
	var Unlimited;
	/**
	 * It's like `Unlimited`, expect your capped at your screens refresh rate.
	 */
	var Vsync;
}

/*
   This class at first was jokingly named "PullingAPsychEngine".
   While coding this file I realized how much I was pulling a psych engine.
*/
/**
 * The main settings for the engine.
 */
@:structInit class MainSettings {
	#if MOD_SUPPORT
	/**
	 * If true, this is like enabling soloOnlyMode in Modding.
	 */
	public var soloOnly:Bool = false;
	#end

	/**
	 * If you have epilepsy please have this setting on.
	 */
	public var lightSensitive:Bool = true;
	/**
	 * If true, the game will pause when you click off.
	 */
	public var autoPause:Bool = true;

	/**
	 * If true, pressing the reset bind doesn't kill you in songs.
	 */
	public var disableDeathBind:Bool = false;
	/**
	 * If true, the gameover screen will hard cut to the confirm animation.
	 */
	public var instantRespawn:Bool = false;

	/**
	 * If true, antialiasing can be applied to things.
	 */
	public var antialiasing(get, default):Bool = true;
	inline function get_antialiasing():Bool
		return qualityLevel > 0.35 ? antialiasing : false;

	/**
	 * This states the level of quality you want the game to display.
	 * `Note: Depending on the quality level it will auto set some options but the engine will still remember your choices.`
	 */
	public var qualityLevel(default, set):Float = 1;
	inline function set_qualityLevel(value:Float):Float
		return qualityLevel = FlxMath.bound(value, 0, 1);
	/**
	 * If true, bigger shaders will be disabled.
	 * `Note: In order for this to work you gotta make sure you do if statement stuff.`
	 */
	public var canDoShaders(get, default):Bool = false;
	inline function get_canDoShaders():Bool
		return qualityLevel > 0.7 ? canDoShaders : false;
	/**
	 * If true, your devices gpu will do all the caching.
	 */
	public var gpuCaching:Bool = false;

	/**
	 * The fps cap you wish to go for.
	 */
	public var fpsCap(default, set):Int = 60;
	inline function set_fpsCap(value:Int):Int
		return fpsCap = Std.int(FlxMath.bound(value, 0, 300));
	/**
	 * The type of fps rendering you wish to use.
	 * Your choices are Custom, Unlimited and Vsync.
	 */
	public var fpsType:FpsType = Custom;

	#if CHECK_FOR_UPDATES
	/**
	 * If true, the engine will check for updates.
	 */
	public var checkForUpdates:Bool = true;
	#end
	/**
	 * If true, your given access to all the tools to make a mod!
	 */
	public var debugMode(get, default):Bool = false;
	inline function get_debugMode():Bool
		return #if debug true #else debugMode #end;
	/**
	 * If true, logs with the `Warning` level won't show up.
	 */
	public var ignoreLogWarnings:Bool = true;
}

/**
 * The settings for each player.
 */
@:structInit class PlayerSettings {
	/**
	 * If true, the strums will be at the bottom of the screen instead of the top.
	 */
	public var downscroll:Bool = false;
	/**
	 * If true, the main player arrow field will be put in the center of the screen.
	 */
	public var middlescroll:Bool = false;

	/**
	 * Basically, do you wish for the characters to repeat their sing anim every time they hit a sustain note?
	 */
	public var beatLoop:Bool = true;
	/**
	 * If true, press shit all you fucking want asshole.
	 */
	public var ghostTapping:Bool = false;

	/**
	 * The timing for the killer rating window.
	 */
	public var killerWindow:Float = 12.5;
	/**
	 * The timing for the sick rating window.
	 */
	public var sickWindow:Float = 45;
	/**
	 * The timing for the good rating window.
	 */
	public var goodWindow:Float = 90;
	/**
	 * The timing for the bad rating window.
	 */
	public var badWindow:Float = 135;
	/**
	 * The timing for the shit rating window.
	 */
	public var shitWindow:Float = 160;
}

/**
 * The class that handles all your settings.
 */
class Settings {
	/**
	 * The current settings.
	 */
	public static var setup(default, set):MainSettings = {}
	inline static function set_setup(value:MainSettings):MainSettings
		return setup = value;
	/**
	 * Default settings.
	 */
	public static var defaults(default, null):MainSettings = {}

	/**
	 * Player 1's settings!
	 */
	public static var setupP1(default, set):PlayerSettings = {}
	inline static function set_setupP1(value:PlayerSettings):PlayerSettings
		return setupP1 = value;
	/**
	 * Default player 1 settings.
	 */
	public static var defaultsP1(default, null):PlayerSettings = {}

	/**
	 * Player 2's settings!
	 */
	public static var setupP2(default, set):PlayerSettings = {}
	inline static function set_setupP2(value:PlayerSettings):PlayerSettings
		return setupP2 = value;
	/**
	 * Default player settings.
	 */
	public static var defaultsP2(default, null):PlayerSettings = {}
}