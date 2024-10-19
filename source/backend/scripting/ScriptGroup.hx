package backend.scripting;

class ScriptGroup extends FlxBasic {
	public var members:Array<Script> = [];
	public var length(get, never):Int;
	inline function get_length():Int
		return members.length;

	public var publicVars:Map<String, Dynamic> = [];
	public var extraVars:Map<String, Dynamic> = [];

	@:isVar public var parent(get, set):Dynamic;
	inline function get_parent():Dynamic
		return parent;
	inline function set_parent(value:Dynamic):Dynamic {
		for (script in members)
			if (script != null)
				script.parent = value;
		return parent = value;
	}

	// as of rn this func is ripped from cne
	public function importScript(path:String, pathType:FunkinPath = ANY):Script {
		final script:Script = Script.create(path, pathType, false)[0];
		if (script.type.dummy) {
			trace('Script at "$path", doesn\'t exist.');
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

	public function load(clearInvaild:Bool = true):Void {
		if (clearInvaild)
			this.clearInvaild();
		for (script in members)
			if (script != null)
				script.load();
	}

	public function set(variable:String, value:Dynamic):Void
		for (script in members)
			if (script != null)
				script.set(variable, value);

	public function get(variable:String, ?def:Dynamic):Dynamic {
		for (script in members)
			if (script != null)
				return script.get(variable);
		return def;
	}

	public function call(funcName:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		for (script in members)
			if (script != null)
				return script.call(funcName, args);
		return def;
	}

	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		for (script in members) {
			if (!script.active) continue;
			event.returnCall = call(func, [event]);
			if (event.stopped && @:privateAccess !event.continueLoop) break;
		}
		return event;
	}

	public function reload():Void
		for (script in members)
			if (script != null)
				script.reload();

	public function add(script:Script, allowDuplicate:Bool = false):Void {
		if (!allowDuplicate && isDuplicate(script)) return;
		members.push(script);
		setupScript(script);
	}

	override public function destroy():Void {
		for (script in members)
			if (script != null)
				script.destroy();
		super.destroy();
	}

	public function remove(script:Script):Void
		members.remove(script);

	public function insert(pos:Int, script:Script, allowDuplicate:Bool = false):Void {
		if (!allowDuplicate && isDuplicate(script)) return;
		members.insert(pos, script);
		setupScript(script);
	}

	function isDuplicate(script:Script):Bool {
		var check:Script = getByPath(script.path);
		var isDup:Bool = check != null;
		if (isDup) script.destroy();
		return isDup;
	}

	function setupScript(script:Script):Void {
		if (parent != null) script.parent = parent;
		script.setPublicVars(publicVars);
		for (name => thing in extraVars)
			script.set(name, thing);
	}

	public function clearInvaild():Void {
		for (script in members) {
			if (script != null && script.type.dummy) {
				remove(script);
				script.destroy();
			}
		}
	}

	// whitsling noises
	public function getByPath(name:String):Script {
		var result:Script = null;
		for (script in members)
			if (script != null && script.path == name) {
				result = script;
				break;
			}
		return result;
	}

	public function getByName(name:String):Script {
		var result:Script = null;
		for (script in members)
			if (script != null && script.name == name) {
				result = script;
				break;
			}
		return result;
	}
}
