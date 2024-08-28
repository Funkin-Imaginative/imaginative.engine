package backend.scripting;

class ModSubState extends BeatSubState {
	public static var lastName:String = null;

	public function new(stateName:String, statePath:String = '') {
		if (stateName != null)
			lastName = stateName;
		statePathShortcut = statePath;
		super(true, lastName);
	}
}