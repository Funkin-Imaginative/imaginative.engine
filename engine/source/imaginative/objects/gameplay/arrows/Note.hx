package imaginative.objects.gameplay.arrows;

class Note extends FlxSprite {
	// Cool variables.
	/**
	 * Custom update function.
	 */
	public var _update:Float->Void;
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * The field the note is assigned to.
	 */
	public var setField(default, null):ArrowField;
	/**
	 * The parent strum of this note.
	 */
	public var setStrum(get, null):Strum;
	inline function get_setStrum():Strum
		return setStrum ?? setField.strums.members[id] ?? setField.strums.members[idMod];
	/**
	 * The sustain pieces this note has.
	 */
	public var tail(default, null):Array<Sustain> = [];
	/**
	 * The tail length in time.
	 */
	public var length(get, never):Float;
	inline function get_length():Float
		return tail.length != 0 ? tail[tail.length - 1].time : 0;

	// Note specific variables.
	/**
	 * The strum lane index.
	 */
	public var id:Int;
	/**
	 * Its just id but with % applied.
	 */
	public var idMod(get, never):Int;
	inline function get_idMod():Int
		return id % setField.strumCount;

	// NOTE: As of rn this is actually in milliseconds!!!!!
	/**
	 * The note position in steps.
	 */
	public var time:Float;

	/**
	 * The scroll speed of this note.
	 */
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float {
		return setField.settings.enablePersonalScrollSpeed ? setField.settings.personalScrollSpeed : (mods.handler.speedIsMult ? setStrum.__scrollSpeed * mods.speed : mods.speed);
	}

	/**
	 * The direction the notes will come from.
	 * This offsets from the strum of the same id's speed.
	 */
	public var scrollAngle(default, set):Float = 0;
	@:access(imaginative.objects.gameplay.arrows.ArrowModifier.update_angle)
	inline function set_scrollAngle(value:Float):Float {
		scrollAngle = value;
		for (sustain in tail)
			sustain.mods.update_angle();
		return value;
	}

	/**
	 * If true this note will have less priority in the input system and in most cases be detected last.
	 */
	public var lowPriority:Bool = false;

	/**
	 * Any characters in this array will overwrite the notes parent field array.
	 * `May make it contain string instead.`
	 */
	public var assignedActors:Array<Character> = [];
	/**
	 * Returns which characters will sing.
	 * @return Array<Character>
	 */
	inline public function renderActors():Array<Character>
		return assignedActors.empty() ? setField.assignedActors : assignedActors;

