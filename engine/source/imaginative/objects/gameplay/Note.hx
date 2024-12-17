package imaginative.objects.gameplay;

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

	/**
	 * NOTE: As of rn this is actually in milliseconds!!!!!
	 * The note position in steps.
	 */
	public var time:Float;

	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float
		return mods.apply.speedIsMult ? setStrum.__scrollSpeed * mods.speed : mods.speed;

	// public var scrollAngle:Float = 270;

	public var lowPriority:Bool = false;

	/**
	 * Any characters in this array will overwrite the notes parent field array.
	 * `May make it contain string instead.`
	 */
	public var assignedActors:Array<Character> = [];
	inline public function renderActors():Array<Character>
		return assignedActors.length == 0 ? setField.assignedActors : assignedActors;

	// important
	public var canHit(get, never):Bool;
	inline function get_canHit():Bool
		return time >= setField.conductor.time - Settings.setupP1.maxWindow && time <= setField.conductor.time + Settings.setupP1.maxWindow;
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return time < setField.conductor.time - (300 / Math.abs(__scrollSpeed)) && !wasHit;
	}
	public var pastedStrum(get, never):Bool;
	inline function get_pastedStrum():Bool
		return setField.conductor.time < time;
	public var wasHit:Bool = false;
	public var wasMissed:Bool = false;

	public var canDie:Bool = false;

	public var mods:ArrowModifier;

	override public function new(field:ArrowField, parent:Strum, id:Int, time:Float) {
		setField = field;
		setStrum = parent;
		this.id = id;
		this.time = time;

		super(-10000, -10000);

		var dir:String = ['left', 'down', 'up', 'right'][idMod];

		this.loadTexture('gameplay/arrows/funkin');

		animation.addByPrefix('head', '$dir head', 24, false);

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
		mods.update(elapsed);
	}

	/**
	 * Makes the note follow this strum's position.
	 * @param strum
	 */
	public function followStrum(?strum:Strum):Void {
		strum ??= setStrum;

		var distance:{position:Float, time:Float} = {position: 0, time: 0}
		var scrollAngle:Float = setField.settings.downscroll ? 90 : 270;
		if (__scrollSpeed < 0) scrollAngle += 180;
		scrollAngle += setField.strums.angle;

		var angleDir:Float = Math.PI / 180;
		angleDir = scrollAngle * angleDir;
		var pos:Position = new Position(strum.x + mods.offset.x, strum.y + mods.offset.x);
		distance.position = 0.45 * (distance.time = setField.conductor.time - time) * Math.abs(__scrollSpeed);

		pos.x -= width / 2;
		pos.x += strum.width / 2;
		pos.x += Math.cos(angleDir) * distance.position;

		pos.y -= height / 2;
		pos.y += strum.height / 2;
		pos.y += Math.sin(angleDir) * distance.position;

		setPosition(
			mods.apply.position.x ? pos.x : x,
			mods.apply.position.y ? pos.y : y
		);

		for (sustain in tail) {
			// var scrollAngle:Float = scrollAngle + sustain.scrollAngle;
			var distance:{position:Float, time:Float} = {position: 0, time: 0}
			var angleDir:Float = Math.PI / 180;
			angleDir = scrollAngle * angleDir;
			sustain.angle = scrollAngle + 90;

			var pos:Position = new Position(strum.x + sustain.mods.offset.x, strum.y + sustain.mods.offset.y);
			distance.position = 0.45 * (distance.time = setField.conductor.time - (time + sustain.time)) * Math.abs(sustain.__scrollSpeed);

			pos.x -= sustain.width / 2;
			pos.x += strum.width / 2;
			pos.x += Math.cos(angleDir) * distance.position;

			pos.y += strum.height / 2;
			pos.y += Math.sin(angleDir) * distance.position;

			sustain.setPosition(
				sustain.mods.apply.position.x ? pos.x : sustain.x,
				sustain.mods.apply.position.y ? pos.y : sustain.y
			);
		}
	}

	@:allow(imaginative.objects.gameplay.ArrowField.parse)
	inline static function generateTail(note:Note, length:Float) {
		var roundedLength:Int = Math.round(length / note.setField.conductor.stepTime);
		if (roundedLength > 0) {
			for (susNote in 0...roundedLength) {
				var sustain:Sustain = new Sustain(note, (note.setField.conductor.stepTime * susNote), susNote == (roundedLength - 1));
				note.tail.push(sustain);
			}
			note.tail.sort(sortTail);
		}
	}


	inline public static function filterNotes(notes:Array<Note>, ?i:Int):Array<Note> {
		var result:Array<Note> = notes.filter((note:Note) -> return note.canHit && !note.wasHit && !note.wasMissed && !note.tooLate && note.id == (i ?? note.id) && !note.canDie);
		result.sort(sortNotes);
		return result;
	}
	inline public static function filterTail(sustains:Array<Sustain>, isMiss:Bool = false, ?i:Int):Array<Sustain> {
		var result:Array<Sustain> = sustains.filter((sustain:Sustain) -> return (isMiss ? true : sustain.canHit) && !sustain.wasHit && !sustain.wasMissed && !sustain.tooLate && sustain.id == (i ?? sustain.id) && !sustain.canDie);
		result.sort(sortTail);
		return result;
	}

	inline public static function sortNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority) return 1;
		else if (!a.lowPriority && b.lowPriority) return -1;
		return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
	}
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