package imaginative.objects.gameplay.hud;

import imaginative.objects.ui.Bar;

class PsychHUD extends HUDTemplate {
	override function get_type():HUDType
		return Psych;

	override public function getFieldYLevel(downscroll:Bool = false, field:ArrowField):Float {
		var yLevel:Float = (downscroll ? (getDefaultCamera().height - 150) : 50) + (ArrowField.arrowSize / 2);
		return call(true, 'onGetFieldY', [downscroll, yLevel], yLevel);
	}

	override function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, getDefaultCamera().height * (!Settings.setupP1.downscroll ? 0.89 : 0.11)).makeGraphic(600, 20, FlxColor.BLACK);
		bg.screenCenter(X);
		elements.add(bg);

		return new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'visualHealth', minHealth, maxHealth);
	}
	override function initStatsText():FlxText {
		var text:FlxText = new FlxText(0, (healthBar.y - 4) + 40 - 8, getDefaultCamera().width);
		text.setFormat(Paths.font('vcr').format(), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		text.borderSize = 1.25;
		return text;
	}
	override function initStatsP2Text():FlxText {
		var text:FlxText = new FlxText(0, Settings.setupP1.downscroll ? 650 : 0, getDefaultCamera().width);
		text.setFormat(Paths.font('vcr').format(), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		text.borderSize = 1.25;
		text.visible = ArrowField.enableP2;
		return text;
	}

	override public function updateStatsText():Void {
		statsText.text = 'Score: ${Scoring.statsP1.score} | Misses: ${Scoring.statsP1.misses} | Rating: (${floorDecimal(Scoring.statsP1.accuracy * 100, 2)}%) - Clear';
		call('onUpdateStats', [Settings.setupP1, Scoring.statsP1]);
	}
	override public function updateStatsP2Text():Void {
		statsP2Text.text = 'Score: ${Scoring.statsP2.score} | Misses: ${Scoring.statsP2.misses} | Rating: (${floorDecimal(Scoring.statsP2.accuracy * 100, 2)}%) - Clear';
		call('onUpdateStatsP2', [Settings.setupP2, Scoring.statsP2]);
	}

	function floorDecimal(value:Float, decimals:Int):Float {
		if (decimals < 1)
			return Math.floor(value);
		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
}