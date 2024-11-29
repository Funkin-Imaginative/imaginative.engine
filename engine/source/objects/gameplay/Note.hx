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
	 *
	 */
	public var time:Float;

	@:allow(objects.gameplay.ArrowField.parse)
	override function new(field:ArrowField, id:Int, time:Float) {
		setField = field;
		this.id = id;

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

	@:allow(objects.gameplay.ArrowField.parse)
	static function generateSustain(note:Note, length:Float) {
		if (length > 0) {
			var sustain:Sustain = new Sustain(note);
			note.tail.add(sustain);
		}
	}
}