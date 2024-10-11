package backend;

import flixel.input.keyboard.FlxKey;

typedef PressTypes = {
	var pressed:Bool;
	var held:Bool;
	var released:Bool;
}

class Controls implements IFlxDestroyable {
	public static var p1:Controls;
	public static var p2:Controls;

	// UI //
	// Pressed
	public static var uiLeft(get, never):Bool;
	inline static function get_uiLeft():Bool
		return globalPressed('uiLeft');

	public static var uiDown(get, never):Bool;
	inline static function get_uiDown():Bool
		return globalPressed('uiDown');

	public static var uiUp(get, never):Bool;
	inline static function get_uiUp():Bool
		return globalPressed('uiUp');

	public static var uiRight(get, never):Bool;
	inline static function get_uiRight():Bool
		return globalPressed('uiRight');

	// Held
	public static var uiLeftPress(get, never):Bool;
	inline static function get_uiLeftPress():Bool
		return globalHeld('uiLeft');

	public static var uiDownPress(get, never):Bool;
	inline static function get_uiDownPress():Bool
		return globalHeld('uiDown');

	public static var uiUpPress(get, never):Bool;
	inline static function get_uiUpPress():Bool
		return globalHeld('uiUp');

	public static var uiRightPress(get, never):Bool;
	inline static function get_uiRightPress():Bool
		return globalHeld('uiRight');

	// Released
	public static var uiLeftReleased(get, never):Bool;
	inline static function get_uiLeftReleased():Bool
		return globalReleased('uiLeft');

	public static var uiDownReleased(get, never):Bool;
	inline static function get_uiDownReleased():Bool
		return globalReleased('uiDown');

	public static var uiUpReleased(get, never):Bool;
	inline static function get_uiUpReleased():Bool
		return globalReleased('uiUp');

	public static var uiRightReleased(get, never):Bool;
	inline static function get_uiRightReleased():Bool
		return globalReleased('uiRight');

	// Controls //
	// Pressed
	public var noteLeft(get, never):Bool;
	inline function get_noteLeft():Bool
		return pressed('noteLeft');

	public var noteDown(get, never):Bool;
	inline function get_noteDown():Bool
		return pressed('noteDown');

	public var noteUp(get, never):Bool;
	inline function get_noteUp():Bool
		return pressed('noteUp');

	public var noteRight(get, never):Bool;
	inline function get_noteRight():Bool
		return pressed('noteRight');

	// Held
	public var noteLeftHeld(get, never):Bool;
	inline function get_noteLeftHeld():Bool
		return held('noteLeft');

	public var noteDownHeld(get, never):Bool;
	inline function get_noteDownHeld():Bool
		return held('noteDown');

	public var noteUpHeld(get, never):Bool;
	inline function get_noteUpHeld():Bool
		return held('noteUp');

	public var noteRightHeld(get, never):Bool;
	inline function get_noteRightHeld():Bool
		return held('noteRight');

	// Released
	public var noteLeftReleased(get, never):Bool;
	inline function get_noteLeftReleased():Bool
		return released('noteLeft');

	public var noteDownReleased(get, never):Bool;
	inline function get_noteDownReleased():Bool
		return released('noteDown');

	public var noteUpReleased(get, never):Bool;
	inline function get_noteUpReleased():Bool
		return released('noteUp');

	public var noteRightReleased(get, never):Bool;
	inline function get_noteRightReleased():Bool
		return released('noteRight');

	// Actions //
	public static var accept(get, never):Bool;
	inline static function get_accept():Bool
		return globalPressed('accept');

	public static var back(get, never):Bool;
	inline static function get_back():Bool
		return globalPressed('back');

	public static var pause(get, never):Bool;
	inline static function get_pause():Bool
		return globalPressed('pause');

	public static var reset(get, never):Bool;
	inline static function get_reset():Bool
		return globalPressed('reset');

	// Extras //
	public static var fullscreen(get, never):Bool;
	inline static function get_fullscreen():Bool
		return globalPressed('fullscreen');

	// The Main Powerhouses //
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
		'fullscreen' => [F11]
	];
	inline public static function globalPressed(key:String):Bool return FlxG.keys.anyJustPressed(globalBinds[key]);
	inline public static function globalHeld(key:String):Bool return FlxG.keys.anyPressed(globalBinds[key]);
	inline public static function globalReleased(key:String):Bool return FlxG.keys.anyJustReleased(globalBinds[key]);

	public var setBinds:Map<String, Array<FlxKey>>;
	inline public function pressed(key:String):Bool return FlxG.keys.anyJustPressed(setBinds[key]);
	inline public function held(key:String):Bool return FlxG.keys.anyPressed(setBinds[key]);
	inline public function released(key:String):Bool return FlxG.keys.anyJustReleased(setBinds[key]);

	inline public function keyPress(key:String):PressTypes {
		return {
			pressed: pressed(key),
			held: held(key),
			released: released(key)
		}
	}

	public function new() {
		setBinds = [
			// Controls //
			'noteLeft' => [D, LEFT],
			'noteDown' => [F, DOWN],
			'noteUp' => [K, UP],
			'noteRight' => [L, RIGHT]
		];
	}

	public function destroy():Void {}
}