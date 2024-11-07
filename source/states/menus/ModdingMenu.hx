package states.menus;

class ModdingMenu extends BeatState {
	public var bg:FlxSprite;

	override function create():Void {
		super.create();

		bg = new FlxSprite();
		bg.getBGSprite(FlxColor.MAGENTA);
		bg.scrollFactor.set(0.1, 0.1);
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
	}
}