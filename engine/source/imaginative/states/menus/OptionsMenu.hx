package imaginative.states.menus;

class OptionsMenu extends BeatState {
	// Menu related vars.
	var canSelect:Bool = true;
	static var prevSelected:Int = 0;
	static var curSelected:Int = 0;
	var visualSelected:Int = curSelected;
	inline function selectionCooldown(duration:Float = 0.1):FlxTimer {
		canSelect = false;
		return new FlxTimer().start(duration, (_:FlxTimer) -> canSelect = true);
	}

	// Objects in the state.
	var bg:MenuSprite;

	// Camera management.
	var camPoint:FlxObject;

	override public function create():Void {
		super.create();
		conductor.loadMusic('breakfast', (_:FlxSound) -> conductor.fadeIn(0.6, 0.8));

		// Camera position.
		camPoint = new FlxObject(0, 0, 1, 1);
		mainCamera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		// Menu elements.
		bg = new MenuSprite(FlxColor.BLUE);
		bgColor = bg.blankBg.color;
		bg.scrollFactor.set();
		bg.updateScale(1.2);
		bg.screenCenter();
		add(bg);

		// bg.y = FlxMath.lerp(0, FlxG.height - bg.height, FlxMath.remapToRange(visualSelected, 0, menuItems.length - 1, 0, 1));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (canSelect) {
			/* if (Controls.uiUp || FlxG.keys.justPressed.PAGEUP) {
				changeSelection(-1);
				visualSelected = curSelected;
			}
			if (Controls.uiDown || FlxG.keys.justPressed.PAGEDOWN) {
				changeSelection(1);
				visualSelected = curSelected;
			}

			if (FlxG.mouse.wheel != 0) {
				changeSelection(-1 * FlxG.mouse.wheel);
				visualSelected = curSelected;
			}
			if (PlatformUtil.mouseJustMoved())
				for (i => item in menuItems)
					if (FlxG.mouse.overlaps(item))
						changeSelection(i, true);

			if (FlxG.keys.justPressed.HOME) {
				changeSelection(0, true);
				visualSelected = curSelected;
			}
			if (FlxG.keys.justPressed.END) {
				changeSelection(menuItems.length - 1, true);
				visualSelected = curSelected;
			} */

			if (Controls.global.back) {
				FunkinUtil.playMenuSFX(CancelSFX);
				conductor.fadeOut(0.4, (_:FlxTween) -> {
					BeatState.switchState(() -> new MainMenu());
					conductor.stop();
				});
			}
			/* if (Controls.accept || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuItems.members[curSelected]))) {
				if (visualSelected != curSelected) {
					visualSelected = curSelected;
					FunkinUtil.playMenuSFX(ScrollSFX, 0.7);
				} else selectCurrent();
			} */
		}

		// camPoint.y = FunkinUtil.lerp(highestY, lowestY, FlxMath.remapToRange(visualSelected, 0, menuItems.length - 1, 0, 1));
		// bg.y = FunkinUtil.lerp(bg.y, FlxMath.lerp(0, FlxG.height - bg.height, FlxMath.remapToRange(visualSelected, 0, menuItems.length - 1, 0, 1)), 0.16);
	}

	function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		prevSelected = curSelected;
		// curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, menuItems.length - 1);
		if (prevSelected != curSelected)
			FunkinUtil.playMenuSFX(ScrollSFX, 0.7);
	}

	function selectCurrent():Void {
		//
	}
}