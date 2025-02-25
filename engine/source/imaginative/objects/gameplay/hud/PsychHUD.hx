package imaginative.objects.gameplay.hud;

import imaginative.objects.gameplay.hud.HUDTemplate.HUDType;
import imaginative.objects.ui.Bar;

class PsychHUD extends HUDTemplate {
	override function get_type():HUDType
		return Psych;

	override public function getFieldYLevel(downscroll:Bool = false, ?field:ArrowField):Float {
		field ??= ArrowField.player;
		var yLevel:Float = (downscroll ? (FlxG.camera.height - 150) : 50) + (ArrowField.arrowSize / 2);
		return call(true, 'onGetFieldY', [downscroll, yLevel], yLevel);
	}

	override function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, FlxG.camera.height * (!Settings.setupP1.downscroll ? 0.89 : 0.11)).makeGraphic(600, 20, FlxColor.BLACK);
		bg.screenCenter(X);
		elements.add(bg);

		return new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'health', 0, 2);
	}
	override function initStatsText():FlxText {
		var text:FlxText = new FlxText(0, healthBar.y + 40 - 8, FlxG.camera.width, '');
		text.setFormat(Paths.font('vcr').format(), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		text.borderSize = 1.25;
		return text;
	}

	override public function updateStatsText():Void {
		statsText.text = 'Score: ${Scoring.statsP1.score} | Misses: ${Scoring.statsP1.misses} | Rating: (${Scoring.statsP1.accuracy}%) - Clear';
	}
}