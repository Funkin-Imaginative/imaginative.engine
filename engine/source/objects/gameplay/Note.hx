package objects.gameplay;

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
	inline function get_setStrum():Strum {
		return setStrum ?? (setField.strums.members[id] ?? setField.strums.members[idMod]);
	}
	/**
	 * The sustain pieces this note has.
	 */
	public var tail(default, null):BeatTypedGroup<Sustain> = new BeatTypedGroup<Sustain>();

	// Note specific variables.
	/**
	 * The base overall note width.
	 */
	public static var baseWidth(default, null):Float = 160 * 0.7;

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

	// public var scrollSpeed:Float = 0;
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float
		return PlayState.chartData.speed;

	// public var scrollAngle:Float = 270;

	public var lowPriority:Bool = false;

	/**
	 * Any characters in this array will overwrite the notes parent field array.
	 * `May make it contain string instead.`
	 */
	public var assignedActors:Array<Character> = [];

	// important
	public var canHit(get, never):Bool;
	inline function get_canHit():Bool
		return time >= setField.conductor.songPosition - Settings.setupP1.maxWindow && time <= setField.conductor.songPosition + Settings.setupP1.maxWindow;
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return time < setField.conductor.songPosition - (300 / __scrollSpeed) && !wasHit;
	}
	public var pastedStrum(get, never):Bool;
	inline function get_pastedStrum():Bool
		return setField.conductor.songPosition < time;
	public var wasHit:Bool = false;
	public var wasMissed:Bool = false;

	public var canDie:Bool = false;

	override public function new(field:ArrowField, parent:Strum, id:Int, time:Float) {
		setField = field;
		setStrum = parent;
		this.id = id;
		this.time = time;
		tail.memberAdded.add((_:Sustain) -> tail.members.sort(sortTail));
		tail.memberRemoved.add((_:Sustain) -> tail.members.sort(sortTail));

		super(-10000, -10000);

		var dir:String = ['Left', 'Down', 'Up', 'Right'][idMod];

		this.loadTexture('gameplay/arrows/notes');

		animation.addByPrefix('head', 'note$dir', 24, false);

		animation.play('head', true);
		scale.scale(0.7);
		updateHitbox();
		animation.play('head', true);
		updateHitbox();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		followStrum();
	}

	/**
	 * Makes the note follow this strum's position.
	 * @param strum
	 */
	public function followStrum(?strum:Strum):Void {
		strum ??= setStrum;

		var distance:{position:Float, time:Float} = {position: 0, time: 0}
		var scrollAngle:Float = 270;

		var angleDir:Float = Math.PI / 180;
		angleDir = scrollAngle * angleDir;
		var pos:Position = new Position(strum.x, strum.y);
		distance.position = 0.45 * (distance.time = setField.conductor.songPosition - time) * __scrollSpeed;

		// pos.x += offset.x;
		pos.x += Math.cos(angleDir) * distance.position;

		// pos.y += offset.y;
		pos.y += Math.sin(angleDir) * distance.position;
		setPosition(pos.x, pos.y);

		for (sustain in tail) {
			// var scrollAngle:Float = scrollAngle + sustain.scrollAngle;
			var distance:{position:Float, time:Float} = {position: 0, time: 0}
			var angleDir:Float = Math.PI / 180;
			angleDir = scrollAngle * angleDir;
			sustain.angle = scrollAngle - 90;

			var followsParent:Bool = false;//pastedStrum;
			var pos:Position = new Position(followsParent ? x : strum.x, followsParent ? y : strum.y);
			distance.position = 0.45 * (distance.time = setField.conductor.songPosition - ((followsParent ? 0 : time) + sustain.time)) * __scrollSpeed;

			// pos.x += offset.x;
			pos.x -= sustain.width / 2;
			pos.x += (followsParent ? width : strum.width) / 2;
			pos.x += Math.cos(angleDir) * distance.position;

			// pos.y += offset.y;
			pos.y += (followsParent ? width : strum.width) / 2;
			pos.y += Math.sin(angleDir) * distance.position;
			sustain.setPosition(pos.x, pos.y);
		}
	}

	@:allow(objects.gameplay.ArrowField.parse)
	inline static function generateTail(note:Note, length:Float) {
		var roundedLength:Int = Math.round(length / note.setField.conductor.stepCrochet);
		if (roundedLength > 0) {
			for (susNote in 0...roundedLength) {
				var sustain:Sustain = new Sustain(note, (note.setField.conductor.stepCrochet * susNote), susNote == (roundedLength - 1));
				note.tail.add(sustain);
			}
		}
	}


	inline public static function filterNotes(notes:Array<Note>, ?i:Int):Array<Note> {
		var result:Array<Note> = notes.filter((note:Note) -> return note.canHit && !note.wasHit && !note.wasMissed && !note.tooLate && note.id == (i ??= note.id) && !note.canDie);
		result.sort(sortNotes);
		return result;
	}
	inline public static function filterTail(sustains:Array<Sustain>, ?i:Int):Array<Sustain> {
		var result:Array<Sustain> = sustains.filter((sustain:Sustain) -> return sustain.canHit && !sustain.wasHit && !sustain.wasMissed && !sustain.tooLate && sustain.id == (i ??= sustain.id) && !sustain.canDie);
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
		tail.kill();
		super.kill();
	}
	override public function revive():Void {
		tail.revive();
		super.revive();
	}
	override public function destroy():Void {
		tail.destroy();
		super.destroy();
	}
}