package imaginative.backend;

import flixel.input.keyboard.FlxKey;

// TODO: Rewrite variable documentation and names for this class.
/**
 * This class handles user controls. Without it, how would you do anything?
 */
class Controls implements IFlxDestroyable {
	/**
	 * Player 1's controls.
	 */
	public static var p1(default, null):Controls = new Controls();
	/**
	 * Player 2's controls.
	 */
	public static var p2(default, null):Controls = new Controls();

	/**
	 * Used for arrow field's when it's not maintained by a player.
	 */
	public static var blank(default, null):Controls = new Controls();

	// UI
	/**
	 * When you press left to move through ui elements
	 */
	public static var uiLeft(get, never):Bool;
	inline static function get_uiLeft():Bool
		return globalPressed('uiLeft');
	/**
	 * When you press down to move through ui elements
	 */
	public static var uiDown(get, never):Bool;
	inline static function get_uiDown():Bool
		return globalPressed('uiDown');
	/**
	 * When you press up to move through ui elements
	 */
	public static var uiUp(get, never):Bool;
	inline static function get_uiUp():Bool
		return globalPressed('uiUp');
	/**
	 * When you press right to move through ui elements
	 */
	public static var uiRight(get, never):Bool;
	inline static function get_uiRight():Bool
		return globalPressed('uiRight');

	/**
	 * When you hold left to move through ui elements
	 */
	public static var uiLeftPress(get, never):Bool;
	inline static function get_uiLeftPress():Bool
		return globalHeld('uiLeft');
	/**
	 * When you hold down to move through ui elements
	 */
	public static var uiDownPress(get, never):Bool;
	inline static function get_uiDownPress():Bool
		return globalHeld('uiDown');
	/**
	 * When you hold up to move through ui elements
	 */
	public static var uiUpPress(get, never):Bool;
	inline static function get_uiUpPress():Bool
		return globalHeld('uiUp');
	/**
	 * When you hold up to move through ui elements
	 */
	public static var uiRightPress(get, never):Bool;
	inline static function get_uiRightPress():Bool
		return globalHeld('uiRight');

	/**
	 * When you release left to move through ui elements
	 */
	public static var uiLeftReleased(get, never):Bool;
	inline static function get_uiLeftReleased():Bool
		return globalReleased('uiLeft');
	/**
	 * When you release down to move through ui elements
	 */
	public static var uiDownReleased(get, never):Bool;
	inline static function get_uiDownReleased():Bool
		return globalReleased('uiDown');
	/**
	 * When you release up to move through ui elements
	 */
	public static var uiUpReleased(get, never):Bool;
	inline static function get_uiUpReleased():Bool
		return globalReleased('uiUp');
	/**
	 * When you release right to move through ui elements
	 */
	public static var uiRightReleased(get, never):Bool;
	inline static function get_uiRightReleased():Bool
		return globalReleased('uiRight');

	// Controls
	/**
	 * Left note press.
	 */
	public var noteLeft(get, never):Bool;
	inline function get_noteLeft():Bool
		return pressed('noteLeft');
	/**
	 * Down note press.
	 */
	public var noteDown(get, never):Bool;
	inline function get_noteDown():Bool
		return pressed('noteDown');
	/**
	 * Up note press
	 */
	public var noteUp(get, never):Bool;
	inline function get_noteUp():Bool
		return pressed('noteUp');
	/**
	 * Right note press.
	 */
	public var noteRight(get, never):Bool;
	inline function get_noteRight():Bool
		return pressed('noteRight');

	/**
	 * Left note held.
	 */
	public var noteLeftHeld(get, never):Bool;
	inline function get_noteLeftHeld():Bool
		return held('noteLeft');
	/**
	 * Down note held.
	 */
	public var noteDownHeld(get, never):Bool;
	inline function get_noteDownHeld():Bool
		return held('noteDown');
	/**
	 * Up note held.
	 */
	public var noteUpHeld(get, never):Bool;
	inline function get_noteUpHeld():Bool
		return held('noteUp');
	/**
	 * Right note held.
	 */
	public var noteRightHeld(get, never):Bool;
	inline function get_noteRightHeld():Bool
		return held('noteRight');

