package imaginative.states;

import flixel.text.FlxText;
import moonchart.Moonchart;

class LaunchScreen extends imaginative.backend.states.GameState {
	@:unreflective static var game_boot:Bool = false;
	static var splash_screen:Bool = false;

	override function create():Void {
		if (!game_boot) @:privateAccess {
			game_boot = true;

			Moonchart.DEFAULT_DIFF = 'normal';
			Moonchart.init();

			Assets.init();

			FlxG.fixedTimestep = false;
			flixel.FlxSprite.defaultAntialiasing = true; // this ain't a pixel game... yeah ik week 6 exists!
		}
		super.create();
		#if Updateable
		if (blah blah blah) {
			Game.switchState(() -> new CanUpdateScreen());
			return;
		}
		#end
		if (!splash_screen) {
			splash_screen = true;

			var logo = new BaseSprite('watermarks/static-logo');
			logo.scale.scale(0.2);
			logo.alpha = 0;
			logo.screenCenter();
			logo.y -= 30;
			add(logo);

			var text = new FlxText('Imaginative\nEngine');
			text.setFormat(Paths.font('vcr.tff').format(), 50, 0xffffc800, CENTER, OUTLINE, FlxColor.WHITE).alpha = 0;
			text.borderSize = 2;
			text.screenCenter();
			text.y += 100;
			add(text);

			FlxTween.tween(logo, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
			FlxTween.tween(text, {alpha: 1}, 1, {ease: FlxEase.cubeOut});

			FlxG.sound.play(Assets.sound('gameovers/retry', true), 0.5, () -> {
				// Game.switchState();
				trace(':3');
			});
		} // else
	}
}