package imaginative.objects.gameplay.arrows;

import imaginative.backend.scripting.events.objects.gameplay.*;
import imaginative.objects.gameplay.hud.HUDType;
import imaginative.states.editors.ChartEditor.ChartField;

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

	public static function setupFieldXPositions(fields:Array<ArrowField>, ?camera:FlxCamera):Array<ArrowField> {
		if (camera == null)
			camera = FlxG.camera;
		for (i => field in fields) {
			if (field.length < 3)
				field.scale.set(field.scale.x / Math.min(field.length, 2), field.scale.y / Math.min(field.length, 2));
			field.visible = true;
		}
		var hatred:Array<FlxObject> = [
			for (field in fields)
				new FlxObject(field.x, field.y, field.totalWidth, arrowSize)
		];
		hatred.space((camera.width / 2) - (camera.width / 4), 0, (camera.width / 2) + (camera.width / 4) - (camera.width / 2) - (camera.width / 4), 0, (object:FlxObject, x:Float, y:Float) -> {
			var field:ArrowField = fields[hatred.indexOf(object)];
			field.x = /* field.totalWidth / 2 + */ x;
		});
		for (obj in hatred)
			obj.destroy();
		return fields;
	}

	/**
	 * If enabled, botplay will be active when entering a song.
	 */
	public static var botplay:Bool = false;
	/**
	 * If enabled, you play as the enemy instead of the player.
	 */
	public static var enemyPlay:Bool = false;
	/**
	 * If enabled, the enemy will be controlled by a second player.
	 * But with enemyPlay your swapped around, making P1 the enemy and P2 the player.
	 */
	public static var enableP2:Bool = false;

	inline public static function characterSing(field:ArrowField, actors:Array<Character>, id:Int, context:AnimationContext, force:Bool = true, ?suffix:String):Void {
		for (char in actors.filter((char:Character) -> return char != null)) {
			char.controls = field.isPlayer ? field.controls : null;
			var temp:String = ['LEFT', 'DOWN', 'UP', 'RIGHT'][id];
			char.playAnim('sing$temp', context, suffix);
			char.lastHit = field.conductor.time;
		}
	}

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
		return status != null && (status == !enemyPlay || enableP2) && !botplay;

	public var controls(get, never):Controls;
	inline function get_controls():Controls
		if (status == null) return Controls.blank;
		else return status == enemyPlay ? Controls.p2 : Controls.p1;
	public var settings(get, never):PlayerSettings;
	inline function get_settings():PlayerSettings
		if (status == null) return Settings.setupP1;
		else return status == enemyPlay ? Settings.setupP2 : Settings.setupP1;
	public var stats(get, never):PlayerStats;
	private function get_stats():PlayerStats
		if (status == null) return Scoring.unregisteredStats;
		else return status == enemyPlay ? Scoring.statsP2 : Scoring.statsP1;

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
	public var sustains(default, null):BeatTypedGroup<Sustain> = new BeatTypedGroup<Sustain>();

	/**
	 * How far out until a note is killed.
	 */
	public var noteKillRange:Float = 350;
	/**
	 * The distance between the each strum.
	 * TODO: Make it so strum skins will have their own spacing!
	 * TODO: REWORK THIS
	 */
	public var strumSpacing:Float = 0;

	/**
	 * This function is used to get the scroll speed but also check for the personal speed!
	 * This really only exists to not fuck up the scrollSpeed get functionality.
	 * ```haxe
	 * // just so
	 * scrollSpeed = scrollSpeed + 2;
	 * // wouldn't actually be
	 * scrollSpeed = personalScrollSpeed + 2;
	 * // that wouldn't be fun
	 * ```
	 * @return `Float` ~ Target scroll speed.
	 */
	inline public function getScrollSpeed():Float
		return settings.enablePersonalScrollSpeed ? settings.personalScrollSpeed : scrollSpeed;
	/**
	 * The scroll speed of the field.
	 * This overrides the base chart speed.
	 * When null is returns the base chart speed.
	 */
	public var scrollSpeed(default, set):Null<Float>;
	@:access(imaginative.objects.gameplay.arrows.ArrowModifier.update_scale)
	inline function set_scrollSpeed(?value:Float):Float {
		scrollSpeed = value ?? PlayState.chartData.speed;
		for (sustain in sustains)
			sustain.mods.update_scale();
		return scrollSpeed;
	}
	/**
	 * The direction the notes will come from.
	 * Downscroll is 90, while upscroll is 270.
	 */
	public var scrollAngle(default, set):Null<Float>;
	@:access(imaginative.objects.gameplay.arrows.ArrowModifier.update_angle)
	inline function set_scrollAngle(?value:Float):Null<Float> {
		value ??= (settings.downscroll ? 90 : 270);
		scrollAngle = value;
		for (sustain in sustains)
			sustain.mods.update_angle();
		return value;
	}

	/**
	 * The amount of strums in the field.
	 * Forced to 4 for now.
	 */
	public var strumCount(default, set):Int;
	inline function set_strumCount(value:Int):Int
		return strumCount = 4;//Std.int(FlxMath.bound(value, 1, 9));

	@:access(imaginative.objects.gameplay.arrows.ArrowModifier.update_scale)
	override public function new(?singers:Array<Character>, mania:Int = 4) {
		strumCount = mania;
		super();

		for (i in 0...strumCount)
			strums.add(new Strum(this, i));

		scrollSpeed = scrollAngle = null; // runs the "set_" function

		scale = new FlxCallbackPoint(
			(point:FlxPoint) -> {
				strums.scale.copyFrom(point);
				for (note in notes)
					note.mods.update_scale();
			}
		);

		strums.group.memberAdded.add((_:Strum) -> strums.members.sort((a:Strum, b:Strum) -> return FlxSort.byValues(FlxSort.ASCENDING, a.id, b.id)));
		strums.group.memberRemoved.add((_:Strum) -> strums.members.sort((a:Strum, b:Strum) -> return FlxSort.byValues(FlxSort.ASCENDING, a.id, b.id)));

		resetInternalPositions();
		setPosition(FlxG.camera.width / 2, FlxG.camera.height / 2);

		if (singers != null)
			assignedActors = singers;

		notes.memberAdded.add((_:Note) -> notes.members.sort(Note.sortNotes));
		notes.memberRemoved.add((_:Note) -> notes.members.sort(Note.sortNotes));

		sustains.memberAdded.add((_:Sustain) -> sustains.members.sort(Note.sortTail));
		sustains.memberRemoved.add((_:Sustain) -> sustains.members.sort(Note.sortTail));

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
				[i]
			);
	}

	/**
	 * Where input stuff really begins.
	 * @param i The strum lane index.
	 * @param strum The strum object instance.
	 * @param hasHit If true, a bind was pressed.
	 * @param beingHeld If true, a bind is being held.
	 * @param wasReleased If true, a bind was released.
	 */
	inline function input(i:Int, strum:Strum, hasHit:Bool, beingHeld:Bool, wasReleased:Bool):Void {
		var event:FieldInputEvent = new FieldInputEvent(i, strum, this, hasHit, beingHeld, wasReleased);
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
					event.field.stats.combo = 0;
					event.field.stats.misses++;

					if (!event.stopStrumPress)
						event.strum.playAnim('press', !event.triggerMiss);

					if (event.field.status != null)
						if (event.field.status == enemyPlay) HUDType.direct.updateStatsP2Text();
						else HUDType.direct.updateStatsText();
				}
			}
		}

		// sustain hits
		if (beingHeld) {
			for (sustain in Note.filterTail(sustains.members, i))
				if ((sustain.time + sustain.setHead.time) <= conductor.time)
					_onSustainHit(sustain, i);
		}

		if (!event.stopStrumPress && wasReleased && strum.getAnimName() != 'static')
			strum.playAnim('static');
	}

	override public function update(elapsed:Float):Void {
		// Hopefully the on update method is temporary until I can find a better way. As on input was giving some issues.
		if (isPlayer)
			_input();

		for (note in notes) {
			// lol
			if (note.tooLate && (conductor.time - note.time) > Math.max(conductor.stepTime, noteKillRange / note.__scrollSpeed)) {
				if (!note.wasHit && !note.wasMissed)
					_onNoteMissed(note);
				note.canDie = true;
			}
			if (!isPlayer) {
				if (note.time <= conductor.time && !note.tooLate && !note.wasHit && !note.wasMissed)
					_onNoteHit(note);
			}
			var shouldKill:Bool = note.canDie;
			for (sustain in note.tail)
				if (!(shouldKill = sustain.canDie))
					break;
			if (shouldKill)
				note.kill();
		}
		for (sustain in sustains) {
			// lol
			if (sustain.tooLate && (conductor.time - (sustain.time + sustain.setHead.time)) > Math.max(conductor.stepTime, noteKillRange / sustain.__scrollSpeed)) {
				if (!sustain.wasHit && !sustain.wasMissed)
					_onSustainMissed(sustain);
				sustain.canDie = true;
			}
			if (!isPlayer) {
				if ((sustain.time + sustain.setHead.time) <= conductor.time && !sustain.tooLate && !sustain.wasHit && !sustain.wasMissed)
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
			event.field.stats.combo++;
			event.field.stats.hits++;

			// using event as mush as we can, jic scripts somehow edited everything 💀
			if (!event.stopStrumConfirm)
				event.note.setStrum.playAnim('confirm', true);

			if (event.field.status != null)
				if (event.field.status == enemyPlay) HUDType.direct.updateStatsP2Text();
				else HUDType.direct.updateStatsText();
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
			if (!event.stopStrumConfirm)
				event.sustain.setStrum.playAnim(event.sustain.setStrum.doesAnimExist('confirm-hold') ? 'confirm-hold' : 'confirm', true);

			if (event.field.status != null)
				if (event.field.status == enemyPlay) HUDType.direct.updateStatsP2Text();
				else HUDType.direct.updateStatsText();
		}
	}
	inline function _onNoteMissed(note:Note, ?i:Int):Void {
		if (note.wasMissed) return;
		i ??= note.id;
		note.wasMissed = true;
		var event:NoteMissedEvent = new NoteMissedEvent(note, i, this, isPlayer);
		onNoteMissed.dispatch(event);
		if (!event.prevented) {
			if (event.field.settings.missFullSustain)
				for (sustain in Note.filterTail(event.note.tail, true))
					sustain.wasMissed = true;
			event.field.stats.combo = 0;
			event.field.stats.misses++;

			if (!event.stopStrumPress)
				event.note.setStrum.playAnim('press', !event.field.isPlayer);

			if (event.field.status != null)
				if (event.field.status == enemyPlay) HUDType.direct.updateStatsP2Text();
				else HUDType.direct.updateStatsText();
		}
	}
	inline function _onSustainMissed(sustain:Sustain, ?i:Int):Void {
		if (sustain.wasMissed) return;
		i ??= sustain.id;
		sustain.wasMissed = true;
		var event:SustainMissedEvent = new SustainMissedEvent(sustain, i, this, isPlayer);
		onSustainMissed.dispatch(event);
		if (!event.prevented) {
			if (event.field.settings.missFullSustain)
				for (sustain in Note.filterTail(event.sustain.setHead.tail, true))
					sustain.wasMissed = true;
			event.field.stats.combo = 0;
			event.field.stats.misses++;

			if (!event.stopStrumPress)
				event.sustain.setStrum.playAnim('press', !event.field.isPlayer);

			if (event.field.status != null)
				if (event.field.status == enemyPlay) HUDType.direct.updateStatsP2Text();
				else HUDType.direct.updateStatsText();
		}
	}

	/**
	 * The base arrow size.
	 */
	public static var arrowSize(default, null):Float = 160 * 0.7;

	/**
	 * The average width you'll get from this field.
	 */
	public var averageWidth(get, null):Float;
	inline function get_averageWidth():Float {
		return (arrowSize * strumCount) + (strumSpacing * (strumCount - 1));
	}
	/**
	 * The total calculated width of the strums.
	 */
	public var totalWidth(default, null):Float;

	/**
	 * Reset's the internal positions of the strums.
	 */
	public function resetInternalPositions():Void {
		for (strum in strums)
			strum.x = 0;

		inline function helper(a:Strum, b:Strum):Void
			if (a != null && b != null)
				b.x = a.x + arrowSize + strumSpacing;

		for (i => strum in strums.members) {
			strum.y = -arrowSize / 2;
			helper(strum, strums.members[i + 1]);
		}

		totalWidth = (strums.members[strums.length - 1].x + strums.members[strums.length - 1].width) - strums.members[0].x;
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
	 * Set's the center position of the field.
	 * @param x The center x position.
	 * @param y The center y position.
	 */
	inline public function setPosition(x:Float = 0, y:Float = 0):Void {
		this.x = x;
		this.y = y;
	}

	/**
	 * The scale of the field.
	 */
	public var scale:FlxPoint;

	/**
	 * The field alpha.
	 */
	public var alpha(get, set):Float;
	inline function get_alpha():Float
		return strums.alpha;
	@:access(imaginative.objects.gameplay.arrows.ArrowModifier.update_alpha)
	inline function set_alpha(value:Float):Float {
		strums.alpha = value;
		for (note in notes)
			note.mods.update_alpha();
		return strums.alpha;
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
			for (sustain in notes.add(note).tail)
				sustains.add(sustain);
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