package backend.scripting.states;

/**
 * Used for custom states.
 */
class ModState extends BeatState {
	override public function get_conductor():Conductor
		return conductor;
	override public function set_conductor(value:Conductor):Conductor
		return conductor = value;

	/**
	 * Previous state name.
	 */
	public static var lastName:String = null;

	public function new(stateName:String) {
		conductor = Conductor.menu;
		if (stateName != null)
			lastName = stateName;
		super(true, lastName);
	}
}