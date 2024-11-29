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

	public var isEnd:Bool;

	override public function new(parent:Note, end:Bool = false) {
		setParent = parent;
		end;

		super(-10000, -10000);

		var col:String = ['purple', 'blue', 'green', 'red'][idMod];

		// this.loadTexture('gameplay/notes/NOTE_assets');
		makeGraphic(50, end ? 60 : 80, (end ? [0x3c1f56, 0x1542b7, 0x0a4447, 0x651038] : [0xc24b99, 0x00ffff, 0x12fa05, 0xf9393f])[idMod]);

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