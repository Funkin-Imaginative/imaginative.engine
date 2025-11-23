package imaginative.objects.gameplay.arrows;

import imaginative.backend.scripting.events.gameplay.*;
import imaginative.objects.gameplay.arrows.group.NoteGroup;
import imaginative.objects.gameplay.arrows.group.StrumGroup;
import imaginative.objects.gameplay.arrows.group.SustainGroup;
import imaginative.objects.gameplay.hud.HUDType;
import imaginative.states.editors.ChartEditor.ChartField;

typedef FieldSetupData = {
	var x:Float;
	var scale:Float;
}

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
		return conductor ?? Conductor.mainInstance;

	// Even though you can have a but ton of 'ArrowField's you can ***ONLY*** play as one!
	/**
	 * The main enemy field.
	 */
	public static var enemy(default, set):Null<ArrowField>;
	inline static function set_enemy(?value:ArrowField):Null<ArrowField> {
		enemy = value;
		// sets the lane count for the controls instance
		if (enemy != null) enemy.controls.laneCount = enemy.laneCount;
		return enemy;
	}
	/**
	 * The main player field.
	 */
	public static var player(default, set):Null<ArrowField>;
	inline static function set_player(?value:ArrowField):Null<ArrowField> {
		player = value;
		// sets the lane count for the controls instance
		if (player != null) player.controls.laneCount = player.laneCount;
		return player;
	}

	/**
	 * Returns x position and scaling data for an array of fields.
	 * @param fields Array of fields.
	 * @return Array<FieldSetupData> ~ The data for field x position and scaling.
	 */
	public static function getFieldSetupData(fields:Array<ArrowField>):Array<FieldSetupData> {
		if (fields.empty()) return [];
		var setupData:Array<FieldSetupData> = [];
		for (i => field in fields) {
			var data:FieldSetupData = {x: 0, scale: 1}
			var camera = field.getDefaultCamera();
			data.x = camera.width * i / fields.length;
			data.x += camera.width / fields.length / 2;
			setupData.push(data);
		}
		return setupData;
	}

	/**
	 * If enabled botplay will be activate when entering a song.
	 */
	public static var botplay:Bool = false;
	/**
	 * If enabled you play as the enemy instead of the player.
	 */
	public static var enemyPlay:Bool = false;
	/**
	 * If enabled the enemy will be controlled by a second player.
	 * But with enemyPlay your swapped around, making P1 the enemy and P2 the player.
	 */
	public static var enableP2:Bool = false;

	// TODO: Figure out how to do this better.
	inline public static function characterSing(field:ArrowField, actors:Array<Character>, id:Int, context:AnimationContext, force:Bool = true, ?suffix:String):Void {
		for (char in field.previousInteractedActors = actors.filter((char:Character) -> return char != null)) {
			char.controls = field.isPlayer ? field.controls : null;
			var temp:String = ['LEFT', 'DOWN', 'UP', 'RIGHT'][id];
			char.playAnim('sing$temp', force, context, suffix);
			char.lastHit = field.conductor.time;
		}
	}

	/**
	 * States if its the main enemy or player field.
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
	 * If true this field is maintained by a player.
	 */
	public var isPlayer(get, never):Bool;
	inline function get_isPlayer():Bool {
		return status != null && (status != enemyPlay || enableP2) && !botplay;
	}

	/**
	 * The field controls instance.
	 */
	public var controls(get, never):PlayerControls;
	inline function get_controls():PlayerControls {
		if (status == null) return Controls.blank;
		return status == enemyPlay ? Controls.p2 : Controls.p1;
	}
	/**
	 * The field settings instance.
	 */
	public var settings(get, never):PlayerSettings;
	inline function get_settings():PlayerSettings {
		if (status == null) return Settings.setupP1;
		return status == enemyPlay ? Settings.setupP2 : Settings.setupP1;
	}
	/**
	 * The field stats instance.
	 */
	public var stats(get, never):PlayerStats;
	inline function get_stats():PlayerStats {
		if (status == null) return Scoring.unregisteredStats;
		return status == enemyPlay ? Scoring.statsP2 : Scoring.statsP1;
	}

	// FlxSignals
	/**
	 * Dispatches when user input happens at all.
	 */
	public var userInput(default, null):FlxTypedSignal<FieldInputEvent->Void> = new FlxTypedSignal<FieldInputEvent->Void>();
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
	 * Any characters in this array will react to notes for this field.
	 * `May make it contain string instead.`
	 */
	public var assignedActors:Array<Character>;
	/**
	 * States what characters last sang for this field.
	 * Used for tracking you should be the target character for gameovers.
	 */
	public var previousInteractedActors:Array<Character> = [];

	/**
	 * If true then the note rendering process is active.
	 */
	public var activateNoteRendering:Bool = true;

	/**
	 * The strums of the field.
	 */
	public var strums(default, null):StrumGroup;
	/**
	 * The notes of the field.
	 */
	public var notes(default, null):NoteGroup;
	/**
	 * The sustains of the field.
	 */
	public var sustains(default, null):SustainGroup;

	/**
	 * How far out until a note is killed.
	 */
	public var noteKillRange:Float = 350;
	/**
	 * The distance between the each lane.
	 */
	public var laneSpacing:Float = 7;
	/**
	 * Used for psych "middlescroll" type shit.
	 */
	public var centerSpacing:Null<Float> = null;

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
	 * @return Float ~ Target scroll speed.
	 */
	inline public function getScrollSpeed():Float
		return settings.enablePersonalScrollSpeed ? settings.personalScrollSpeed : scrollSpeed;
	/**
	 * The scroll speed of the field.
	 * This overrides the base chart speed.
	 * When "null" is returns the base chart speed.
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
		scrollAngle = value ?? (settings.downscroll ? 90 : 270);
		for (sustain in sustains)
			sustain.mods.update_angle();
		return value;
	}

	/**
	 * The amount of strums in the field.
	 * Forced to 4 *for now*.
	 */
	public var laneCount(get, never):Int;
	inline function get_laneCount():Int
		return strums.length;

	@:access(imaginative.objects.gameplay.arrows.ArrowModifier.update_scale)
	override public function new(?singers:Array<Character>, startCount:Int = 4) {
		strums = new StrumGroup(this);
		notes = new NoteGroup(strums);
		sustains = new SustainGroup(notes);
		super();

		// runs the "set_" function
		scrollSpeed = null;
		scrollAngle = null;

		scale = new FlxCallbackPoint(
			(point:FlxPoint) -> {
				strums.scale.copyFrom(point);
				strums.scale.scale(arrowScale);
				for (note in notes)
					note.mods.update_scale();
			}
		);

		strums.setLineup(4);
		scale.set(1, 1); // wasn't set to 1 by default apparently
		resetInternalPositions();
		setPosition(getDefaultCamera().width / 2, getDefaultCamera().height / 2);

		assignedActors = singers ?? [];

		add(strums);
		add(notes);
		insert(members.indexOf(false ? strums : notes), sustains); // behindStrums
	}

	inline function _input():Void {
		for (i => strum in strums.members)
			input(i, strum, controls.notePressed(i), controls.noteHeld(i), controls.noteReleased(i));
	}

	// TODO: Rework this.
	/**
	 * Where input stuff really begins.
	 * @param i The lane index.
	 * @param strum The strum object instance.
	 * @param hasHit If true a bind was pressed.
	 * @param beingHeld If true a bind is being held.
	 * @param wasReleased If true a bind was released.
	 */
	function input(i:Int, strum:Strum, hasHit:Bool, beingHeld:Bool, wasReleased:Bool):Void {
		var event:FieldInputEvent = new FieldInputEvent(i, strum, this, hasHit, beingHeld, wasReleased);
		userInput.dispatch(event);
		if (event.prevented) return;

		// note hits
		if (hasHit) {
			var activeNotes:Array<Note> = Note.filterNotes(notes.members, i);
			if (!activeNotes.empty()) {
				var frontNote:Note = activeNotes[0]; // took from psych, fixes a dumb issue where it eats up jacks
				if (activeNotes.length > 2) {
					var backNote:Note = activeNotes[1];
					if (Math.abs(backNote.time - frontNote.time) < 1.0) {
						var liveNote:Note = backNote.length < frontNote.length ? backNote : frontNote;
						var deadNote:Note = backNote.length < frontNote.length ? frontNote : backNote;
						deadNote.destroy(); // shouldn't need to keep existing
						frontNote = liveNote;
					} else if (backNote.time < frontNote.time)
						frontNote = backNote;
				}
				_onNoteHit(frontNote, i);
			} else {
				// void hits (random key presses / ghost tapping)
				var event:VoidMissEvent = new VoidMissEvent(settings.ghostTapping, i, this);
				onVoidMiss.dispatch(event);
				if (!event.prevented) {
					if (!event.stopStrumPress)
						event.strum.playAnim('press', !event.triggerMiss);
					if (event.triggerMiss)
						FlxG.sound.play(Assets.sound('gameplay/missnote${FlxG.random.int(1, 3)}'), 0.7);
					event.field.updateStatsText();
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

		// auto hit and note miss
		notes.forEachExists((note:Note) -> {
			if (note.tooLate && (conductor.time - note.time) > Math.max(conductor.stepTime, noteKillRange / Math.abs(note.__scrollSpeed)))
				if (!note.wasHit && !note.wasMissed)
					_onNoteMissed(note);
			if (!isPlayer)
				if (note.time <= conductor.time && !note.tooLate && !note.wasHit && !note.wasMissed)
					_onNoteHit(note);
		});
		// auto hit and sustain miss
		sustains.forEachExists((sustain:Sustain) -> {
			if (sustain.tooLate && (conductor.time - (sustain.time + sustain.setHead.time)) > Math.max(conductor.stepTime, noteKillRange / Math.abs(sustain.__scrollSpeed)))
				if (!sustain.wasHit && !sustain.wasMissed)
					_onSustainMissed(sustain);
			if (!isPlayer)
				if ((sustain.time + sustain.setHead.time) <= conductor.time && !sustain.tooLate && !sustain.wasHit && !sustain.wasMissed)
					_onSustainHit(sustain);
		});
		// checks when a note and its tail can be killed
		notes.forEachExists((note:Note) -> {
			var canKill:Array<Bool> = [(note.wasHit || note.wasMissed) && note.tooLate];
			for (sustain in note.tail)
				canKill.push((sustain.wasHit || sustain.wasMissed) && sustain.tooLate);
			if (!canKill.contains(false)) {
				_log('[ArrowField] Lineage Killed: $note', DebugMessage);
				note.kill();
			} else note.followStrum();
			canKill = canKill.clearArray();
		});

		super.update(elapsed);
	}

	/**
	 * Shortcut function to update the stats text of the hud.
	 */
	inline public function updateStatsText():Void
		if (status != null && HUDType.instance != null)
			if (status == enemyPlay) HUDType.instance.updateStatsP2Text();
			else HUDType.instance.updateStatsText();

	// TODO: Figure out how to do this better.
	function _onNoteHit(note:Note, ?i:Int):Void {
		if (note.wasHit) return;
		i ??= note.id;
		note.wasHit = true;
		note.visible = false;
		var event:NoteHitEvent = new NoteHitEvent(note, i, this);
		onNoteHit.dispatch(event);
		if (!event.prevented) {
			if (event.field.isPlayer) {
				event.field.stats.score += 350;
				event.field.stats.combo++;
				event.field.stats.hits++;
			}
			// using event as mush as we can, jic scripts somehow edit everything 💀
			if (!event.stopStrumConfirm)
				event.note.setStrum.playAnim('confirm', true);
			event.field.updateStatsText();
		}
	}
	function _onSustainHit(sustain:Sustain, ?i:Int):Void {
		if (sustain.wasHit) return;
		i ??= sustain.id;
		sustain.wasHit = true;
		sustain.visible = false;
		var event:SustainHitEvent = new SustainHitEvent(sustain, i, this);
		onSustainHit.dispatch(event);
		if (!event.prevented) {
			if (event.field.isPlayer)
				event.field.stats.score += 30;
			if (!event.stopStrumConfirm)
				event.sustain.setStrum.playAnim('confirm', true);
			event.field.updateStatsText();
		}
	}
	function _onNoteMissed(note:Note, ?i:Int):Void {
		if (note.wasMissed) return;
		i ??= note.id;
		note.wasMissed = true;
		note.mods.alpha *= 0.86;
		var event:NoteMissedEvent = new NoteMissedEvent(note, i, this, isPlayer);
		onNoteMissed.dispatch(event);
		if (!event.prevented) {
			FlxG.sound.play(Assets.sound('gameplay/missnote${FlxG.random.int(1, 3)}'), 0.7);
			if (event.field.settings.missFullSustain)
				for (sustain in Note.filterTail(event.note.tail, true)) {
					sustain.wasMissed = true;
					sustain.mods.alpha *= 0.86;
				}
			if (event.field.isPlayer) {
				event.field.stats.score -= 50;
				event.field.stats.combo = 0;
				event.field.stats.misses++;
			}
			if (!event.stopStrumPress)
				event.note.setStrum.playAnim('press', !event.field.isPlayer);
			event.field.updateStatsText();
		}
	}
	function _onSustainMissed(sustain:Sustain, ?i:Int):Void {
		if (sustain.wasMissed) return;
		i ??= sustain.id;
		sustain.wasMissed = true;
		sustain.mods.alpha *= 0.86;
		var event:SustainMissedEvent = new SustainMissedEvent(sustain, i, this, isPlayer);
		onSustainMissed.dispatch(event);
		if (!event.prevented) {
			FlxG.sound.play(Assets.sound('gameplay/missnote${FlxG.random.int(1, 3)}'), 0.7);
			if (event.field.settings.missFullSustain)
				for (sustain in Note.filterTail(event.sustain.setHead.tail, true)) {
					sustain.wasMissed = true;
					sustain.mods.alpha *= 0.86;
				}
			if (event.field.isPlayer) {
				event.field.stats.score -= 20;
				event.field.stats.combo = 0;
				event.field.stats.misses++;
			}
			if (!event.stopStrumPress)
				event.sustain.setStrum.playAnim('press', !event.field.isPlayer);
			event.field.updateStatsText();
		}
	}

	/**
	 * The base arrow scale.
	 * Scale being the objects scale variable.
	 */
	public static var arrowScale:Float = 0.7;
	/**
	 * The base arrow size.
	 * Size being the objects width and height.
	 */
	public static var arrowSize(default, null):Float = 150 * arrowScale; // 150 being the average width and height of the base note textures

	/**
	 * The average width you'll get from this field.
	 */
	public var averageWidth(get, never):Float;
	inline function get_averageWidth():Float {
		return (arrowSize * laneCount) + (laneSpacing * (laneCount - 2)) + (centerSpacing ?? laneSpacing);
	}
	/**
	 * The total calculated width of the strums.
	 * Would use an automatic method like 'FlxSpriteGroup's shit but doesn't work right for some reason.
	 */
	public var totalWidth:Float = 0;
	/* inline function get_totalWidth():Float {
		if (strums.members.empty()) return 0;
		return findMaxStrumsX() - findMinStrumsX();
	}
	// these were taken from 'FlxSpriteGroup'
	function findMinStrumsX():Float {
		var value = Math.POSITIVE_INFINITY;
		for (member in strums) {
			if (member == null) continue;

			var minX:Float;
			if (member.flixelType == SPRITEGROUP) minX = (cast member:FlxSpriteGroup).findMinX();
			else minX = member.x;

			if (minX < value)
				value = minX;
		}
		return value;
	}
	function findMaxStrumsX():Float {
		var value = Math.NEGATIVE_INFINITY;
		for (member in strums) {
			if (member == null) continue;

			var maxX:Float;
			if (member.flixelType == SPRITEGROUP) maxX = (cast member:FlxSpriteGroup).findMaxX();
			else maxX = member.x + member.width;

			if (maxX > value)
				value = maxX;
		}
		return value;
	} */

	/**
	 * Resets the internal positions of the strums.
	 */
	public function resetInternalPositions():Void {
		for (strum in strums)
			strum.x = 0;

		inline function helper(a:Strum, b:Strum, isMiddle:Bool = false):Void {
			if (a != null && b != null)
				b.x = a.x + (arrowSize * Math.abs(scale.x)) + (isMiddle ? centerSpacing ?? laneSpacing : laneSpacing);
		}

		for (i => strum in strums.members) {
			strum.y = -(arrowSize * Math.abs(scale.y)) / 2;
			helper(strum, strums.members[i + 1], i == Math.floor(strums.length / 2) - 1);
		}
		totalWidth = (strums.members.last().x + strums.members.last().width) - strums.members[0].x;
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
	 * Sets the center position of the field.
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
	 * Parses 'ChartField' information.
	 * @param data The 'ChartField' data.
	 */
	public function parse(data:ChartField):Void {
		for (base in data.notes) {
			var note:Note = new Note(this, base.id, base.time, base.length);
			var lol:Array<String> = base.characters ??= [];
			note.assignedActors = PlayState.instance == null ? [] : [
				for (tag => char in PlayState.instance.characterMapping)
					if (lol.contains(tag))
						char
			];
		}
	}

	override public function destroy():Void {
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