package fnf.backend.scripting;

class ScriptGroup extends FlxBasic {
	public var scripts:Array<Script> = [];
	public var publicVars:Map<String, Dynamic> = [];
	public var extraVars:Map<String, Dynamic> = [];

	@:isVar public var parent(get, set):Dynamic;
	inline function get_parent():Dynamic return parent;
	inline function set_parent(value:Dynamic):Dynamic {
		for (script in scripts) script.parent = value;
		return parent = value;
	}

	// as of rn this func is ripped from cne
	public function importScript(path:String):Script {
		var script = Script.create(path);
		if (script.isInvalid) {
			throw 'Script at $path does not exist.';
			return null;
		}
		add(script);
		script.load();
		return script;
	}

	public function new(stateName:String) {
		extraVars['importScript'] = importScript;
		super();
	}

	public function load()
		for (script in scripts)
			script.load();

	public function set(variable:String, value:Dynamic)
		for (script in scripts)
			script.set(variable, value);
	public function get(variable:String)
		for (script in scripts)
			script.get(variable);

	public function call(funcName:String, ?args:Array<Dynamic>)
		for (script in scripts)
			script.call(funcName, args);

	public function add(script:Script) {
		scripts.push(script);
		setupScript(script);
	}

	override public function destroy():Void {
		for (script in scripts)
			script.destroy();
		super.destroy();
	}

	public function reload()
		for (script in scripts)
			script.reload();

	public function remove(script:Script)
		scripts.remove(script);

	public function insert(pos:Int, script:Script) {
		scripts.insert(pos, script);
		setupScript(script);
	}

	private function setupScript(script:Script) {
		if (parent != null) script.parent = parent;
		script.setPublicVars(publicVars);
		for (name => thing in extraVars) script.set(name, thing);
	}

	// whitsleing noises
	public function getByPath(name:String) {
		for(s in scripts)
			if (s.path == name)
				return s;
		return null;
	}
	public function getByName(name:String) {
		for(s in scripts)
			if (s.fileName == name)
				return s;
		return null;
	}
}