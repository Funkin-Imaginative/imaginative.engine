package objects.gameplay;

class Strum extends FlxSprite /* implements ISelfGroup */ {
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
	 * The field the strum is assigned to.
	 */
	public var setField(default, null):ArrowField;

	// Strum specific variables.
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

	@:allow(objects.gameplay.ArrowField.new)
	override function new(field:ArrowField, id:Int) {
		setField = field;
		this.id = id;

		super();

		var dir:String = ['Left', 'Down', 'Up', 'Right'][idMod];

		this.loadTexture('gameplay/arrows/noteStrumline');

		animation.addByPrefix('static', 'static$dir', 24, false);
		animation.addByPrefix('press', 'press$dir', 24, false);
		animation.addByPrefix('confirm', 'confirm$dir', 24, false);

		playAnim('static');
		scale.set(0.7, 0.7);
		updateHitbox();
		playAnim('static');
	}

	/**
	 * Play's an animation.
	 * @param name The animation name.
	 * @param force If true, the game won't care if another one is already playing.
	 * @param reverse If true, the animation will play backwards.
	 * @param frame The starting frame. By default it's 0.
	 *              Although if reversed it will use the last frame instead.
	 */
	public function playAnim(name:String, force:Bool = true, reverse:Bool = false, frame:Int = 0):Void {
		if (animation.exists(name)) {
			animation.play(name, force, reverse, frame);
			centerOffsets();
			centerOrigin();
		}
	}
}