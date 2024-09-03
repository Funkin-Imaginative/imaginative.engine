package backend;

import flixel.input.keyboard.FlxKey;

typedef PressTypes = {
	var justPressed:Bool;
	var pressed:Bool;
	var justReleased:Bool;
}

class Controls implements flixel.util.FlxDestroyUtil.IFlxDestroyable {
	public static var p1:Controls;
	public static var p2:Controls;

	// UI

	// Just Pressed
	public var uiLeft(get, never):Bool;
	inline function get_uiLeft():Bool
		return justPressed('uiLeft');

	public var uiDown(get, never):Bool;
	inline function get_uiDown():Bool
		return justPressed('uiDown');

	public var uiUp(get, never):Bool;
	inline function get_uiUp():Bool
		return justPressed('uiUp');

	public var uiRight(get, never):Bool;
	inline function get_uiRight():Bool
		return justPressed('uiRight');

	// Pressed
	public var uiLeftPress(get, never):Bool;
	inline function get_uiLeftPress():Bool
		return pressed('uiLeft');

	public var uiDownPress(get, never):Bool;
	inline function get_uiDownPress():Bool
		return pressed('uiDown');

	public var uiUpPress(get, never):Bool;
	inline function get_uiUpPress():Bool
		return pressed('uiUp');

	public var uiRightPress(get, never):Bool;
	inline function get_uiRightPress():Bool
		return pressed('uiRight');

	// Released
	public var uiLeftReleased(get, never):Bool;
	inline function get_uiLeftReleased():Bool
		return justReleased('uiLeft');

	public var uiDownReleased(get, never):Bool;
	inline function get_uiDownReleased():Bool
		return justReleased('uiDown');

	public var uiUpReleased(get, never):Bool;
	inline function get_uiUpReleased():Bool
		return justReleased('uiUp');

	public var uiRightReleased(get, never):Bool;
	inline function get_uiRightReleased():Bool
		return justReleased('uiRight');



	// Controls

	// Just Pressed
	public var noteLeft(get, never):Bool;
	inline function get_noteLeft():Bool
		return justPressed('noteLeft');

	public var noteDown(get, never):Bool;
	inline function get_noteDown():Bool
		return justPressed('noteDown');

	public var noteUp(get, never):Bool;
	inline function get_noteUp():Bool
		return justPressed('noteUp');

	public var noteRight(get, never):Bool;
	inline function get_noteRight():Bool
		return justPressed('noteRight');

	// Pressed
	public var noteLeftPress(get, never):Bool;
	inline function get_noteLeftPress():Bool
		return pressed('noteLeft');

	public var noteDownPress(get, never):Bool;
	inline function get_noteDownPress():Bool
		return pressed('noteDown');

	public var noteUpPress(get, never):Bool;
	inline function get_noteUpPress():Bool
		return pressed('noteUp');

	public var noteRightPress(get, never):Bool;
	inline function get_noteRightPress():Bool
		return pressed('noteRight');

	// Released
	public var noteLeftReleased(get, never):Bool;
	inline function get_noteLeftReleased():Bool
		return justReleased('noteLeft');

	public var noteDownReleased(get, never):Bool;
	inline function get_noteDownReleased():Bool
		return justReleased('noteDown');

	public var noteUpReleased(get, never):Bool;
	inline function get_noteUpReleased():Bool
		return justReleased('noteUp');

	public var noteRightReleased(get, never):Bool;
	inline function get_noteRightReleased():Bool
		return justReleased('noteRight');



	// Extras
	public var accept(get, never):Bool;
	inline function get_accept():Bool
		return justPressed('accept');

	public var back(get, never):Bool;
	inline function get_back():Bool
		return justPressed('back');

	public var pause(get, never):Bool;
	inline function get_pause():Bool
		return justPressed('pause');

	public var reset(get, never):Bool;
	inline function get_reset():Bool
		return justPressed('reset');

	// The Main Powerhouses
	public var binds:Map<String, Array<FlxKey>>;
	inline public function justPressed(key:String):Bool
		return FlxG.keys.anyJustPressed(binds[key]);
	inline public function pressed(key:String):Bool
		return FlxG.keys.anyPressed(binds[key]);
	inline public function justReleased(key:String):Bool
		return FlxG.keys.anyJustReleased(binds[key]);

	inline public function keyPress(key:String):PressTypes {
		return {
			justPressed: justPressed(key),
			pressed: pressed(key),
			justReleased: justReleased(key)
		}
	}

	public function new() {
		binds = [
			// UI
			'uiLeft' => [A, LEFT],
			'uiDown' => [S, DOWN],
			'uiUp' => [W, UP],
			'uiRight' => [D, RIGHT],

			// Controls
			'noteLeft' => [D, LEFT],
			'noteDown' => [F, DOWN],
			'noteUp' => [K, UP],
			'noteRight' => [L, RIGHT],

			// Extras
			'accept' => [ENTER, SPACE],
			'back' => [BACKSPACE, ESCAPE],
			'pause' => [ENTER, ESCAPE],
			'reset' => [R, DELETE],

			// Volume
			'volumeUp' => [PLUS, NUMPADPLUS],
			'volumeDown' => [MINUS, NUMPADMINUS],
			'volumeMute' => [ZERO, NUMPADZERO]
		];
	}

	public function destroy():Void {}
}