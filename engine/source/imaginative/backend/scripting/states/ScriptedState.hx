package imaginative.backend.scripting.states;

/**
 * Used for custom states.
 */
class ScriptedState extends BeatState {
	override public function get_conductor():Conductor
		return conductor;
	override public function set_conductor(value:Conductor):Conductor
		return conductor = value;

	/**
	 * Previous state name.
	 */
	public static var prevName:String = null;
	/**
	 * Previous conductor instance.
	 */
	public static var lastConductor:Conductor = null;

	override public function new(stateName:String, ?conductorInst:Conductor) {
		prevName = stateName ?? 'NullState';
		conductor = conductorInst ?? (lastConductor ??= Conductor.menu);
		super(true, prevName);
	}
}