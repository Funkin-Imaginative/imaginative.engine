package imaginative.objects.gameplay.hud;

import imaginative.objects.ui.Bar;

// TODO: Optimize this shit.
class KadeHUD extends HUDTemplate {
	override function get_type():HUDType
		return Kade;

	override public function getFieldYLevel(downscroll:Bool = false, field:ArrowField):Float {
		var yLevel:Float = (downscroll ? FlxG.height - 165 : 50) + (ArrowField.arrowSize / 2);
		return call(true, 'onFieldY', [downscroll, yLevel], yLevel);
	}

	override function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, getDefaultCamera().height * 0.9).makeGraphic(600, 20, FlxColor.BLACK);
		if (Settings.setupP1.downscroll)
			bg.y = 50;
		bg.screenCenter(X);
		elements.add(bg);

		return new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'visualHealth', minHealth, maxHealth);
	}

	override function initStatsText():FlxText {
		var text:FlxText = new FlxText(0, (healthBar.y - 4) + 50, getDefaultCamera().width);
		text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		// text.y = healthBar.y - 4;
		return text;
	}
	override function initStatsP2Text():FlxText {
		return new FlxText('', 0); // to prevent crashes
	}

	override function createElements():Void {
		// kade layer ordering lol
		healthBar = initHealthBar();
		statsText = initStatsText();
		elements.add(statsText);
		elements.add(healthBar);
		call(true, 'onCreateElements');
		updateStatsText();
	}

	// figure this out later, code by @Zyflx btw
	/* var nps:Int = 0;
	var maxNps:Int = 0;
	var noteHitArray:Array<Float> = [];
	override public function new() {
		super();
		ArrowField.player.onNoteHit.add(event -> {
			nps++;
			noteHitArray.push(event.note.time);
		});
	}

	override public function update(elapsed:Float) {
		for (time in noteHitArray) {
			if (time < ArrowField.player.conductor.time) {
				nps--;
				noteHitArray.remove(time);
				updateStatsText();
			}
		}
		if (maxNps < nps)
			maxNps = nps;
		super.update(elapsed);
	} */

	override public function updateStatsText():Void {
		var result:Array<String> = [];
		result.push('NPS: 0 (Max 0)');
		result.push('Score:${Scoring.statsP1.score}');
		result.push('Combo Breaks:${Scoring.statsP1.misses + Scoring.statsP1.breaks}');
		result.push('Accuracy:${truncateFloat(Scoring.statsP1.accuracy, 2)} %');
		result.push(generateLetterRank(Scoring.statsP1));
		statsText.text = result.join(' | ');
		call('onUpdateStats', [Settings.setupP1, Scoring.statsP1]);
	}

	/**
	 * stolen from kade lol
	 */
	function truncateFloat(number:Float, precision:Int):Float {
		var num:Float = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}
	/**
	 * will be optimized in the future ofc
	 *
	 * or not exist tbh lol
	 */
	function generateLetterRank(stats:PlayerStats):String {
		var ranking:String = 'N/A';
		if ((ArrowField.botplay && !ArrowField.enableP2) /* && !PlayState.loadRep */)
			ranking = 'BotPlay';

		if (stats.misses == 0 /* && stats.bads == 0 && stats.shits == 0 && stats.goods == 0 */) // Marvelous (SICK) Full Combo
			ranking = '(MFC)';
		else if (stats.misses == 0 /* && stats.bads == 0 && stats.shits == 0 && stats.goods >= 1 */) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = '(GFC)';
		else if (stats.misses == 0) // Regular FC
			ranking = '(FC)';
		else if (stats.misses < 10) // Single Digit Combo Breaks
			ranking = '(SDCB)';
		else
			ranking = '(Clear)';

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			stats.accuracy >= 99.9935, // AAAAA
			stats.accuracy >= 99.980, // AAAA:
			stats.accuracy >= 99.970, // AAAA.
			stats.accuracy >= 99.955, // AAAA
			stats.accuracy >= 99.90, // AAA:
			stats.accuracy >= 99.80, // AAA.
			stats.accuracy >= 99.70, // AAA
			stats.accuracy >= 99, // AA:
			stats.accuracy >= 96.50, // AA.
			stats.accuracy >= 93, // AA
			stats.accuracy >= 90, // A:
			stats.accuracy >= 85, // A.
			stats.accuracy >= 80, // A
			stats.accuracy >= 70, // B
			stats.accuracy >= 60, // C
			stats.accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length) {
			var b = wifeConditions[i];
			if (b) {
				switch (i) {
					case 0: ranking += ' AAAAA';
					case 1: ranking += ' AAAA:';
					case 2: ranking += ' AAAA.';
					case 3: ranking += ' AAAA';
					case 4: ranking += ' AAA:';
					case 5: ranking += ' AAA.';
					case 6: ranking += ' AAA';
					case 7: ranking += ' AA:';
					case 8: ranking += ' AA.';
					case 9: ranking += ' AA';
					case 10: ranking += ' A:';
					case 11: ranking += ' A.';
					case 12: ranking += ' A';
					case 13: ranking += ' B';
					case 14: ranking += ' C';
					case 15: ranking += ' D';
				}
				break;
			}
		}

		if (stats.accuracy == 0)
			ranking = 'N/A';
		else if ((ArrowField.botplay && !ArrowField.enableP2) /* && !PlayState.loadRep */)
			ranking = 'BotPlay';

		return ranking;
	}
}