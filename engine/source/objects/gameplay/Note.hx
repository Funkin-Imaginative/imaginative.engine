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
	public var setParent(get, null):Strum;
	inline function get_setParent():Strum
		return setParent ?? setField.strums.members[idMod];
	/**
	 * The sustain pieces this note has.
	 */
	public var tail:BeatTypedGroup<Sustain> = new BeatTypedGroup<Sustain>();

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
	public var idMod(get, null):Int;
	inline function get_idMod():Int
		return id % setField.strumCount;

	/**
	 * The note position in steps.
	 */
	public var time:Float;

	// public var scrollSpeed:Float = 0;
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float
		return PlayState.chartData.speed;

	// public var scrollAngle:Float = 270;

	/**
	 * Any character tag names in this array will overwrite the notes field array.
	 */
	public var assignedSingers:Array<Character> = [];

	// important
	public var canHit(get, never):Bool;
	inline function get_canHit():Bool
		return time >= Conductor.song.songPosition - Settings.setupP1.maxWindow && time <= Conductor.song.songPosition + Settings.setupP1.maxWindow;
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return time < Conductor.song.songPosition - (300 / __scrollSpeed) && wasHit;
	}
	public var pastedStrum(get, never):Bool;
	inline function get_pastedStrum():Bool
		return Conductor.song.songPosition < time;
	public var wasHit(default, null):Bool = false;
	@:allow(objects.gameplay.ArrowField.input)
	@:unreflective inline function hasBeenHit():Bool
		return wasHit = true;

	@:allow(objects.gameplay.ArrowField.parse)
	override function new(field:ArrowField, parent:Strum, id:Int, time:Float) {
		setField = field;
		setParent = parent;
		this.id = id;
		this.time = time;

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
		// if (tooLate && !wasHit)
	}

	/**
	 * Makes the note follow this strum's position.
	 * @param strum
	 */
	public function followStrum(?strum:Strum):Void {
		strum ??= setParent;

		var distance:{position:Float, time:Float} = {position: 0, time: 0}
		var scrollAngle:Float = 270;

		var angleDir:Float = Math.PI / 180;
		angleDir = scrollAngle * angleDir;
		var pos:Position = new Position(strum.x, strum.y);
		distance.position = 0.45 * (distance.time = Conductor.song.songPosition - time) * __scrollSpeed;

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

			var followsParent:Bool = !pastedStrum;
			var pos:Position = new Position(followsParent ? x : strum.x, followsParent ? y : strum.y);
			distance.position = 0.45 * (distance.time = Conductor.song.songPosition - ((followsParent ? 0 : time) + sustain.time)) * __scrollSpeed;

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
		final roundedLength:Int = Math.round(length / Conductor.song.stepCrochet);
		if (roundedLength > 0) {
			for (susNote in 0...roundedLength) {
				var sustain:Sustain = new Sustain(note, (Conductor.song.stepCrochet * susNote), susNote == roundedLength);
				note.tail.add(sustain);
			}
		}
	}
}