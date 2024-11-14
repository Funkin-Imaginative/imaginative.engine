package objects.gameplay;

/**
 * States what note part it is.
 */
enum abstract NotePart(String) from String to String {
	/**
	 * The head of the note.
	 */
	var NoteHead = 'Head';
	/**
	 * A tail piece of a sustain.
	 */
	var NoteTail = 'Tail';
	/**
	 * The end of a sustain.
	 */
	var NoteEnd = 'End';
}

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

	// Note specific variables.
	/**
	 * The base overall note width.
	 */
	public static var baseWidth(default, null):Float = 160 * 0.7;

	/**
	 * States what note part it is.
	 */
	public var part(default, null):NotePart;
	/**
	 * The strum lane index.
	 */
	public var id(default, null):Int;
	/**
	 * Its just id but with % applied.
	 */
	public var idMod(get, null):Int;
	inline function get_idMod():Int
		return id % setField.strumCount;

	@:allow(objects.gameplay.ArrowField.parse)
	override function new(field:ArrowField, id:Int, time:Float, part:NotePart = NoteHead) {
		setField = field;
		this.id = id;

		super(-10000, -10000);

		var col:String = ['purple', 'blue', 'green', 'red'][idMod];

		this.loadTexture('gameplay/notes/NOTE_assets');

		switch (this.part = part) {
			case NoteHead: animation.addByPrefix('note', '${col}0', 24);
			case NoteTail: animation.addByPrefix('note', '$col hold piece', 24);
			case NoteEnd: animation.addByPrefix('note', '$col hold end', 24);
		}

		animation.play('note', true);
		scale.set(0.7, 0.7);
		updateHitbox();
	}
}