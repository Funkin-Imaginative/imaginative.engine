package states.menus;

class TitleScreen extends BeatState {
	static var played:Bool = false;
	var started:Bool = false;
	var skipped:Bool = false;
	var leaving:Bool = false;

	override public function create():Void {
		statePathShortcut = 'menus/title/';
		super.create();
		new FlxTimer().start(played ? 0.0001 : 1, (timer:FlxTimer) -> {
			if (Conductor.menu == null) Conductor.menu = new Conductor();
			if (conductor.audio == null || !conductor.audio.playing) {
				conductor.setAudio('freakyMenu', 0);
				conductor.audio.fadeIn(4, 0, 0.7);
				conductor.audio.persist = true;
			}

			logo = new FlxSprite(-150, -100);
			logo.frames = Paths.frames('${statePathShortcut}logoBumpin');
			logo.animation.addByPrefix('bump', 'logo bumpin', 24);
			logo.animation.play('bump', true);
			logo.animation.finish();
			logo.antialiasing = true;
			add(logo);

			menuDancer = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			menuDancer.frames = Paths.frames('${statePathShortcut}gfDanceTitle');
			menuDancer.animation.addByIndices('idle', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
			menuDancer.animation.addByIndices('sway', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
			menuDancer.antialiasing = true;
			add(menuDancer);

			titleText = new FlxSprite(100, FlxG.height * 0.8);
			titleText.frames = Paths.frames('${statePathShortcut}titleEnter');
			titleText.animation.addByPrefix('idle', 'Press Enter to Begin', 24);
			titleText.animation.addByPrefix('press', 'ENTER PRESSED', 24);
			titleText.animation.play('idle', true);
			titleText.antialiasing = true;
			add(titleText);

			startIntro();
		});
	}

	var logo:FlxSprite;
	var menuDancer:FlxSprite;
	var titleText:FlxSprite;
	var ngLogo:FlxSprite;

	function startIntro():Void {
		if (!played) {}

		for (l in [logo, menuDancer, titleText])
			if (l != null)
				l.visible = false;

		ngLogo = new FlxSprite().loadGraphic(getAsset('newgrounds'));
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
			FlxG.camera.flash(FlxColor.WHITE, 4);
			skipped = true;
		}
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.justPressed.ENTER && !leaving && skipped) {
			titleText.animation.play('press', true);
			FlxG.camera.flash(FlxColor.WHITE, 1);
			CoolUtil.playMenuSFX(CONFIRM, 0.7);
			leaving = true;
			FlxG.switchState(new MainMenu());
		}

		if (FlxG.keys.justPressed.ENTER && !skipped && played)
			skipIntro();

		super.update(elapsed);
	}

	var hasSwayed:Bool = false;

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);

		if (!started)
			return;

		if (skipped) {
			logo.animation.play('bump', true);
			menuDancer.animation.play((hasSwayed = !hasSwayed) ? 'sway' : 'idle', true);
		} else {
			if (curBeat == 16)
				skipIntro();
		}
	}
}