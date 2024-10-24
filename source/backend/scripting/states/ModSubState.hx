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
	public static var prevName:String = null;
	/**
	 * Previous conductor instance.
	 */
	public static var lastConductor:Conductor = null;

	public function new(subStateName:String, ?conductorInst:Conductor) {
		if (subStateName != null)
			prevName = subStateName;
		if (conductorInst != null)
			conductor = conductorInst;
		super(true, prevName);
	}
}