package backend.scripting;

class ScriptGroup extends FlxBasic {
	public var members:Array<Script> = [];
	public var length(get, never):Int;
	private function get_length():Int
		return members.length;

	public var publicVars:Map<String, Dynamic> = [];
	public var extraVars:Map<String, Dynamic> = [];

	@:isVar public var parent(get, set):Dynamic;
	inline function get_parent():Dynamic
		return parent;
	inline function set_parent(value:Dynamic):Dynamic {
		for (script in members)
			script.parent = value;
		return parent = value;
	}

	// as of rn this func is ripped from cne
	public function importScript(path:String, stopNewCall:Bool = false):Script {
		final script = Script.create(path);
		if (script.isInvalid) {
			throw 'Script at $path does not exist.';
			return cast null;
		}
		add(script);
		script.load(stopNewCall);
		return script;
	}

	public function new(parent:Dynamic) {
		super();
		extraVars['importScript'] = importScript;
		this.parent = parent;
	}

	public function load(stopNewCall:Bool = false, clearInvaild:Bool = true) {
		if (clearInvaild)
			this.clearInvaild();
		for (script in members)
			script.load(stopNewCall);
	}

	public function set(variable:String, value:Dynamic)
		for (script in members)
			script.set(variable, value);

	public function get(variable:String, ?def:Dynamic):Dynamic {
		for (script in members)
			return script.get(variable);
		return def;
	}

	public function call(funcName:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		for (script in members)
			return script.call(funcName, args);
		return def;
	}

	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		for (script in members) {
			if (!script.active) continue;
			call(func, [event]);
			if (event.stopped && @:privateAccess !event.continueLoop) break;
		}
		return event;
	}

	public function reload()
		for (script in members)
			script.reload();

	public function add(script:Script) {
		members.push(script);
		setupScript(script);
	}

	override public function destroy():Void {
		for (script in members)
			script.destroy();
		super.destroy();
	}

	public function remove(script:Script)
		members.remove(script);

	public function insert(pos:Int, script:Script) {
		members.insert(pos, script);
		setupScript(script);
	}

	private function setupScript(script:Script) {
		if (parent != null) script.parent = parent;
		script.setPublicVars(publicVars);
		for (name => thing in extraVars)
			script.set(name, thing);
	}

	public function clearInvaild() {
		for (script in members) {
			if (script.isInvalid) {
				remove(script);
				script.destroy();
			}
		}
	}

	// whitsling noises
	public function getByPath(name:String) {
		var result:Script = null;
		for (script in members)
			if (script.path == name) {
				result = script;
				break;
			}
		return result;
	}

	public function getByName(name:String) {
		var result:Script = null;
		for (script in members)
			if (script.fileName == name) {
				result = script;
				break;
			}
		return result;
	}
}
