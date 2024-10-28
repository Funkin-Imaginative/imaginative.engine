package objects.gameplay;

class Strum extends FlxSprite {
	/**
	 * The strum lane index.
	 */
	public var id:Int;

	@:allow(objects.gameplay.ArrowField)
	override function new(id:Int) {
		super();
		this.id = id;
	}
}