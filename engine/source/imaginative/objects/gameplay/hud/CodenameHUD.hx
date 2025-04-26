package imaginative.objects.gameplay.hud;

import imaginative.objects.ui.Bar;

class CodenameHUD extends HUDTemplate {
	override function get_type():HUDType
		return Codename;

	/**
	 * The text that shows you the amount of misses.
	 */
	public var missesText:FlxText;
	/**
	 * The text that shows you the accuracy percent.
	 */
	public var accuracyText:FlxText;

	override function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, FlxG.camera.height * 0.9).makeGraphic(600, 20, FlxColor.BLACK);
		bg.screenCenter(X);
		elements.add(bg);

		var bar:Bar = new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'visualHealth', minHealth, maxHealth);
		return bar.setColors(FlxColor.RED, 0xFF66FF33, true);
	}

	override function initStatsText():FlxText {
		var texts:Array<FlxText> = [];
		for (alignment in [RIGHT, CENTER, LEFT]) {
			var text:FlxText = new FlxText((healthBar.x - 4) + 50, (healthBar.y - 4) + 30, Std.int((healthBar.width + 8) - 100));
			text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, alignment, OUTLINE, FlxColor.BLACK);
			text.borderSize = 1;
			texts.push(text);
		}
		elements.add(missesText = texts[1]);
		elements.add(accuracyText = texts[2]);
		accuracyText.text = 'Accuracy:-% - [N/A]';
		return texts[0];
	}
	override function initStatsP2Text():FlxText {
		return new FlxText('', 0); // to prevent crashes
	}

	/**
	 * Applies CNE's y level system thing to a sprite.
	 * @param spr The sprite to effect.
	 * @return `FlxSprite`
	 */
	public static function cneYLevel<Sprite:FlxObject>(spr:Sprite):Sprite {
		spr.y = FlxG.camera.height - spr.y - spr.height;
		return spr;
	}
	override function createElements():Void {
		super.createElements();
		if (Settings.setupP1.downscroll) {
			// var ignoreList:Array<FlxBasic> = cast call('setHudYIgnoreList', [], []) ?? [];
			for (object in elements/* .members.copy().filter(_ -> !ignoreList.contains(_)) */)
				cneYLevel(cast object);
		}
	}

	// cne doesn't give p2 their own texts, it just kinda stacks onto p1's... so I'm doing it like this i guess
	// i could just put them on the other end of the health bar but im feelin lazy rn lol... and tired its- oh, 9:50... (pm)
	override public function updateStatsText():Void {
		statsText.text = 'Score:${(ArrowField.enemyPlay ? 0 : Scoring.statsP1.score) + (ArrowField.enemyPlay ? Scoring.statsP2.score : 0)}';
		missesText.text = 'Misses:${(ArrowField.enemyPlay ? 0 : Scoring.statsP1.misses) + (ArrowField.enemyPlay ? Scoring.statsP2.misses : 0)}';
		// this is just visual, don't worry
		var accuracy:Float = ArrowField.enableP2 ? FlxMath.remapToRange(Scoring.statsP1.accuracy + Scoring.statsP2.accuracy, 0, 100, 0, 200) : (ArrowField.enemyPlay ? Scoring.statsP2.accuracy : Scoring.statsP1.accuracy);
		accuracyText.text = 'Accuracy:${accuracy < 0 ? '-' : Std.string(Math.fround(accuracy * 100 * 100) / 100)}% - [N/A]';
		call('onUpdateStats', [Settings.setupP1, Scoring.statsP1]);
	}
	override public function updateStatsP2Text():Void {
		updateStatsText();
		call('onUpdateStatsP2', [Settings.setupP2, Scoring.statsP2]);
	}
}