package fnf.backend.scripting;

class ModSubstate extends SongSubstate {
	public static var lastName:String = null;
	public function new(stateName:String) {
		if (stateName != null) lastName = stateName;
		super(true, lastName);
	}
}