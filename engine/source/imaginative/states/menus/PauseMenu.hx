package imaginative.states.menus;

class PauseMenu extends BeatSubState {
	/**
	 * The mod path of the script.
	 * I recommend setting the type to be respective to the mods type. So you don't set this as the wrong script.
	 */
	public static var scriptPath:ModPath;

	/**
	 * The pause menu script.
	 */
	public var script:Script;

	override public function new() {
		super(true, true);
	}

	override function initCamera():Void
		FlxG.cameras.add(camera = mainCamera = new BeatCamera('Pause Camera'), false).bgColor = 0xb3000000;

	override public function create():Void {
		add(script = Script.create(scriptPath));
		super.create();
		conductor.loadMusic('breakfast', (_:FlxSound) -> {
			conductor.playFromTime(FlxG.random.float(0, conductor.length / 2), 0);
			conductor.fadeIn(5, 0.5);
		});
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (Controls.global.accept)
			close();
		if (Controls.global.back)
			BeatState.switchState(() -> PlayState.storyMode ? new StoryMenu() : new FreeplayMenu());
	}

	override public function destroy():Void {
		conductor.stop();
		super.destroy();
	}
}