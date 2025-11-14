package imaginative.backend;

import flixel.input.keyboard.FlxKey;

/**
 * Player input for menus and other general things.
 */
class GlobalControls extends Controls {
	// UI
	/**
	 * When you press left to move through ui elements
	 */
	public var uiLeft(get, never):Bool;
	inline function get_uiLeft():Bool
		return pressed('uiLeft');
	/**
	 * When you press down to move through ui elements
	 */
	public var uiDown(get, never):Bool;
	inline function get_uiDown():Bool
		return pressed('uiDown');
	/**
	 * When you press up to move through ui elements
	 */
	public var uiUp(get, never):Bool;
	inline function get_uiUp():Bool
		return pressed('uiUp');
	/**
	 * When you press right to move through ui elements
	 */
	public var uiRight(get, never):Bool;
	inline function get_uiRight():Bool
		return pressed('uiRight');

	/**
	 * When you hold left to move through ui elements
	 */
	public var uiLeftPress(get, never):Bool;
	inline function get_uiLeftPress():Bool
		return held('uiLeft');
	/**
	 * When you hold down to move through ui elements
	 */
	public var uiDownPress(get, never):Bool;
	inline function get_uiDownPress():Bool
		return held('uiDown');
	/**
	 * When you hold up to move through ui elements
	 */
	public var uiUpPress(get, never):Bool;
	inline function get_uiUpPress():Bool
		return held('uiUp');
	/**
	 * When you hold up to move through ui elements
	 */
	public var uiRightPress(get, never):Bool;
	inline function get_uiRightPress():Bool
		return held('uiRight');

	/**
	 * When you release left to move through ui elements
	 */
	public var uiLeftReleased(get, never):Bool;
	inline function get_uiLeftReleased():Bool
		return released('uiLeft');
	/**
	 * When you release down to move through ui elements
	 */
	public var uiDownReleased(get, never):Bool;
	inline function get_uiDownReleased():Bool
		return released('uiDown');
	/**
	 * When you release up to move through ui elements
	 */
	public var uiUpReleased(get, never):Bool;
	inline function get_uiUpReleased():Bool
		return released('uiUp');
	/**
	 * When you release right to move through ui elements
	 */
	public var uiRightReleased(get, never):Bool;
	inline function get_uiRightReleased():Bool
		return released('uiRight');

	// Actions
	/**
	 * When accept is pressed.
	 */
	public var accept(get, never):Bool;
	inline function get_accept():Bool
		return pressed('accept');
	/**
	 * When back is pressed.
	 */
	public var back(get, never):Bool;
	inline function get_back():Bool
		return pressed('back');
	/**
	 * When paused is pressed.
	 */
	public var pause(get, never):Bool;
	inline function get_pause():Bool
		return pressed('pause');
	/**
	 * When reset is pressed.
	 */
	public var reset(get, never):Bool;
	inline function get_reset():Bool
		return pressed('reset');

	// Extras
	/**
	 * When fullscreen is pressed.
	 */
	public var fullscreen(get, never):Bool;
	inline function get_fullscreen():Bool
		return pressed('fullscreen');

	// Debug
	/**
	 * When botplay is pressed.
	 */
	public var botplay(get, never):Bool;
	inline function get_botplay():Bool
		return pressed('botplay');
	/**
	 * When resetState is pressed.
	 */
	public var resetState(get, never):Bool;
	inline function get_resetState():Bool
		return pressed('resetState');
	/**
	 * When shortcutState is pressed.
	 */
	public var shortcutState(get, never):Bool;
	inline function get_shortcutState():Bool
		return pressed('shortcutState');
	/**
	 * When reloadGlobalScripts is pressed.
	 */
	public var reloadGlobalScripts(get, never):Bool;
	inline function get_reloadGlobalScripts():Bool
		return pressed('reloadGlobalScripts');
}
/**
 * Player input for 'ArrowField's.
 */
class PlayerControls extends Controls {
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
}

/**
 * This class handles user controls, without it how would you do anything?
 */
class Controls extends FlxBasic {
	@:access(imaginative.backend.system.SaveData)
	@:allow(imaginative.states.EngineProcess)
	inline static function init():Void {
		SaveData.initSave(CONTROLS);
		global = new GlobalControls(SaveData.controls.global);
		p1 = new PlayerControls(SaveData.controls.player1);
		p2 = new PlayerControls(SaveData.controls.player2);
	}

	/**
	 * Menu input amongst other things.
	 */
	public static var global(default, null):GlobalControls;

	/**
	 * Used for arrow field's when it's not maintained by a player.
	 */
	public static final blank:PlayerControls = new PlayerControls();
	/**
	 * Player 1's controls.
	 */
	public static var p1(default, null):PlayerControls;
	/**
	 * Player 2's controls.
	 */
	public static var p2(default, null):PlayerControls;

	/**
	 * The binds that are contained within this controls instance.
	 */
	public var bindMap:Map<String, Array<FlxKey>>;
	/**
	 * Pressed input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public function pressed(key:String):Bool
		return FlxG.keys.anyJustPressed(bindCheck(key));
	/**
	 * Held input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public function held(key:String):Bool
		return FlxG.keys.anyPressed(bindCheck(key));
	/**
	 * Released input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public function released(key:String):Bool
		return FlxG.keys.anyJustReleased(bindCheck(key));

	inline function bindCheck(key:String):Array<FlxKey>
		return active && bindMap.exists(key) ? bindMap.get(key) : [];

	public function new(?initBinds:Map<String, Array<FlxKey>>) {
		super();
		active = true;
		bindMap = initBinds ?? [];
		// FlxG.plugins.addPlugin(this);
	}

	override public function destroy():Void {
		active = false;
		// FlxG.plugins.remove(this);
		bindMap.clear();
		super.destroy();
	}

	override public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('active', active),
			LabelValuePair.weak('Key Binds', bindMap)
		]);
	}
}