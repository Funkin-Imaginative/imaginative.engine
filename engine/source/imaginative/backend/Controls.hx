package imaginative.backend;

import flixel.input.keyboard.FlxKey;
/* import flixel.input.mouse.FlxMouseButton;
import flixel.input.android.FlxAndroidKey;
import flixel.input.gamepad.FlxGamepadInputID; */

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
		return pressed('ui_left');
	/**
	 * When you press down to move through ui elements
	 */
	public var uiDown(get, never):Bool;
	inline function get_uiDown():Bool
		return pressed('ui_down');
	/**
	 * When you press up to move through ui elements
	 */
	public var uiUp(get, never):Bool;
	inline function get_uiUp():Bool
		return pressed('ui_up');
	/**
	 * When you press right to move through ui elements
	 */
	public var uiRight(get, never):Bool;
	inline function get_uiRight():Bool
		return pressed('ui_right');

	/**
	 * When you hold left to move through ui elements
	 */
	public var uiLeftPress(get, never):Bool;
	inline function get_uiLeftPress():Bool
		return held('ui_left');
	/**
	 * When you hold down to move through ui elements
	 */
	public var uiDownPress(get, never):Bool;
	inline function get_uiDownPress():Bool
		return held('ui_down');
	/**
	 * When you hold up to move through ui elements
	 */
	public var uiUpPress(get, never):Bool;
	inline function get_uiUpPress():Bool
		return held('ui_up');
	/**
	 * When you hold up to move through ui elements
	 */
	public var uiRightPress(get, never):Bool;
	inline function get_uiRightPress():Bool
		return held('ui_right');

	/**
	 * When you release left to move through ui elements
	 */
	public var uiLeftReleased(get, never):Bool;
	inline function get_uiLeftReleased():Bool
		return released('ui_left');
	/**
	 * When you release down to move through ui elements
	 */
	public var uiDownReleased(get, never):Bool;
	inline function get_uiDownReleased():Bool
		return released('ui_down');
	/**
	 * When you release up to move through ui elements
	 */
	public var uiUpReleased(get, never):Bool;
	inline function get_uiUpReleased():Bool
		return released('ui_up');
	/**
	 * When you release right to move through ui elements
	 */
	public var uiRightReleased(get, never):Bool;
	inline function get_uiRightReleased():Bool
		return released('ui_right');

	// Actions
	/**
	 * When "accept" is pressed.
	 */
	public var accept(get, never):Bool;
	inline function get_accept():Bool
		return pressed('accept');
	/**
	 * When "back" is pressed.
	 */
	public var back(get, never):Bool;
	inline function get_back():Bool
		return pressed('back');
	/**
	 * When "paused" is pressed.
	 */
	public var pause(get, never):Bool;
	inline function get_pause():Bool
		return pressed('pause');
	/**
	 * When "reset" is pressed.
	 */
	public var reset(get, never):Bool;
	inline function get_reset():Bool
		return pressed('reset');

	// Extras
	/**
	 * When "fullscreen" is pressed.
	 */
	public var fullscreen(get, never):Bool;
	inline function get_fullscreen():Bool
		return pressed('fullscreen');

	// Debug
	/**
	 * When "botplay" is pressed.
	 */
	public var botplay(get, never):Bool;
	inline function get_botplay():Bool
		return pressed('botplay');
	/**
	 * When "resetState" is pressed.
	 */
	public var resetState(get, never):Bool;
	inline function get_resetState():Bool
		return pressed('resetState');
	/**
	 * When "shortcutState" is pressed.
	 */
	public var shortcutState(get, never):Bool;
	inline function get_shortcutState():Bool
		return pressed('shortcutState');
	/**
	 * When "reloadGame" is pressed.
	 */
	public var reloadGame(get, never):Bool;
	inline function get_reloadGame():Bool
		return pressed('reloadGame');

	public function new(?initBinds:Map<String, Array<FlxKey>>) {
		super(initBinds);
		if (bindMap.exists('volume_up')) FlxG.sound.volumeUpKeys = bindMap.get('volume_up');
		if (bindMap.exists('volume_down')) FlxG.sound.volumeDownKeys = bindMap.get('volume_down');
		if (bindMap.exists('volume_mute')) FlxG.sound.muteKeys = bindMap.get('volume_mute');
	}
}
/**
 * Player input for 'ArrowField's.
 */
class PlayerControls extends Controls {
	/**
	 * The amount of lanes the assigned 'ArrowField' has.
	 */
	public var laneCount:Int = 4;

	/**
	 * Pressed input for notes.
	 * @param id The lane id.
	 * @param count The lane amount.
	 * @return Bool
	 */
	inline public function notePressed(id:Int, ?count:Int):Bool
		return pressed('note_${count ?? laneCount}:$id');
	/**
	 * Held input for notes.
	 * @param id The lane id.
	 * @param count The lane amount.
	 * @return Bool
	 */
	inline public function noteHeld(id:Int, ?count:Int):Bool
		return held('note_${count ?? laneCount}:$id');
	/**
	 * Released input for notes.
	 * @param id The lane id.
	 * @param count The lane amount.
	 * @return Bool
	 */
	inline public function noteReleased(id:Int, ?count:Int):Bool
		return released('note_${count ?? laneCount}:$id');

	/**
	 * Pressed inputs for all note id's in that lane amount.
	 * @param count The lane amount.
	 * @return Bool
	 */
	inline public function notesPressed(?count:Int):Array<Bool>
		return [for (id in 0...count) notePressed(id, count ?? laneCount)];
	/**
	 * Held inputs for all note id's in that lane amount.
	 * @param count The lane amount.
	 * @return Bool
	 */
	inline public function notesHeld(?count:Int):Array<Bool>
		return [for (id in 0...count) noteHeld(id, count ?? laneCount)];
	/**
	 * Released inputs for all note id's in that lane amount.
	 * @param count The lane amount.
	 * @return Bool
	 */
	inline public function notesReleased(?count:Int):Array<Bool>
		return [for (id in 0...count) noteReleased(id, count ?? laneCount)];
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
	public final bindMap:Map<String, Array<FlxKey>>;
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
	}

	override public function destroy():Void {
		active = false;
		bindMap.clear();
		super.destroy();
	}

	override public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('Key Binds', bindMap),
			LabelValuePair.weak('active', active)
		]);
	}
}