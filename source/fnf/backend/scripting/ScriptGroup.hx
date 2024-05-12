package fnf.backend.scripting;

class ScriptGroup extends FlxBasic {
	public var scripts:Array<Script> = [];
	public var parent:Dynamic;

	public function new(stateName:String) {
		super();
	}

	public function setParent(parent:Dynamic)
		for (script in scripts)
			script.setParent(parent);
}