package imaginative.objects.gameplay;

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
	 * The field the sustain is assigned to.
	 */
	public var setField(get, never):ArrowField;
	inline function get_setField():ArrowField
		return setHead.setField;
	/**
	 * The parent strum of this note.
	 */
	public var setStrum(get, null):Strum;
	inline function get_setStrum():Strum
		return setHead.setStrum;
	/**
	 * The parent note of this sustain.
	 */
	public var setHead(default, null):Note;

	// public var scrollAngle:Float = 0;

	/**
	 * The strum lane index.
	 */
	public var id(get, never):Int;
	inline function get_id():Int
		return setHead.id;
	/**
	 * Its just id but with % applied.
	 */
	public var idMod(get, never):Int;
	inline function get_idMod():Int
		return id % setField.strumCount;

	/**
	 * NOTE: As of rn this is actually in milliseconds!!!!!
	 * The sustain position in steps, is an offset of the parent's time.
	 */
	public var time:Float;

	public var isEnd(default, null):Bool;

	/**
	 * Any characters in this array will overwrite the sustains parent field array.
	 * `May make it contain string instead.`
	 */
	public var assignedActors(get, set):Array<Character>;
	inline function get_assignedActors():Array<Character>
		return setHead.assignedActors;
	inline function set_assignedActors(value:Array<Character>):Array<Character>
		return setHead.assignedActors = value;
	inline public function renderActors():Array<Character>
		return setHead.renderActors();

	public var canHit(get, never):Bool;
	inline function get_canHit():Bool {
		return (time + setHead.time) >= setField.conductor.time - Settings.setupP1.maxWindow && (time + setHead.time) <= setField.conductor.time + Settings.setupP1.maxWindow;
	}
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return (time + setHead.time) < setField.conductor.time - (300 / setHead.__scrollSpeed) && !wasHit;
	}
	public var wasHit:Bool = false;
	public var wasMissed:Bool = false;

	public var canDie:Bool = false;

	override public function new(parent:Note, time:Float, end:Bool = false) {
		setHead = parent;
		this.time = time;
		isEnd = end;

		super(setHead.x, setHead.y);

		var col:String = ['purple', 'blue', 'green', 'red'][idMod];

		// this.loadTexture('gameplay/notes/NOTE_assets');
		makeGraphic(50, isEnd ? 60 : 80, (isEnd ? [0xff3c1f56, 0xff1542b7, 0xff0a4447, 0xff651038] : [0xffc24b99, 0xff00ffff, 0xff12fa05, 0xfff9393f])[idMod]);

		var name:String = isEnd ? 'end' : 'hold';
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