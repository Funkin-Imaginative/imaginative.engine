package imaginative.backend.system;

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

/**
   This class at first was jokingly named "PullingAPsychEngine".
   While coding this file I realized how much I was pulling a psych engine.
**/
/**
 * The main settings for the engine.
 */
class MainSettings {
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
	 * The hud you wish to pick for the default.
	 */
	public var HUDSelection:imaginative.objects.gameplay.hud.HUDType = Imaginative;

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

	@:allow(imaginative.backend.system.Settings) function new() {}
}

/**
 * The settings for each player.
 */
class PlayerSettings {
	/**
	 * If true, the strums will be at the bottom of the screen instead of the top.
	 */
	public var downscroll:Bool = false;
	/**
	 * If true, the main player arrow field will be put in the center of the screen.
	 */
	public var middlescroll:Bool = false;

	/**
	 * Your personal scroll speed value that you enjoy the most!
	 */
	public var personalScrollSpeed:Float = 2.45;
	/**
	 * If true, the personalScrollSpeed setting will override the your current arrow field speed!
	 */
	public var enablePersonalScrollSpeed:Bool = false;

	/**
	 * Basically, do you wish for the characters to repeat their sing anim every time they hit a sustain note?
	 */
	public var stepJitter:Bool = true;
	/**
	 * If true, press shit all you fucking want asshole.
	 */
	public var ghostTapping:Bool = false;

	/**
	 * The timing window cap in milliseconds.
	 */
	public var maxWindow:Float = 230;
	/**
	 * The timing window percent for the killer rating window.
	 */
	public var killerWindow:Float = 0.0543478260869565;
	/**
	 * The timing window percent for the sick rating window.
	 */
	public var sickWindow:Float = 0.195652173913043;
	/**
	 * The timing window percent for the good rating window.
	 */
	public var goodWindow:Float = 0.391304347826087;
	/**
	 * The timing window percent for the bad rating window.
	 */
	public var badWindow:Float = 0.58695652173913;
	/**
	 * The timing window percent for the shit rating window.
	 */
	public var shitWindow:Float = 0.695652173913043;

	/**
	 * If true, missing a note or sustain piece will make you miss that entire note. Otherwise you can miss each note piece.
	 */
	public var missFullSustain:Bool = true;

	@:allow(imaginative.backend.system.Settings) function new() {}
}

/**
 * The class that handles all your settings.
 */
class Settings {
	/**
	 * The current settings.
	 */
	public static var setup(default, set):MainSettings = new MainSettings();
	inline static function set_setup(value:MainSettings):MainSettings
		return setup = value;
	/**
	 * Default settings.
	 */
	public static var defaults(default, null):MainSettings = new MainSettings();

	/**
	 * Player 1's settings!
	 */
	public static var setupP1(default, set):PlayerSettings = new PlayerSettings();
	inline static function set_setupP1(value:PlayerSettings):PlayerSettings
		return setupP1 = value;
	/**
	 * Default player 1 settings.
	 */
	public static var defaultsP1(default, null):PlayerSettings = new PlayerSettings();

	/**
	 * Player 2's settings!
	 */
	public static var setupP2(default, set):PlayerSettings = new PlayerSettings();
	inline static function set_setupP2(value:PlayerSettings):PlayerSettings
		return setupP2 = value;
	/**
	 * Default player settings.
	 */
	public static var defaultsP2(default, null):PlayerSettings = new PlayerSettings();
}