	/**
	 * Left note released.
	 */
	public var noteLeftReleased(get, never):Bool;
	inline function get_noteLeftReleased():Bool
		return released('noteLeft');
	/**
	 * Down note released.
	 */
	public var noteDownReleased(get, never):Bool;
	inline function get_noteDownReleased():Bool
		return released('noteDown');
	/**
	 * Up note released.
	 */
	public var noteUpReleased(get, never):Bool;
	inline function get_noteUpReleased():Bool
		return released('noteUp');
	/**
	 * Right note released.
	 */
	public var noteRightReleased(get, never):Bool;
	inline function get_noteRightReleased():Bool
		return released('noteRight');

	// Actions
	/**
	 * When accept is pressed.
	 */
	public static var accept(get, never):Bool;
	inline static function get_accept():Bool
		return globalPressed('accept');
	/**
	 * When back is pressed.
	 */
	public static var back(get, never):Bool;
	inline static function get_back():Bool
		return globalPressed('back');
	/**
	 * When paused is pressed.
	 */
	public static var pause(get, never):Bool;
	inline static function get_pause():Bool
		return globalPressed('pause');
	/**
	 * When reset is pressed.
	 */
	public static var reset(get, never):Bool;
	inline static function get_reset():Bool
		return globalPressed('reset');

	// Extras
	/**
	 * When fullscreen is pressed.
	 */
	public static var fullscreen(get, never):Bool;
	inline static function get_fullscreen():Bool
		return globalPressed('fullscreen');

	// Debug
	/**
	 * When botplay is pressed.
	 */
	public static var botplay(get, never):Bool;
	inline static function get_botplay():Bool
		return globalPressed('botplay');
	/**
	 * When resetState is pressed.
	 */
	public static var resetState(get, never):Bool;
	inline static function get_resetState():Bool
		return globalPressed('resetState');
	/**
	 * When shortcutState is pressed.
	 */
	public static var shortcutState(get, never):Bool;
	inline static function get_shortcutState():Bool
		return globalPressed('shortcutState');
	/**
	 * When reloadGlobalScripts is pressed.
	 */
	public static var reloadGlobalScripts(get, never):Bool;
	inline static function get_reloadGlobalScripts():Bool
		return globalPressed('reloadGlobalScripts');

	// The Main Powerhouses
	/**
	 * The global binds, mostly for stuff like menus so more like shared binds.
	 */
	public static var globalBinds:Map<String, Array<FlxKey>> = [
		// UI //
		'uiLeft' => [A, LEFT],
		'uiDown' => [S, DOWN],
		'uiUp' => [W, UP],
		'uiRight' => [D, RIGHT],

		// Actions //
		'accept' => [ENTER, SPACE],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, DELETE],

		// Volume //
		'volumeUp' => [PLUS, NUMPADPLUS],
		'volumeDown' => [MINUS, NUMPADMINUS],
		'volumeMute' => [ZERO, NUMPADZERO],

		// Extras //
		'fullscreen' => [F11],

		// Debug //
		'botplay' => [F4],
		'resetState' => [F5],
		'shortcutState' => [F6],
		'reloadGlobalScripts' => [F7]
	];
	/**
	 * Global pressed input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public static function globalPressed(key:String):Bool
		return FlxG.keys.anyJustPressed(globalBinds[key]);
	/**
	 * Global held input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public static function globalHeld(key:String):Bool
		return FlxG.keys.anyPressed(globalBinds[key]);
	/**
	 * Global released input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public static function globalReleased(key:String):Bool
		return FlxG.keys.anyJustReleased(globalBinds[key]);

	/**
	 * The binds, these binds are per controls set.
	 */
	public var setBinds:Map<String, Array<FlxKey>>;
	/**
	 * Pressed input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public function pressed(key:String):Bool
		return FlxG.keys.anyJustPressed(setBinds[key]);
	/**
	 * Held input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public function held(key:String):Bool
		return FlxG.keys.anyPressed(setBinds[key]);
	/**
	 * Released input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public function released(key:String):Bool
		return FlxG.keys.anyJustReleased(setBinds[key]);

	inline public function new() {
		setBinds = [
			// Controls //
			'noteLeft' => [E, LEFT],
			'noteDown' => [F, DOWN],
			'noteUp' => [K, UP],
			'noteRight' => [O, RIGHT]
		];
		if (this == blank)
			setBinds.clear();
	}

	/**
	 * When called it destroys the controls instance.
	 */
	inline public function destroy():Void
		setBinds.clear();
}