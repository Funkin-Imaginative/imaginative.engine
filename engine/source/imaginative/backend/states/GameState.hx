package imaginative.backend.states;

class GameState extends flixel.FlxSubState {
	/**
	 * The states conductor instance.
	 */
	@:isVar public var conductor(get, set):Conductor;
	function get_conductor():Conductor return Conductor.menu;
	function set_conductor(value:Conductor):Conductor return Conductor.menu;
	// this to for overriding when it comes to game play ^^

	public function new() {
		super();
	}
}