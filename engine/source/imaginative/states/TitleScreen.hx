package imaginative.states;

class TitleScreen extends BeatState {
	static var played:Bool = false;
	var started:Bool = false;
	var skipped:Bool = false;
	var leaving:Bool = false;

	var logo:BeatSprite;
	var menuDancer:BeatSprite;
	var titleText:BaseSprite;
	var ngLogo:BaseSprite;

	override public function create():Void {
		super.create();
		new FlxTimer().start(played ? 0.0001 : 1, (_:FlxTimer) -> {
			if (!conductor.playing)
				conductor.loadMusic('freakyMenu', (sound:FlxSound) -> conductor.fadeIn(4, 0.7));

			logo = new BeatSprite(-150, -100, 'menus/title/logo');
			add(logo);

			menuDancer = new BeatSprite(FlxG.width * 0.4, FlxG.height * 0.07, 'menus/title/menuDancer');
			add(menuDancer);

			titleText = new BaseSprite(100, FlxG.height * 0.8, 'menus/title/titleEnter');
			titleText.animation.addByPrefix('idle', 'Press Enter to Begin', 24);
			titleText.animation.addByPrefix('press', 'ENTER PRESSED', 24);
			titleText.playAnim('idle');
			titleText.centerOffsets();
			titleText.centerOrigin();
			add(titleText);

			startIntro();
		});
	}

	override public function update(elapsed:Float):Void {
		if (Controls.accept || FlxG.mouse.justPressed) {
			if (!leaving && skipped) {
				titleText.playAnim('press');
				titleText.centerOffsets();
				titleText.centerOrigin();
				camera.flash(FlxColor.WHITE, 1);
				FunkinUtil.playMenuSFX(ConfirmSFX, 0.7);
				leaving = true;
				BeatState.switchState(new imaginative.states.menus.MainMenu());
			}
			if (!skipped && played)
				skipIntro();
		}

		super.update(elapsed);
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);

		if (!started)
			return;

		if (!skipped) {
			if (curBeat >= 16)
				skipIntro();
		}
	}

	function startIntro():Void {
		if (!played) {}

		for (l in [logo, menuDancer, titleText])
			if (l != null)
				l.visible = false;

		ngLogo = new BaseSprite('menus/title/newgrounds');
		ngLogo.scale.scale(0.8);
		ngLogo.updateHitbox();
		ngLogo.screenCenter(X);
		ngLogo.visible = false;
		add(ngLogo);

		if (played)
			skipIntro();
		else
			played = true;
		started = true;
	}

	function skipIntro():Void {
		if (!skipped) {
			// remove(ngLogo);
			for (l in [logo, menuDancer, titleText])
				if (l != null)
					l.visible = true;
			camera.flash(FlxColor.WHITE, 4);
			skipped = true;
		}
	}
}