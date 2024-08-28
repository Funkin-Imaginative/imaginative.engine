package backend.scripting;

class ModState extends BeatState {
	public static var lastName:String = null;

	public function new(stateName:String, statePath:String = '') {
		if (stateName != null)
			lastName = stateName;
		statePathShortcut = statePath;
		super(true, lastName);
	}
}