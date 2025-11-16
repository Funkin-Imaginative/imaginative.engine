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

	override public function create():Void {
		script = Script.create(scriptPath, false)[0];
		super.create();

		FlxG.cameras.add(camera = new FlxCamera(), false);
		camera.bgColor = 0xb3000000;
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
		if (FlxG.cameras.list.contains(camera))
			FlxG.cameras.remove(camera, true);
		conductor.stop();
		super.destroy();
	}
}