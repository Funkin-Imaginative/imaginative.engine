package states.menus;

class TitleScreen extends BeatState {
	static var played:Bool = false;
	var started:Bool = false;
	var skipped:Bool = false;
	var leaving:Bool = false;

	var logo:BaseSprite;
	var menuDancer:BeatSprite;
	var titleText:BaseSprite;
	var ngLogo:BaseSprite;

	override public function create():Void {
		super.create();
		new FlxTimer().start(played ? 0.0001 : 1, (timer:FlxTimer) -> {
			if (Conductor.menu == null) Conductor.menu = new Conductor();
			if (conductor.audio == null || !conductor.audio.playing)
				conductor.loadMusic('freakyMenu', 0, (audio:FlxSound) -> audio.fadeIn(4, 0, 0.7));

			logo = new BaseSprite(-150, -100, 'menus/title/logoBumpin');
			logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logo.playAnim('bump', true);
			logo.animation.finish();
			logo.antialiasing = true;
			add(logo);

			menuDancer = new BeatSprite(FlxG.width * 0.4, FlxG.height * 0.07, 'menus/title/gfDanceTitle');
			menuDancer.animation.addByIndices('idle', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
			menuDancer.animation.addByIndices('sway', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
			menuDancer.antialiasing = true;
			add(menuDancer);

			titleText = new BaseSprite(100, FlxG.height * 0.8, 'menus/title/titleEnter');
			titleText.animation.addByPrefix('idle', 'Press Enter to Begin', 24);
			titleText.animation.addByPrefix('press', 'ENTER PRESSED', 24);
			titleText.animation.play('idle', true);
			titleText.centerOffsets();
			titleText.centerOrigin();
			titleText.antialiasing = true;
			add(titleText);

			startIntro();
		});
	}

	function startIntro():Void {
		if (!played) {}

		for (l in [logo, menuDancer, titleText])
			if (l != null)
				l.visible = false;

		ngLogo = new BaseSprite('menus/title/newgrounds');
		ngLogo.scale.set(0.8, 0.8);
		ngLogo.updateHitbox();
		ngLogo.screenCenter(X);
		ngLogo.antialiasing = true;
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

	override public function update(elapsed:Float):Void {
		if (Controls.accept && !leaving && skipped) {
			titleText.animation.play('press', true);
			titleText.centerOffsets();
			titleText.centerOrigin();
			camera.flash(FlxColor.WHITE, 1);
			FunkinUtil.playMenuSFX(CONFIRM, 0.7);
			leaving = true;
			FlxG.switchState(new MainMenu());
		}

		if (Controls.accept && !skipped && played)
			skipIntro();

		super.update(elapsed);
	}

	var hasSwayed:Bool = false;

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);

		if (!started)
			return;

		if (skipped) {
			logo.playAnim('bump', true);
			menuDancer.playAnim((hasSwayed = !hasSwayed) ? 'sway' : 'idle', true);
		} else {
			if (curBeat >= 16)
				skipIntro();
		}
	}
}