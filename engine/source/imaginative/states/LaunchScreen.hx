package imaginative.states;

import moonchart.Moonchart;

class LaunchScreen extends GameState {
	@:unreflective static var game_boot:Bool = false;
	static var splash_screen:Bool = false;

	override function create():Void {
		if (!game_boot) @:privateAccess {
			game_boot = true;

			Moonchart.DEFAULT_DIFF = 'normal';
			Moonchart.init();

			Conductor.init();
			Assets.init();

			FlxG.fixedTimestep = false;
			flixel.FlxSprite.defaultAntialiasing = true; // this ain't a pixel game... yeah ik week 6 exists!
		}
		super.create();
		#if Updateable
		if (Game.updateAvailable) {
			openSubState(new UpdateScreen());
			return;
		}
		#end
		if (!splash_screen) {
			splash_screen = true;

			var logo = new BaseSprite('watermarks/static-logo');
			logo.screenCenter();
			logo.alpha = 0;
			logo.y -= 30;
			add(logo);

			var text = new BaseSprite('watermarks/engine-text');
			text.screenCenter();
			text.alpha = 0;
			text.y += 200 - 30;
			add(text);

			FlxTween.tween(logo, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
			FlxTween.tween(text, {alpha: 1}, 1, {ease: FlxEase.cubeOut});

			// TODO: once settings state is coded, do first time game launch stuff
			FlxG.sound.play(Assets.sound('gameovers/retry', true, true), 0.5, () -> {
				Game.switchState(() -> new TitleScreen());
			});
		} // else
	}
}

#if Updateable
class UpdateScreen extends GameState {
	//
}
#end