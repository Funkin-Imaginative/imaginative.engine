package imaginative.states;

class GameoverState extends BeatSubState {
	var game(get, never):PlayState;
	inline function get_game():PlayState
		return PlayState.instance;

	var character:Character;
	var camDead:BeatCamera;

	override public function new(targetChar:Character) {
		super(true, true);
		character = new Character(targetChar.x, targetChar.y, '${targetChar.theirName}-dead', targetChar.flipX);
		bgColor = FlxColor.BLACK;
	}

	override public function create():Void {
		super.create();
		parent.persistentDraw = false;
		add(character);

		conductor.loadMusic('gameover/gameOver');
		if (game == null)
			FlxG.cameras.add(camDead = new BeatCamera('Dead Camera').beatSetup(conductor), false);
		else camDead = game.camGame.beatSetup(conductor);

		var camPos = character.getCamPos();
		FlxTween.tween(camDead, {x: camPos.x, y: camPos.y}, 2, {
			ease: FlxEase.smootherStepInOut,
			onComplete: (_) -> conductor.play()
		});
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (Controls.accept || Settings.setup.instantRespawn) {
			BeatState.resetState();
			conductor.stop();
		}
		if (Controls.back) {
			BeatState.switchState(() -> PlayState.storyMode ? new imaginative.states.menus.StoryMenu() : new imaginative.states.menus.FreeplayMenu());
			conductor.stop();
		}
	}
}