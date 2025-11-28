package imaginative.states.menus;

#if MOD_SUPPORT
class ModdingMenu extends BeatState {
	var bg:MenuSprite;

	override function create():Void {
		super.create();

		bg = new MenuSprite(FlxColor.MAGENTA);
		bg.scrollFactor.set(0.1, 0.1);
		bg.scale.scale(1.2);
		bg.screenCenter();
		add(bg);
	}
}
#end