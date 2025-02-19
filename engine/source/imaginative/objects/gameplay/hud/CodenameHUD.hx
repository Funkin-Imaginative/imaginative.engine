package imaginative.objects.gameplay.hud;

import imaginative.objects.gameplay.hud.HUDTemplate.HUDType;
import imaginative.objects.ui.Bar;

class CodenameHUD extends HUDTemplate {
	override function get_type():HUDType
		return Codename;

	public var missesText:FlxText;
	public var accuracyText:FlxText;

	override public function getFieldYLevel(downscroll:Bool = false, ?field:ArrowField):Float {
		field ??= ArrowField.player;
		var height:Float = field?.strums?.height ?? 161;
		var yLevel:Float = 50;
		if (downscroll) yLevel = FlxG.camera.height - yLevel - height;
		yLevel += (height / 2);
		return call(true, 'onGetFieldY', [downscroll, yLevel], yLevel);
	}

	override function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, FlxG.camera.height * 0.9).makeGraphic(600, 20, FlxColor.BLACK);
		bg.screenCenter(X);
		elements.add(bg);

		var bar:Bar = new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'health', 0, 2);
		return bar.setColors(FlxColor.RED, 0xFF66FF33, true);
	}
	override function initStatsText():FlxText {
		var texts:Array<FlxText> = [];
		for (alignment in [RIGHT, CENTER, LEFT]) {
			var text:FlxText = new FlxText(healthBar.x + 50, healthBar.y + 30, Std.int(healthBar.width - 100), '');
			text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, alignment, OUTLINE, FlxColor.BLACK);
			text.borderSize = 1;
			texts.push(text);
		}
		elements.add(missesText = texts[1]);
		elements.add(accuracyText = texts[2]);
		accuracyText.text = 'Accuracy:-% - [N/A]';
		return texts[0];
	}

	public static function cneYLevel<Sprite:FlxObject>(spr:Sprite):Sprite {
		spr.y = FlxG.camera.height - spr.y - spr.height;
		return spr;
	}
	override function createElements():Void {
		super.createElements();
		if (Settings.setupP1.downscroll)
			for (object in elements)
				cneYLevel(cast object);
	}

	override public function updateStatsText():Void {
		statsText.text = 'Score:${Scoring.statsP1.score}';
		missesText.text = 'Misses:${Scoring.statsP1.misses}';
		accuracyText.text = 'Accuracy:${Scoring.statsP1.accuracy < 0 ? '-' : Std.string(Math.fround(Scoring.statsP1.accuracy * 100 * 100) / 100)}% - [N/A]';
	}
}