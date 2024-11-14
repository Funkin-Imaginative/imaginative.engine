package states;

/**
 * Simple little start screen.
 */
class StartScreen extends BeatState {
	var canSelect:Bool = false;
	var tweenAxes:FlxAxes = [X, Y, XY][FlxG.random.int(0, 2)];
	var swapAxes:FlxAxes = [X, Y, XY][FlxG.random.int(0, 2)];

	var simpleBg:FlxBackdrop;
	var welcomeText:FlxText;
	var warnText:FlxText;

	override function create():Void {
		super.create();
		if (!conductor.audio.playing)
			conductor.loadMusic('lunchbox', 0, (sound:FlxSound) -> sound.fadeIn(4, 0.7));
		camera.fade(4, true, () -> canSelect = true);
		if (tweenAxes.x) camera.scroll.x -= camera.width * (swapAxes.x ? -1 : 1);
		if (tweenAxes.y) camera.scroll.y -= camera.height * (swapAxes.y ? -1 : 1);
		FlxTween.tween(camera, {'scroll.x': 0, 'scroll.y': 0}, 3, {ease: FlxEase.cubeOut, startDelay: 1});

		simpleBg = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 200, 200, true, 0x7B939300, 0x7B930000));
		simpleBg.velocity.set(
			(FlxG.random.bool() ? 40 : 30) * (FlxG.random.bool() ? -1 : 1),
			(FlxG.random.bool() ? 40 : 30) * (FlxG.random.bool() ? -1 : 1)
		);

		welcomeText = new FlxText(0, 250, FlxG.width, 'Welcome to\n[ROD]Imaginative Engine[ROD]!')
		.setFormat(Paths.font('vcr').format(), 70, FlxColor.BLACK, CENTER, OUTLINE, FlxColor.WHITE);
		warnText = new FlxText(0, 450, FlxG.width, 'This engine is [YOU]still[YOU] [FUCK]work in progress[FUCK]!\nBe weary of any issues you may encounter.')
		.setFormat(Paths.font('vcr').format(), 40, FlxColor.BLACK, CENTER, OUTLINE, FlxColor.WHITE);

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

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (canSelect && (Controls.accept || FlxG.mouse.justPressed)) {
			canSelect = false;
			FunkinUtil.playMenuSFX(ConfirmSFX);
			conductor.audio.fadeOut(3, 0, (_:FlxTween) -> conductor.reset());
			camera.fade(3.5, () -> BeatState.switchState(new TitleScreen()), true); // jic
			FlxTween.completeTweensOf(camera);
			FlxTween.tween(camera, {
				'scroll.x': tweenAxes.x ? ((camera.scroll.x + camera.width) * (swapAxes.x ? -1 : 1)) : 0,
				'scroll.y': tweenAxes.y ? ((camera.scroll.y + camera.height) * (swapAxes.y ? -1 : 1)) : 0
			}, 5, {ease: FlxEase.smoothStepIn});
		}
	}
}