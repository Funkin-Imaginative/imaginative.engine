package objects.gameplay;

class Sustain extends FlxSprite {
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
	public var setField(get, never):ArrowField;
	inline function get_setField():ArrowField
		return setParent.setField;
	/**
	 * The parent note of this sustain.
	 */
	public var setParent(default, null):Note;

	// public var scrollAngle:Float = 0;

	/**
	 * The strum lane index.
	 */
	public var id(get, never):Int;
	inline function get_id():Int
		return setParent.id;
	/**
	 * Its just id but with % applied.
	 */
	public var idMod(get, null):Int;
	inline function get_idMod():Int
		return id % setField.strumCount;

	/**
	 * The sustain position in steps, is an offset of the parent's time.
	 */
	public var time:Float;

	public var isEnd(default, null):Bool;
	@:unreflective inline public function setEnd(value:Bool):Bool
		return isEnd = value;

	public var canHit(get, never):Bool;
	inline function get_canHit():Bool {
		return (time + setParent.time) >= setField.conductor.songPosition - Settings.setupP1.maxWindow && (time + setParent.time) <= setField.conductor.songPosition + Settings.setupP1.maxWindow;
	}
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return (time + setParent.time) < setField.conductor.songPosition - (300 / setParent.__scrollSpeed) && wasHit;
	}
	public var wasHit(default, null):Bool = false;
	@:allow(objects.gameplay.ArrowField.input)
	@:unreflective inline function hasBeenHit():Bool
		return wasHit = true;

	/**
	 * Any character tag names in this array will overwrite the notes field array.
	 */
	public var assignedSingers(get, set):Array<Character>;
	inline function get_assignedSingers():Array<Character>
		return setParent.assignedSingers;
	inline function set_assignedSingers(value:Array<Character>):Array<Character>
		return setParent.assignedSingers = value;

	override public function new(parent:Note, time:Float, end:Bool = false) {
		setParent = parent;
		this.time = time;
		isEnd = end;

		super(setParent.x, setParent.y);

		var col:String = ['purple', 'blue', 'green', 'red'][idMod];

		// this.loadTexture('gameplay/notes/NOTE_assets');
		makeGraphic(50, end ? 60 : 80, (end ? [0xff3c1f56, 0xff1542b7, 0xff0a4447, 0xff651038] : [0xffc24b99, 0xff00ffff, 0xff12fa05, 0xfff9393f])[idMod]);

		var name:String = end ? 'end' : 'hold';
		// case NoteTail: animation.addByPrefix('hold', '$col hold piece', 24, false);
		// case NoteEnd: animation.addByPrefix('end', '$col hold end', 24, false);

		// animation.play(name, true);
		scale.scale(0.7);
		updateHitbox();
		// animation.play(name, true);
		// updateHitbox();
		origin.y = 0;
	}
}