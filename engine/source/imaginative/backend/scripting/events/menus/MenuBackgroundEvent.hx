package imaginative.backend.scripting.events.menus;

final class MenuBackgroundEvent extends ScriptEvent {
	/**
	 * FlxColor input.
	 */
	public var color:FlxColor;
	/**
	 * It true, when using FlxColor YELLOW, BLUE, MAGENTA, or GRAY it will use the menuBG color instead.
	 */
	public var funkinColor:Bool;

	/**
	 * The mod path type.
	 */
	public var imagePathType:ModType;

	override public function new(color:FlxColor = FlxColor.YELLOW, funkinColor:Bool = true, imagePathType:ModType = ANY) {
		super();
		this.color = color;
		this.funkinColor = funkinColor;
		this.imagePathType = imagePathType;
	}
}