package imaginative.states;

class LaunchScreen extends imaginative.backend.states.GameState {
	@:unreflective static var game_boot:Bool = false;
	static var splash_screen:Bool = false;

	override function create():Void {
		super.create();
		trace('LaunchScreen created!');

		if (!game_boot) @:privateAccess {
			game_boot = true;
			Assets.init();
		}
		if (!splash_screen) {
			splash_screen = true;
		}

		Sys.exit(0);
	}
}