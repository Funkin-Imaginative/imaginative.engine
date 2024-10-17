package backend.scripting.states;

class ModSubState extends BeatSubState {
	override public function get_conductor():Conductor
		return conductor;
	override public function set_conductor(value:Conductor):Conductor
		return conductor = value;

	public static var lastName:String = null;

	public function new(stateName:String) {
		conductor = Conductor.menu;
		if (stateName != null)
			lastName = stateName;
		super(true, lastName);
	}
}