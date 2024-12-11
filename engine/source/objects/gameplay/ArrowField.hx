package objects.gameplay;

import backend.scripting.events.objects.gameplay.FieldInputEvent;
import backend.scripting.events.objects.gameplay.NoteHitEvent;
import backend.scripting.events.objects.gameplay.NoteMissedEvent;
import backend.scripting.events.objects.gameplay.SustainHitEvent;
import backend.scripting.events.objects.gameplay.SustainMissedEvent;
import backend.scripting.events.objects.gameplay.VoidMissEvent;
import states.editors.ChartEditor.ChartField;

class ArrowField extends BeatGroup {
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * The conductor the arrow field follows.
	 */
	public var conductor(get, default):Conductor;
	inline function get_conductor():Conductor
		return conductor ?? Conductor.mainDirect;

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
	function set_status(?value:Bool):Null<Bool> {
		switch (value) {
			case false:
				if (this == player) swapTargetFields();
				else enemy = this;
			case true:
				if (this == enemy) swapTargetFields();
				else player = this;
			case null:
				var prevStatus:Null<Bool> = status; // jic
				if (prevStatus != null)
					prevStatus ? player = null : enemy = null;
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
	 * If true, this field is maintained by a player.
	 */
	public var isPlayer(get, never):Bool;
	inline function get_isPlayer():Bool
		return status != null && (status == !PlayConfig.enemyPlay || PlayConfig.enableP2) && !PlayConfig.botplay;

	public var controls(get, never):Null<Controls>;
	inline function get_controls():Null<Controls>
		if (status == null) return Controls.blank;
		else return status == PlayConfig.enemyPlay ? Controls.p2 : Controls.p1;
	public var settings(get, never):Null<PlayerSettings>;
	inline function get_settings():Null<PlayerSettings>
		if (status == null) return Settings.setupP1;
		else return status == PlayConfig.enemyPlay ? Settings.setupP2 : Settings.setupP1;

	// signals
	/**
	 * Dispatches when a note is hit.
	 */
	public var onNoteHit(default, null):FlxTypedSignal<NoteHitEvent->Void> = new FlxTypedSignal<NoteHitEvent->Void>();
	/**
	 * Dispatches when a sustain is hit.
	 */
	public var onSustainHit(default, null):FlxTypedSignal<SustainHitEvent->Void> = new FlxTypedSignal<SustainHitEvent->Void>();
	/**
	 * Dispatches when a note is missed.
	 */
	public var onNoteMissed(default, null):FlxTypedSignal<NoteMissedEvent->Void> = new FlxTypedSignal<NoteMissedEvent->Void>();
	/**
	 * Dispatches when a sustain is missed.
	 */
	public var onSustainMissed(default, null):FlxTypedSignal<SustainMissedEvent->Void> = new FlxTypedSignal<SustainMissedEvent->Void>();
	/**
	 * Dispatches when you tap without hitting a note.
	 */
	public var onVoidMiss(default, null):FlxTypedSignal<VoidMissEvent->Void> = new FlxTypedSignal<VoidMissEvent->Void>();
	/**
	 * Dispatches when user input happens at all.
	 */
	public var userInput(default, null):FlxTypedSignal<FieldInputEvent->Void> = new FlxTypedSignal<FieldInputEvent->Void>();

	/**
	 * Any characters in this array will react to notes for this field.
	 * `May make it contain string instead.`
	 */
	public var assignedActors:Array<Character> = [];

	/**
	 * The strums of the field.
	 */
	public var strums(default, null):BeatTypedSpriteGroup<Strum> = new BeatTypedSpriteGroup<Strum>();
	/**
	 * The notes of the field.
	 */
	public var notes(default, null):BeatTypedGroup<Note> = new BeatTypedGroup<Note>();
	/**
	 * The sustains of the field.
	 */
	public var sustains(default, null):BeatTypedGroup<BeatTypedGroup<Sustain>> = new BeatTypedGroup<BeatTypedGroup<Sustain>>();

	public var noteKillRange:Float = 350;
	public var strumSpacing:Float = -45;

	/**
	 * The amount of strums in the field.
	 * Forced to 4 for now.
	 */
	public var strumCount(default, set):Int;
	inline function set_strumCount(value:Int):Int
		return strumCount = 4;//Std.int(FlxMath.bound(value, 1, 9));

	override public function new(?singers:Array<Character>, mania:Int = 4) {
		strumCount = mania;
		super();

		for (i in 0...strumCount)
			strums.add(new Strum(this, i));

		strums.group.memberAdded.add((_:Strum) -> strums.members.sort((a:Strum, b:Strum) -> return FlxSort.byValues(FlxSort.ASCENDING, a.id, b.id)));
		strums.group.memberRemoved.add((_:Strum) -> strums.members.sort((a:Strum, b:Strum) -> return FlxSort.byValues(FlxSort.ASCENDING, a.id, b.id)));

		resetInternalPositions();
		setPosition(FlxG.width / 2, FlxG.height / 2);

		if (singers != null)
			assignedActors = singers;

		add(strums);
		add(notes);
		insert(members.indexOf(true ? strums : notes), sustains); // behindStrums
	}

	inline function _input():Void {
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
				[i],
				settings
			);
	}

	/**
	 * Where input stuff really begins.
	 * @param i The strum lane index.
	 * @param strum The strum object instance.
	 * @param hasHit If true, a bind was pressed.
	 * @param beingHeld If true, a bind is being held.
	 * @param wasReleased If true, a bind was released.
	 * @param settings The player settings instance.
	 */
	inline function input(i:Int, strum:Strum, hasHit:Bool, beingHeld:Bool, wasReleased:Bool, settings:PlayerSettings):Void {
		var event:FieldInputEvent = new FieldInputEvent(i, strum, this, hasHit, beingHeld, wasReleased, settings);
		userInput.dispatch(event);
		if (event.prevented) return;

		// note hits
		if (hasHit) {
			var activeNotes:Array<Note> = Note.filterNotes(notes.members, i);
			if (activeNotes.length != 0) {
				for (note in activeNotes) {
					var frontNote:Note = activeNotes[0]; // took from psych, fixes a dumb issue where it eats up jacks
					if (activeNotes.length > 1) {
						var backNote:Note = activeNotes[1];
						if (backNote.id == frontNote.id) {
							if (Math.abs(backNote.time - frontNote.time) < 1.0)
								backNote.canDie = true;
							else if (backNote.time < frontNote.time)
								frontNote = backNote;
						}
					}
					_onNoteHit(frontNote, i);
				}
			} else {
				// void hits (random key presses / ghost tapping)
				var event:VoidMissEvent = new VoidMissEvent(settings.ghostTapping, i, this);
				onVoidMiss.dispatch(event);
				if (!event.prevented) {
					// using event as mush as we can, jic scripts somehow edited everything 💀
					if (!event.stopStrumPress)
						event.strum.playAnim('press', !event.triggerMiss);
				}
			}
		}

		// sustain hits
		if (beingHeld) {
			for (sustain in Note.filterTail([
				for (group in sustains)
					for (sustain in group)
						sustain
			], i))
				if ((sustain.time + sustain.setHead.time) <= conductor.songPosition)
					_onSustainHit(sustain, i);
		}


		if (!event.stopStrumPress && wasReleased && strum.getAnimName() != 'static')
			strum.playAnim('static');
	}

	override function update(elapsed:Float):Void {
		// Hopefully the on update method is temporary until I can find a better way. As on input was giving some issues.
		if (isPlayer)
			_input();

		for (note in notes) {
			// lol
			if (note.tooLate && (conductor.songPosition - note.time) > Math.max(conductor.stepCrochet, noteKillRange / note.__scrollSpeed)) {
				if (!note.wasHit && !note.wasMissed)
					_onNoteMissed(note);
				note.canDie = true;
			}
			if (!isPlayer) {
				if (note.time <= conductor.songPosition && !note.tooLate && !note.wasHit && !note.wasMissed)
					_onNoteHit(note);
			}
			var shouldKill:Bool = note.canDie;
			for (sustain in note.tail)
				if (!(shouldKill = sustain.canDie))
					break;
			if (shouldKill)
				note.kill();
		}
		for (sustain in [
			for (group in sustains)
				for (sustain in group)
					sustain
		]) {
			// lol
			if (sustain.tooLate && (conductor.songPosition - (sustain.time + sustain.setHead.time)) > Math.max(conductor.stepCrochet, noteKillRange / sustain.setHead.__scrollSpeed)) {
				if (!sustain.wasHit && !sustain.wasMissed)
					_onSustainMissed(sustain);
				sustain.canDie = true;
			}
			if (!isPlayer) {
				if ((sustain.time + sustain.setHead.time) <= conductor.songPosition && !sustain.tooLate && !sustain.wasHit && !sustain.wasMissed)
					_onSustainHit(sustain);
			}
		}

		super.update(elapsed);
	}

	inline function _onNoteHit(note:Note, ?i:Int):Void {
		if (note.wasHit) return;
		i ??= note.id;
		note.wasHit = true;
		note.visible = false;
		var event:NoteHitEvent = new NoteHitEvent(note, i, this);
		onNoteHit.dispatch(event);
		if (!event.prevented) {
			// using event as mush as we can, jic scripts somehow edited everything 💀
			if (!event.stopStrumConfirm)
				event.note.setStrum.playAnim('confirm', true);
		}
	}
	inline function _onSustainHit(sustain:Sustain, ?i:Int):Void {
		if (sustain.wasHit) return;
		i ??= sustain.id;
		sustain.wasHit = true;
		sustain.visible = false;
		var event:SustainHitEvent = new SustainHitEvent(sustain, i, this);
		onSustainHit.dispatch(event);
		if (!event.prevented) {
			// using event as mush as we can, jic scripts somehow edited everything 💀
			if (!event.stopStrumConfirm)
				event.sustain.setStrum.playAnim('confirm', true);
		}
	}
	inline function _onNoteMissed(note:Note, ?i:Int):Void {
		if (note.wasMissed) return;
		i ??= note.id;
		note.wasMissed = true;
		var event:NoteMissedEvent = new NoteMissedEvent(note, i, this, isPlayer);
		onNoteMissed.dispatch(event);
		if (!event.prevented) {
			// using event as mush as we can, jic scripts somehow edited everything 💀
			if (!event.stopStrumPress)
				event.note.setStrum.playAnim('press', !event.field.isPlayer);
		}
	}
	inline function _onSustainMissed(sustain:Sustain, ?i:Int):Void {
		if (sustain.wasMissed) return;
		i ??= sustain.id;
		sustain.wasMissed = true;
		var event:SustainMissedEvent = new SustainMissedEvent(sustain, i, this, isPlayer);
		onSustainMissed.dispatch(event);
		if (!event.prevented) {
			// using event as mush as we can, jic scripts somehow edited everything 💀
			if (!event.stopStrumPress)
				event.sustain.setStrum.playAnim('press', !event.field.isPlayer);
		}
	}

	public var totalWidth(default, null):Float;
	public function resetInternalPositions():Void {
		inline function helper(a:Strum, b:Strum):Void
			if (a != null && b != null)
				b.x = a.x + a.width + strumSpacing;

		for (i => strum in strums.members) {
			strum.y = -strum.height / 2;
			helper(strum, strums.members[i + 1]);
		}

		totalWidth = 0; // reset width
		for (i => strum in strums.members)
			totalWidth += strum.width;

		totalWidth += strumSpacing * (strumCount - 1);
		for (strum in strums)
			strum.x -= totalWidth / 2;
	}

	/**
	 * The center x position of the field.
	 */
	@:isVar public var x(get, set):Float = 0;
	inline function get_x():Float
		return strums.x;
	inline function set_x(value:Float):Float
		return strums.x = value;
	/**
	 * The center y position of the field.
	 */
	@:isVar public var y(get, set):Float = 0;
	inline function get_y():Float
		return strums.y;
	inline function set_y(value:Float):Float
		return strums.y = value;

	/**
	 * Set's the center position of the strum group.
	 * @param x The center x position.
	 * @param y The center y position.
	 */
	inline public function setPosition(x:Float = 0, y:Float = 0):Void {
		this.x = x;
		this.y = y;
	}

	/**
	 * Parse's ChartField information.
	 * @param data The ChartField data.
	 */
	public function parse(data:ChartField):Void {
		for (base in data.notes) {
			var note:Note = new Note(this, strums.members[base.id], base.id, base.time);
			Note.generateTail(note, base.length);
			var lol:Array<String> = base.characters ??= [];
			note.assignedActors = PlayState.direct == null ? [] : [
				for (tag => char in PlayState.direct.characterMapping)
					if (lol.contains(tag))
						char
			];
			sustains.add(notes.add(note).tail);
		}
	}

	override function destroy():Void {
		if (enemy == this) enemy = null;
		if (player == this) player = null;
		onNoteHit.destroy();
		onSustainHit.destroy();
		onNoteMissed.destroy();
		onSustainMissed.destroy();
		onVoidMiss.destroy();
		userInput.destroy();
		super.destroy();
	}
}