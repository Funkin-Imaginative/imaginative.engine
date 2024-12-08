package backend.scripting.states;

/**
 * Used for custom substates.
 */
class ScriptedSubState extends BeatSubState {
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

	override public function new(subStateName:String, ?conductorInst:Conductor) {
		prevName = subStateName ?? 'NullState';
		conductor = conductorInst ?? (lastConductor ??= Conductor.menu);
		super(true, prevName);
	}
}