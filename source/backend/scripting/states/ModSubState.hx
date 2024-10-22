package backend.scripting.states;

/**
 * Used for custom subStates.
 */
class ModSubState extends BeatSubState {
	override public function get_conductor():Conductor
		return conductor;
	override public function set_conductor(value:Conductor):Conductor
		return conductor = value;

	/**
	 * Previous subState name.
	 */
	public static var lastName:String = null;

	public function new(subStateName:String, ?conductor:Conductor) {
		this.conductor = conductor.getDefault(Conductor.menu);
		if (subStateName != null)
			lastName = subStateName;
		super(true, lastName);
	}
}