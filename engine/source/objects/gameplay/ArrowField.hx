package objects.gameplay;

import backend.scripting.events.objects.gameplay.FieldInputEvent;
import backend.scripting.events.objects.gameplay.NoteHitEvent;
import backend.scripting.events.objects.gameplay.NoteMissedEvent;
import backend.scripting.events.objects.gameplay.SustainHitEvent;
import backend.scripting.events.objects.gameplay.SustainMissedEvent;
import backend.scripting.events.objects.gameplay.VoidMissEvent;
import openfl.events.KeyboardEvent;
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
				final prevStatus:Null<Bool> = status; // jic
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
	inline function get_isPlayer():Bool {
		return status != null && (status == !PlayConfig.enemyPlay || PlayConfig.enableP2) && !PlayConfig.botplay;
	}

	// signals
	/**
	 * Dispatches when a note is hit.
	 */
	public var onNoteHit(default, null):FlxTypedSignal<NoteHitEvent->Void> = new FlxTypedSignal<NoteHitEvent->Void>();
	/**
	 * Dispatches when a note is hit.
	 */
	public var onSustainHit(default, null):FlxTypedSignal<SustainHitEvent->Void> = new FlxTypedSignal<SustainHitEvent->Void>();
	/**
	 * Dispatches when a note is missed.
	 */
	public var onNoteMissed(default, null):FlxTypedSignal<NoteMissedEvent->Void> = new FlxTypedSignal<NoteMissedEvent->Void>();
	/**
	 * Dispatches when a note is missed.
	 */
	public var onSustainMissed(default, null):FlxTypedSignal<SustainMissedEvent->Void> = new FlxTypedSignal<SustainMissedEvent->Void>();
	/**
	 * Dispatches when a note is missed.
	 */
	public var onVoidMiss(default, null):FlxTypedSignal<VoidMissEvent->Void> = new FlxTypedSignal<VoidMissEvent->Void>();
	/**
	 * Dispatches when a note is missed.
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
	public var strums(default, null):BeatTypedGroup<Strum> = new BeatTypedGroup<Strum>();
	/**
	 * The notes of the field.
	 */
	public var notes(default, null):BeatTypedGroup<Note> = new BeatTypedGroup<Note>();
	/**
	 * The sustains of the field.
	 */
	public var sustains(default, null):BeatTypedGroup<BeatTypedGroup<Sustain>> = new BeatTypedGroup<BeatTypedGroup<Sustain>>();

	public var noteKillRange:Float = 350;

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
			assignedActors = singers;

		add(strums);
		add(notes);
		insert(members.indexOf(true ? strums : notes), sustains); // behindStrums

		// input system, having separate because I think I was having double input
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, _down_input);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, _up_input);
	}

	// var lastInput:String = '';
	inline function _down_input(event:KeyboardEvent):Void {
		if (isPlayer) {
			_input(event);
			/* if (lastInput != 'holding') {
				lastInput = FlxG.keys.checkStatus(event.keyCode, JUST_PRESSED) ? 'pressed' : 'holding';
				trace('key $lastInput');
			} */
		}
	}
	inline function _up_input(event:KeyboardEvent):Void {
		if (isPlayer) {
			_input(event);
			/* lastInput = 'released';
			trace('key $lastInput'); */
		}
	}
	inline function _input(event:KeyboardEvent):Void {
		final isP2:Bool = status == PlayConfig.enemyPlay;
		var controls:Controls = isP2 ? Controls.p2 : Controls.p1;
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
				isP2 ? Settings.setupP2 : Settings.setupP1
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
				_onSustainHit(sustain, i);
		}


		if (!event.stopStrumPress && wasReleased && strum.getAnimName() != 'static')
			strum.playAnim('static');
	}

	override function update(elapsed:Float):Void {
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
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _down_input);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, _up_input);
		onNoteHit.destroy();
		onSustainHit.destroy();
		onNoteMissed.destroy();
		onSustainMissed.destroy();
		onVoidMiss.destroy();
		userInput.destroy();
		super.destroy();
	}
}