	// Important
	/**
	 * If true the note can be hit.
	 */
	public var canHit(get, never):Bool;
	inline function get_canHit():Bool
		return time >= setField.conductor.time - setField.settings.maxWindow && time <= setField.conductor.time + setField.settings.maxWindow;
	/**
	 * If true it's too late to hit the note.
	 */
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return time < setField.conductor.time - (300 / Math.abs(__scrollSpeed)) && !wasHit;
	}
	/**
	 * If true the note has pasted the strum.
	 */
	public var pastedStrum(get, never):Bool;
	inline function get_pastedStrum():Bool
		return setField.conductor.time < time;
	/**
	 * If true this note has been hit.
	 */
	public var wasHit:Bool = false;
	/**
	 * If true this note has been missed.
	 */
	public var wasMissed:Bool = false;

	/**
	 * If true along with the tail, this note and it's tail will be destroyed.
	 */
	public var canDie:Bool = false;

	/**
	 * The notes modifiers.
	 */
	public var mods:ArrowModifier;

	override public function new(field:ArrowField, parent:Strum, id:Int, time:Float) {
		setField = field;
		setStrum = parent;
		this.id = id;
		this.time = time;

		super(-10000, -10000);

		var dir:String = ['left', 'down', 'up', 'right'][idMod];

		this.loadTexture('gameplay/arrows/funkin');

		animation.addByPrefix('head', '$dir note head', 24, false);

		animation.play('head', true);
		scale.scale(0.7);
		updateHitbox();
		animation.play('head', true);
		updateHitbox();

		mods = new ArrowModifier(this);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		followStrum();
	}

	/**
	 * Makes the note follow this strums position.
	 * @param strum
	 */
	public function followStrum(?strum:Strum):Void {
		strum ??= setStrum;

		var distance:{position:Float, time:Float} = {position: 0, time: 0}
		var resultAngle:Float = setField.scrollAngle + setStrum.scrollAngle + scrollAngle;
		if (__scrollSpeed < 0) resultAngle += 180;
		resultAngle += setField.strums.angle;

		var angleDir:Float = Math.PI / 180;
		angleDir = resultAngle * angleDir;
		var pos:Position = new Position(strum.x + mods.offset.x, strum.y + mods.offset.x);
		distance.position = 0.45 * (distance.time = setField.conductor.time - time) * Math.abs(__scrollSpeed);

		pos.x += Math.cos(angleDir) * distance.position;
		pos.x -= width / 2;
		pos.x += strum.width / 2;

		pos.y += Math.sin(angleDir) * distance.position;
		pos.y -= height / 2;
		pos.y += strum.height / 2;

		setPosition(
			mods.handler.position.x ? pos.x : x,
			mods.handler.position.y ? pos.y : y
		);

		for (sustain in tail) {
			var resultAngle:Float = resultAngle + sustain.scrollAngle;
			var distance:{position:Float, time:Float} = {position: 0, time: 0}
			var angleDir:Float = Math.PI / 180;
			angleDir = resultAngle * angleDir;

			var pos:Position = new Position(strum.x + sustain.mods.offset.x, strum.y + sustain.mods.offset.y);
			distance.position = 0.45 * (distance.time = setField.conductor.time - (time + sustain.time)) * Math.abs(sustain.__scrollSpeed);

			pos.x += Math.cos(angleDir) * distance.position;
			pos.x -= sustain.width / 2;
			pos.x += strum.width / 2;

			pos.y += Math.sin(angleDir) * distance.position;
			pos.y += strum.height / 2;

			sustain.setPosition(
				sustain.mods.handler.position.x ? pos.x : sustain.x,
				sustain.mods.handler.position.y ? pos.y : sustain.y
			);
		}
	}

	@:allow(imaginative.objects.gameplay.arrows.ArrowField.parse)
	inline static function generateTail(note:Note, length:Float):Void {
		var roundedLength:Int = Math.round(length / note.setField.conductor.stepTime);
		if (roundedLength > 0) {
			for (susNote in 0...roundedLength) {
				var sustain:Sustain = new Sustain(note, (note.setField.conductor.stepTime * susNote), susNote == (roundedLength - 1));
				note.tail.push(sustain);
			}
			note.tail.sort(sortTail);
		}
	}

	/**
	 * Filters an array of notes.
	 * @param notes An array of notes.
	 * @param i Specified note id. This is optional.
	 * @return Array<Note> ~ Resulting filter.
	 */
	inline public static function filterNotes(notes:Array<Note>, ?i:Int):Array<Note> {
		var result:Array<Note> = notes.filter((note:Note) -> return note.canHit && !note.wasHit && !note.wasMissed && !note.tooLate && note.id == (i ?? note.id) && !note.canDie);
		result.sort(sortNotes);
		return result;
	}
	/**
	 * Filters an array of sustains.
	 * @param sustains An array of sustains.
	 * @param isMiss If true then this filters out sustains that can't be hit.
	 * @param i Specified sustain id. This is optional.
	 * @return Array<Sustain> ~ Resulting filter.
	 */
	inline public static function filterTail(sustains:Array<Sustain>, isMiss:Bool = false, ?i:Int):Array<Sustain> {
		var result:Array<Sustain> = sustains.filter((sustain:Sustain) -> return (isMiss ? true : sustain.canHit) && !sustain.wasHit && !sustain.wasMissed && !sustain.tooLate && sustain.id == (i ?? sustain.id) && !sustain.canDie);
		result.sort(sortTail);
		return result;
	}

	/**
	 * Helper function for sorting an array of notes.
	 * @param a Note a.
	 * @param b Note b.
	 * @return Int
	 */
	inline public static function sortNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority) return 1;
		else if (!a.lowPriority && b.lowPriority) return -1;
		return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
	}
	/**
	 * Helper function for sorting an array of sustains.
	 * @param a Note a.
	 * @param b Note b.
	 * @return Int
	 */
	inline public static function sortTail(a:Sustain, b:Sustain):Int
		return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);

	override public function kill():Void {
		for (sustain in tail)
			sustain.kill();
		super.kill();
	}
	override public function revive():Void {
		for (sustain in tail)
			sustain.revive();
		super.revive();
	}
	override public function destroy():Void {
		for (sustain in tail)
			sustain.destroy();
		super.destroy();
	}
}