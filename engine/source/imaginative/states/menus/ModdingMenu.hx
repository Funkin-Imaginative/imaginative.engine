#if MOD_SUPPORT
package imaginative.states.menus;

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