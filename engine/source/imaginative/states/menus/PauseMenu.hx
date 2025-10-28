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

	var stateConductor:Conductor;

	override public function new(?conductor:Conductor) {
		stateConductor = conductor;
		super();
	}

	override public function create():Void {
		script = Script.create(scriptPath, false)[0];
		super.create();

		FlxG.cameras.add(camera = new FlxCamera(), false);
		camera.bgColor = 0xb3000000;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.accept) {
			close();
			parent.persistentUpdate = true;
			stateConductor?.resume();
		}
		if (Controls.back)
			BeatState.switchState(() -> PlayState.storyMode ? new StoryMenu() : new FreeplayMenu());
	}

	override public function destroy():Void {
		if (FlxG.cameras.list.contains(camera))
			FlxG.cameras.remove(camera, true);
		super.destroy();
	}
}