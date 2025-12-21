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
		super.create();
		if (!conductor.playing)
			conductor.loadMusic('lunchbox', (sound:FlxSound) -> conductor.fadeIn(4, 0.7));
		mainCamera.fade(4, true, () -> canSelect = true);
		if (tweenAxes.x) mainCamera.scroll.x -= mainCamera.width * (swapAxes.x ? -1 : 1);
		if (tweenAxes.y) mainCamera.scroll.y -= mainCamera.height * (swapAxes.y ? -1 : 1);
		FlxTween.tween(mainCamera.scroll, {x: 0, y: 0}, 3, {ease: FlxEase.cubeOut, startDelay: 1});

		simpleBg = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 200, 200, true, 0x7B000000, 0x7BFFFFFF));
		simpleBg.velocity.set(
			(FlxG.random.bool() ? 40 : 30) * FlxG.random.sign(),
			(FlxG.random.bool() ? 40 : 30) * FlxG.random.sign()
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
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.BLACK, FlxColor.RED), '[FUCK]'),
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.BLACK, FlxColor.WHITE), '[YOU]'),
		]);

		add(simpleBg);
		add(welcomeText);
		add(warnText);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// skips the leave transition
		if (leaving && (Controls.global.accept || FlxG.mouse.justPressed)) {
			@:privateAccess
				if (conductor.fadeTween != null)
					if (conductor.fadeTween.active)
						conductor.reset();
			BeatState.switchState(() -> new TitleScreen());
		}

		if (canSelect && (Controls.global.accept || FlxG.mouse.justPressed)) {
			leaving = true;
			canSelect = false;
			FunkinUtil.playMenuSFX(ConfirmSFX, 0.7);
			conductor.fadeOut(3, (_:FlxTween) -> conductor.reset());
			mainCamera.fade(3.5, () -> BeatState.switchState(() -> new TitleScreen()), true);
			FlxTween.completeTweensOf(mainCamera.scroll); // skips the entry transition
			FlxTween.tween(mainCamera.scroll, {
				x: tweenAxes.x ? ((mainCamera.scroll.x + mainCamera.width) * (swapAxes.x ? -1 : 1)) : 0,
				y: tweenAxes.y ? ((mainCamera.scroll.y + mainCamera.height) * (swapAxes.y ? -1 : 1)) : 0
			}, 5, {ease: FlxEase.smoothStepIn});
		}

		// just gonna leave this here for easy vslice conversion
		if (FlxG.keys.justPressed.TAB) {
			if (Paths.fileExists('root:chart/chart.json') && Paths.fileExists('root:chart/metadata.json')) {
				var chartOld = new moonchart.formats.fnf.FNFVSlice().fromFile('chart/chart.json', 'chart/metadata.json', 'normal');
				var chartNew = new moonchart.formats.fnf.FNFImaginative().fromFormat(chartOld);
				try {
					chartNew.save('chart/output/chart', 'chart/output/metadata');
					_log('[Moonchart] Successfully converted.');
				} catch(error:haxe.Exception)
					_log('[Moonchart] An error occurred! (error:$error)');
			} else _log('[Moonchart] Chart doesn\'t exist.');
		}
	}
}