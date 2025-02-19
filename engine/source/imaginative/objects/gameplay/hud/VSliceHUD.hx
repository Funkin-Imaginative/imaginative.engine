package imaginative.objects.gameplay.hud;

import imaginative.objects.gameplay.hud.HUDTemplate.HUDType;
import imaginative.objects.ui.Bar;

class VSliceHUD extends HUDTemplate {
	override function get_type():HUDType
		return VSlice;

	override public function getFieldYLevel(downscroll:Bool = false, ?field:ArrowField):Float {
		field ??= ArrowField.player;
		var height:Float = field?.strums?.height ?? 161;
		var yLevel:Float = (downscroll ? FlxG.camera.height - height - 24 : 24) + (height / 2);
		return call(true, 'onGetFieldY', [downscroll, yLevel], yLevel);
	}

	override function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, Settings.setupP1.downscroll ? FlxG.camera.height * 0.1 : FlxG.camera.height * 0.9).makeGraphic(600, 20, FlxColor.BLACK);
		bg.screenCenter(X);
		elements.add(bg);

		var bar:Bar = new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'health', 0, 2);
		return bar.setColors(FlxColor.RED, 0xFF66FF33, true);
	}
	override function initStatsText():FlxText {
		var text:FlxText = new FlxText(healthBar.x + healthBar.width - 190, healthBar.y + 30, 0, '');
		text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		return text;
	}

	override public function updateStatsText():Void {
		statsText.text = ArrowField.botplay ? 'Bot Play Enabled' : 'Score: ${Scoring.statsP1.score.formatMoney(false)}';
	}
}