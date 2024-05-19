package fnf.backend.scripting;

class ScriptGroup extends FlxBasic {
	public var members:Array<Script> = [];
	public var publicVars:Map<String, Dynamic> = [];
	public var extraVars:Map<String, Dynamic> = [];
	public var length(get, never):Int;
	private function get_length():Int return members.length;

	@:isVar public var parent(get, set):Dynamic;
	inline function get_parent():Dynamic return parent;
	inline function set_parent(value:Dynamic):Dynamic {
		for (script in members) script.parent = value;
		return parent = value;
	}

	// as of rn this func is ripped from cne
	public function importScript(path:String):Script {
		final script = Script.create(path);
		if (script.isInvalid) {
			throw 'Script at $path does not exist.';
			return null;
		}
		add(script);
		script.load();
		return script;
	}

	public function new(parent:Dynamic) {
		super();
		extraVars['importScript'] = importScript;
		this.parent = parent;
	}

	public function load(stopNewCall:Bool = false)
		for (script in members)
			script.load(stopNewCall);

	public function set(variable:String, value:Dynamic)
		for (script in members)
			script.set(variable, value);
	public function get(variable:String, ?def:Dynamic):Dynamic {
		for (script in members)
			return script.get(variable);
		return def;
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic {
		for (script in members)
			return script.call(funcName, args);
		return null;
	}

	public function event(func:String, event:Dynamic):Dynamic {
		for (script in members) {
			if (!script.active) continue;
			call(func, [event]);
			if (event.stopped && @:privateAccess !event.continueLoop) break;
		}
		return event;
	}

	public function add(script:Script) {
		members.push(script);
		setupScript(script);
	}

	override public function destroy():Void {
		for (script in members)
			script.destroy();
		super.destroy();
	}

	public function reload()
		for (script in members)
			script.reload();

	public function remove(script:Script)
		members.remove(script);

	public function insert(pos:Int, script:Script) {
		members.insert(pos, script);
		setupScript(script);
	}

	private function setupScript(script:Script) {
		if (parent != null) script.parent = parent;
		script.setPublicVars(publicVars);
		for (name => thing in extraVars) script.set(name, thing);
	}

	public function clearInvaild() {
		for (script in members) {
			if (script.isInvalid) {
				remove(script);
				script.destroy();
			}
		}
	}

	// whitsleing noises
	public function getByPath(name:String) {
		for(s in members)
			if (s.path == name)
				return s;
		return null;
	}
	public function getByName(name:String) {
		for(s in members)
			if (s.fileName == name)
				return s;
		return null;
	}
}