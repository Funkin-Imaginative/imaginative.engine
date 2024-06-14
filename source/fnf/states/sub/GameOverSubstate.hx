package fnf.states.sub;

import fnf.objects.Character;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Character;
	var camPoint:BareCameraPoint;

	var stageSuffix:String = "";
	var randomGameover:Int = 1;

	public function new(x:Float, y:Float) {
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage) {
			case 'school' | 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		var daSong = PlayState.SONG.song.toLowerCase();

		switch (daSong) {
			case 'stress':
				daBf = 'bf-holding-gf-dead';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Character(x, y, daBf);
		bf.flipX = true;
		add(bf);

		camPoint = new BareCameraPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);
		add(camPoint);

		FlxG.sound.play(Paths.sound('gameover/fnf_loss_sfx$stageSuffix'));
		Conductor.bpm = 100;

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var randomCensor:Array<Int> = [];

		if (!SaveManager.getOption('naughtiness')) randomCensor = [1, 3, 8, 13, 17, 21];
		randomGameover = FlxG.random.int(1, 25, randomCensor);
	}

	var playingDeathSound:Bool = false;

	override function update(elapsed:Float)
	{
		// makes the lerp non-dependant on the framerate
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.01);

		super.update(elapsed);

		if (controls.ACCEPT) {
			endBullshit();
		}

		if (controls.BACK) {
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode) FlxG.switchState(new fnf.states.menus.StoryMenuState());
			else FlxG.switchState(new fnf.states.menus.FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camPoint.realPos, LOCKON, 0.01);

		var startedDeath:Bool = false;
		switch (PlayState.storyWeek) {
			case 7:
				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !playingDeathSound) {
					playingDeathSound = true;

					startedDeath = true;
					coolStartDeath(0.2);

					FlxG.sound.play(Paths.sound('gameover/jeff/jeffGameover-$randomGameover'), 1, false, null, true, () -> if (!isEnding) FlxG.sound.music.fadeIn(4, 0.2, 1));
				}
			default:
				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished) {
					startedDeath = true;
					coolStartDeath();
				}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	private function coolStartDeath(?vol:Float = 1):Void
	{
		if (!isEnding)
			FlxG.sound.playMusic(Paths.music('gameover/gameOver$stageSuffix'), vol);
	}

	override function beatHit(curBeat:Int)
	{
		super.beatHit(curBeat);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameover/gameOver$stageSuffix'));
			new FlxTimer().start(0.7, (tmr:FlxTimer) -> FlxG.camera.fade(FlxColor.BLACK, 2, false, () -> LoadingState.loadAndSwitchState(new PlayState())));
		}
	}
}
