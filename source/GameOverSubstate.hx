package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.display.Display.Package;
import ui.PreferencesMenu;

class GameOverSubstate extends MusicBeatSubstate {
	var corpse:Character;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var randomGameover:Int = 1;

	public function new(x:Float, y:Float) {
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage) {
			case 'school' | 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default: daBf = 'bf-dead';
		}

		var daSong = PlayState.chartData.song.toLowerCase();
		if (daSong == 'stress') daBf = 'bf-holding-gf-dead';

		super();

		Conductor.songPosition = 0;

		corpse = new Character(daBf, x, y, true);
		add(corpse);

		camFollow = new FlxObject(corpse.getCharCameraPos.x, corpse.getCharCameraPos.y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		corpse.playAnim('firstDeath');

		var randomCensor:Array<Int> = [];
		if (PreferencesMenu.getPref('censor-naughty')) randomCensor = [1, 3, 8, 13, 17, 21];
		randomGameover = FlxG.random.int(1, 25, randomCensor);
	}

	var playingDeathSound:Bool = false;
	var startedDeath:Bool = false;
	var preventDoublePress:Bool = false;
	override function update(elapsed:Float) {
		// makes the lerp non-dependant on the framerate
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.01);

		super.update(elapsed);

		if (controls.ACCEPT && !preventDoublePress) endBullshit();
		if (controls.ACCEPT || controls.BACK) preventDoublePress = true;
		if (controls.BACK && !preventDoublePress) {
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode) FlxG.switchState(new StoryMenuState());
			else FlxG.switchState(new FreeplayState());
		}

		#if debug
		if (FlxG.keys.justPressed.EIGHT) FlxG.switchState(new AnimationDebug(corpse.charName));
		#end

		if (corpse.animation.curAnim.name == 'firstDeath' && corpse.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		switch (PlayState.storyWeek) {
			case 7:
				if (corpse.animation.curAnim.name == 'firstDeath' && corpse.animation.curAnim.finished && !playingDeathSound) {
					playingDeathSound = true;

					startedDeath = true;
					coolStartDeath(0.2);

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + randomGameover), 1, false, null, true, function()
					{ if (!isEnding) FlxG.sound.music.fadeIn(4, 0.2, 1); });
				}
			default:
				if (corpse.animation.curAnim.name == 'firstDeath' && corpse.animation.curAnim.finished) {
					startedDeath = true;
					coolStartDeath();
				}
		}

		if (FlxG.sound.music.playing) Conductor.songPosition = FlxG.sound.music.time;
	}

	private function coolStartDeath(?vol:Float = 1):Void {
		if (!isEnding) FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), vol);
	}

	override function beatHit() {
		super.beatHit();
		if (curBeat % (corpse.danceNumBeats * corpse.bopSpeed) == 0 && corpse.animation.curAnim.name != 'firstDeath') corpse.playAnim('deathLoop');
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void {
		if (!isEnding) {
			isEnding = true;
			corpse.playAnim('deathConfirm', true);
			corpse.noInterup.bopping = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{ LoadingState.loadAndSwitchState(new PlayState()); });
			});
		}
	}
}
