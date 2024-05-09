package fnf.objects.background;

import flixel.FlxSprite;

class BackgroundGirls extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('weeb/bgFreaks');

		animation.addByIndices('idle', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('sway', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);

		animation.play('idle');
		animation.finish();
	}

	var danceDir:Bool = false;

	public function getScared():Void
	{
		animation.addByIndices('idle', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('sway', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		dance();
		animation.finish();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('sway', true);
		else
			animation.play('idle', true);
	}
}
