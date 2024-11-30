package objects.gameplay;

import openfl.events.KeyboardEvent;
import states.editors.ChartEditor.ChartField;

class ArrowField extends BeatGroup {
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();

	// Even though you can have a but ton of ArrowField's you can ONLY play as one!
	/**
	 * The main enemy field.
	 */
	public static var enemy:ArrowField;
	/**
	 * The main player field.
	 */
	public static var player:ArrowField;

	/**
	 * States if it's the main enemy or player field.
	 * False is the enemy, true is the player, and null is neither.
	 */
	public var status(get, set):Null<Bool>;
	inline function get_status():Null<Bool> {
		if (this == enemy) return false;
		if (this == player) return true;
		return null;
	}
	inline function set_status(?value:Bool):Null<Bool> {
		switch (value) {
			case false:
				if (enemy == player) swapTargetFields();
				else enemy = this;
			case true:
				if (player == enemy) swapTargetFields();
				else player = this;
			case null:
				var prevStatus:Null<Bool> = status; // jic
				if (prevStatus != null) prevStatus ? player = null : enemy = null;
		}
		return status;
	}
	/**
	 * Swaps the current enemy and player field's around.
	 * I guess you could look at this like it triggers enemy play.
	 * When it technically doesn't.
	 */
	inline public static function swapTargetFields():Void {
		var prevEnemy:ArrowField = enemy;
		var prevPlay:ArrowField = player;
		enemy = prevPlay;
		player = prevEnemy;
	}

	/**
	 * Any character tag names in this array will react to notes for this field.
	 */
	public var assignedSingers:Array<Character> = [];

	/**
	 * The strums of the field.
	 */
	public var strums:BeatTypedGroup<Strum> = new BeatTypedGroup<Strum>();
	/**
	 * The notes of the field.
	 */
	public var notes:BeatTypedGroup<Note> = new BeatTypedGroup<Note>();
	/**
	 * The sustains of the field.
	 */
	public var sustains:BeatTypedGroup<BeatTypedGroup<Sustain>> = new BeatTypedGroup<BeatTypedGroup<Sustain>>();

	/**
	 * The amount of strums in the field.
	 * Forced to 4 for now.
	 */
	public var strumCount(default, set):Int;
	inline function set_strumCount(value:Int):Int
		return strumCount = 4;//Std.int(FlxMath.bound(value, 1, 9));

	override public function new(mania:Int = 4, ?singers:Array<Character>) {
		strumCount = mania;
		super();

		for (i in 0...strumCount)
			strums.add(new Strum(this, i));
		setFieldPosition(FlxG.width / 2, FlxG.height / 2);

		if (singers != null)
			assignedSingers = singers;

		add(strums);
		add(notes);
		insert(members.indexOf(true ? strums : notes), sustains); // behindStrums

		// input system
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, _input);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, _input);
	}

	function _input(event:KeyboardEvent):Void {
		if (status != null && (status == !PlayConfig.enemyPlay || PlayConfig.enableP2) && !PlayConfig.botplay) {
			var controls:Controls = status != PlayConfig.enemyPlay ? Controls.p1 : Controls.p2;
			for (i => strum in strums.members)
				input(
					i,
					strum,
					[
						controls.noteLeft,
						controls.noteDown,
						controls.noteUp,
						controls.noteRight
					]
					[i],
					[
						controls.noteLeftHeld,
						controls.noteDownHeld,
						controls.noteUpHeld,
						controls.noteRightHeld
					]
					[i],
					[
						controls.noteLeftReleased,
						controls.noteDownReleased,
						controls.noteUpReleased,
						controls.noteRightReleased
					]
					[i]
				);
		}
	}

	/**
	 * Where input stuff really begins.
	 * @param i The strum index.
	 * @param strum The strum object.
	 * @param hasHit If true, a bind was pressed.
	 * @param beingHeld If true, a bind is being held.
	 * @param wasReleased If true, a bind was released.
	 */
	function input(i:Int, strum:Strum, hasHit:Bool, beingHeld:Bool, wasReleased:Bool):Void {
		if (hasHit)
			strum.playAnim('press');

		if (wasReleased && (strum.getAnimName() == 'press' || strum.getAnimName() == 'confrim'))
			strum.playAnim('static');
	}

	/**
	 * Set's the position of the strums.
	 * @param x The x position.
	 * @param y The y position.
	 */
	public function setFieldPosition(x:Float = 0, y:Float = 0):Void {
		for (i => strum in strums.members) {
			strum.setPosition(x - (Note.baseWidth / 2), y);
			strum.x += Note.baseWidth * i;
			strum.x -= (Note.baseWidth * ((strumCount - 1) / 2));
			// if (SaveManager.getOption('strumShift')) strum.x -= Note.baseWidth / 2.4;
		}
	}

	/**
	 * Parse's ChartField information.
	 * @param data The ChartField data.
	 */
	public function parse(data:ChartField):Void {
		for (base in data.notes) {
			var note:Note = new Note(this, base.id, base.time);
			// Note.generateSustain(note, base.length);
			sustains.add(notes.add(note).tail);
		}
	}

	override function destroy():Void {
		if (enemy == this) enemy = null;
		if (player == this) player = null;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _input);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, _input);
		super.destroy();
	}
}