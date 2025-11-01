package imaginative.states;

class GameoverState extends BeatSubState {
	var game(get, never):PlayState;
	inline function get_game():PlayState
		return PlayState.instance;

	var character:Character;
	var camDead:BeatCamera;
	var camPoint:FlxObject;

	var musicSuffix:String = '';
	var deathSuffix:String = '';
	var retrySuffix:String = '';

	var deathSound:FlxSound;
	var retrySound:FlxSound;

	// TODO: Make this function it's own thing.
	inline function temp(suffix:String):String return suffix.isNullOrEmpty() ? '' : '-$suffix';
	override public function new(targetChar:Character) {
		super(true, true);
		targetChar.visible = false;
		character = new Character(targetChar.x, targetChar.y, '${targetChar.theirName}-dead', targetChar.flipX);
		// bgColor = FlxColor.BLACK;
		bgColor = 0xE9000000;

		// cache
		Assets.music('gameover/gameOver${temp(musicSuffix)}');
		deathSound = FlxG.sound.load(Assets.sound('gameover/death${temp(deathSuffix)}'));
		retrySound = FlxG.sound.load(Assets.sound('gameover/retry${temp(retrySuffix)}'));
	}

	override public function create():Void {
		super.create();
		// parent.persistentDraw = false;
		add(character);

		conductor.loadMusic('gameover/gameOver${temp(musicSuffix)}');
		if (game == null) {
			FlxG.cameras.add(camDead = new BeatCamera('Dead Camera').beatSetup(conductor), false);
			camDead.follow(camPoint = new FlxObject(0, 0, 1, 1), LOCKON, 0.05); add(camPoint);
		} else {
			game.camHUD.visible = false; // would be wierd if you could see the hud huh?
			camDead = game.camGame.beatSetup(conductor);
			camPoint = game.camPoint;
		}

		var camPos = character.getCamPos();
		character.playAnim('dies', NoDancing);
		deathSound.play();
		FlxTween.tween(camPoint, {x: camPos.x, y: camPos.y}, 2, {
			startDelay: 0.7,
			ease: FlxEase.smootherStepInOut,
			onUpdate: (_) -> camDead.snapToTarget(),
			onComplete: (_) -> {
				conductor.play();
				character.dance(); // forces the dance
			}
		});
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (Controls.accept || Settings.setup.instantRespawn) {
			conductor.stop();
			character.playAnim('retry', NoDancing);
			retrySound.play();
			var lol:Int = 0; // works thankfully lol, might change tho
			retrySound.onComplete = () -> {
				lol++;
				if (lol == 2)
					BeatState.resetState();
			}
			camDead.fade(FlxColor.BLACK, 3, () -> {
				lol++;
				if (lol == 2)
					BeatState.resetState();
			});
		}
		if (Controls.back) {
			conductor.stop();
			BeatState.switchState(() -> PlayState.storyMode ? new imaginative.states.menus.StoryMenu() : new imaginative.states.menus.FreeplayMenu());
		}
	}
}