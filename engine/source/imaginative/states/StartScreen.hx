package imaginative.states;

/**
 * Simple little start screen.
 */
class StartScreen extends BeatState {
	var leaving:Bool = false;
	var canSelect:Bool = false;

	var tweenAxes:FlxAxes = [X, Y, XY][FlxG.random.int(0, 2)];
	var swapAxes:FlxAxes = [X, Y, XY][FlxG.random.int(0, 2)];

	var simpleBg:FlxBackdrop;
	var welcomeText:FlxText;
	var warnText:FlxText;

	override public function create():Void {
		Conductor.init();
		super.create();
		if (!conductor.playing)
			conductor.loadMusic('lunchbox', (sound:FlxSound) -> conductor.fadeIn(4, 0.7));
		camera.fade(4, true, () -> canSelect = true);
		if (tweenAxes.x) camera.scroll.x -= camera.width * (swapAxes.x ? -1 : 1);
		if (tweenAxes.y) camera.scroll.y -= camera.height * (swapAxes.y ? -1 : 1);
		FlxTween.tween(camera, {'scroll.x': 0, 'scroll.y': 0}, 3, {ease: FlxEase.cubeOut, startDelay: 1});

		simpleBg = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 200, 200, true, 0x7B000000, 0x7BFFFFFF));
		simpleBg.velocity.set(
			(FlxG.random.bool() ? 40 : 30) * (FlxG.random.bool() ? -1 : 1),
			(FlxG.random.bool() ? 40 : 30) * (FlxG.random.bool() ? -1 : 1)
		);

		welcomeText = new FlxText(0, 250, FlxG.width, 'Welcome to\n[ROD]Imaginative Engine[ROD]!');
		welcomeText.setFormat(Paths.font('vcr').format(), 70, FlxColor.BLACK, CENTER, OUTLINE, FlxColor.WHITE);
		warnText = new FlxText(0, 450, FlxG.width, 'This engine is [YOU]still[YOU] [FUCK]work in progress[FUCK]!\nBe weary of any issues you may encounter.');
		warnText.setFormat(Paths.font('vcr').format(), 40, FlxColor.BLACK, CENTER, OUTLINE, FlxColor.WHITE);

		welcomeText.borderSize = 3;
		welcomeText.applyMarkup(welcomeText.text, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF00C8FF, 0xFF8000FF), '[ROD]'),
		]);
		warnText.borderSize = 3;
		warnText.applyMarkup(warnText.text, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.BLACK, true, false, FlxColor.RED, false), '[FUCK]'),
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.BLACK, false, true, FlxColor.WHITE, false), '[YOU]'),
		]);

		add(simpleBg);
		add(welcomeText);
		add(warnText);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// skips the leave transition
		if (leaving && (Controls.accept || FlxG.mouse.justPressed)) {
			@:privateAccess
				if (conductor.fadeTween != null)
					if (conductor.fadeTween.active)
						conductor.reset();
			BeatState.switchState(new TitleScreen());
		}

		if (canSelect && (Controls.accept || FlxG.mouse.justPressed)) {
			leaving = true;
			canSelect = false;
			FunkinUtil.playMenuSFX(ConfirmSFX);
			conductor.fadeOut(3, (_:FlxTween) -> conductor.reset());
			camera.fade(3.5, () -> BeatState.switchState(new TitleScreen()), true);
			FlxTween.completeTweensOf(camera); // skips the entry transition
			FlxTween.tween(camera, {
				'scroll.x': tweenAxes.x ? ((camera.scroll.x + camera.width) * (swapAxes.x ? -1 : 1)) : 0,
				'scroll.y': tweenAxes.y ? ((camera.scroll.y + camera.height) * (swapAxes.y ? -1 : 1)) : 0
			}, 5, {ease: FlxEase.smoothStepIn});
		}
	}
}