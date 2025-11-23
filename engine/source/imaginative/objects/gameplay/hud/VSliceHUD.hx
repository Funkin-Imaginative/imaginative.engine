package imaginative.objects.gameplay.hud;

import imaginative.objects.ui.Bar;

class VSliceHUD extends HUDTemplate {
	override function get_type():HUDType
		return VSlice;

	override public function getFieldYLevel(downscroll:Bool = false, field:ArrowField):Float {
		var yLevel:Float = (downscroll ? getDefaultCamera().height - ArrowField.arrowSize - 24 : 24) + (ArrowField.arrowSize / 2);
		return call(true, 'onGetFieldY', [downscroll, yLevel], yLevel);
	}

	override function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, getDefaultCamera().height * (Settings.setupP1.downscroll ? 0.1 : 0.9)).makeGraphic(600, 20, FlxColor.BLACK);
		bg.screenCenter(X);
		elements.add(bg);

		var bar:Bar = new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'visualHealth', minHealth, maxHealth);
		return bar.setColors(FlxColor.RED, 0xFF66FF33, true);
	}

	override function initStatsText():FlxText {
		var text:FlxText = new FlxText((healthBar.x - 4) + (healthBar.width + 8) - 190, (healthBar.y - 4) + 30);
		text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		return text;
	}
	override function initStatsP2Text():FlxText {
		var text:FlxText = new FlxText((healthBar.x - 4) - (healthBar.width + 8) + 190, (healthBar.y - 4) + 30);
		text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		text.visible = ArrowField.enableP2;
		return text;
	}

	override public function updateStatsText():Void {
		statsText.text = ArrowField.botplay && !ArrowField.enableP2 ? 'Bot Play Enabled' : 'Score: ${Scoring.statsP1.score.formatMoney(false)}';
		call('onUpdateStats', [Settings.setupP1, Scoring.statsP1]);
	}
	override public function updateStatsP2Text():Void {
		statsP2Text.text = 'Score: ${Scoring.statsP2.score.formatMoney(false)}';
		call('onUpdateStatsP2', [Settings.setupP2, Scoring.statsP2]);
	}
}