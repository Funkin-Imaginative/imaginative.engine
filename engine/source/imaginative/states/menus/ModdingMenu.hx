#if MOD_SUPPORT
package imaginative.states.menus;

class ModdingMenu extends BeatState {
	var bg:FlxSprite;

	override function create():Void {
		super.create();

		bg = new FlxSprite().getBGSprite(FlxColor.MAGENTA);
		bgColor = bg.color;
		bg.scrollFactor.set(0.1, 0.1);
		bg.scale.scale(1.2);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
	}
}
#end