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

	@:allow(states.PlayState)
	override function new() {
		super();
	}

	override function create():Void {
		script = Script.create(scriptPath, false)[0];
		super.create();
	}
}