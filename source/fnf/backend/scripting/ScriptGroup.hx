package fnf.backend.scripting;

class ScriptGroup extends FlxBasic {
	public var scripts:Array<Script> = [];
	public var publicVars:Map<String, Dynamic> = [];
	public var extraVars:Map<String, Dynamic> = [];

	public var parent(get, set):Dynamic = null;
	inline function get_parent():Dynamic return parent;
	inline function set_parent(value:Dynamic):Dynamic {
		for (script in scripts) script.parent = value;
		return parent = value;
	}

	// as of rn this func is ripped from cne
	public function importScript(path:String):Script {
		/* var script = Script.create(Paths.script(path));
		if (script is DummyScript) {
			throw 'Script at ${path} does not exist.';
			return null;
		}
		add(script);
		script.load();
		return script; */
	}

	public function new(stateName:String) {
		extraVars['importScript'] = importScript;
		super();
		add(new Script(stateName, 'state'));
	}

	public function add(script:Script) {
		scripts.push(script);
		setupScript(script);
	}

	public function remove(script:Script) scripts.remove(script);

	public function insert(pos:Int, script:Script) {
		scripts.insert(pos, script);
		setupScript(script);
	}

	private function setupScript(script:Script) {
		if (parent != null) script.parent = parent;
		script.setPublicVars(publicVars);
		for (name => thing in extraVars) script.set(name, thing);
	}
}