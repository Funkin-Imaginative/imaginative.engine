package backend.scripting;

/**
 * This class is to utilize several scripts in a single place.
 */
class ScriptGroup extends FlxBasic {
	/**
	 * `Array` of all the members in this group.
	 */
	public var members:Array<Script> = [];
	/**
	 * The number of entries in the members array. For performance and safety you should check this
	 * variable instead of `members.length` unless you really know what you're doing!
	 */
	public var length(get, never):Int;
	inline function get_length():Int
		return members.length;

	/**
	 * Public variables throughout the group.
	 */
	public var publicVars:Map<String, Dynamic> = [];
	/**
	 * Shared variables throughout the group.
	 */
	public var extraVars:Map<String, Dynamic> = [];

	/**
	 * The parent object that the script group is tied to.
	 */
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

	public function new(?parent:Dynamic) {
		super();
		extraVars['importScript'] = importScript;
		this.parent = parent;
	}

	/**
	 * Load's the scripts in the group, pretty self-explanatory.
	 * @param clearInvaild If true, improper scripts will be removed from the group.
	 */
	public function load(clearInvaild:Bool = true):Void {
		if (clearInvaild)
			this.clearInvaild();
		for (script in members)
			if (script != null)
				script.load();
	}
	/**
	 * Reload's the scripts in the group, pretty self-explanatory.
	 * Only if it's possible for that script type.
	 */
	public function reload():Void
		for (script in members)
			if (script != null)
				script.reload();

	/**
	 * Set's a variable to the script.
	 * @param variable The variable to apply.
	 * @param value The value the variable will hold.
	 */
	public function set(variable:String, value:Dynamic):Void
		for (script in members)
			if (script != null)
				script.set(variable, value);
	/**
	 * Get's a variable from the script.
	 * @param variable The variable to receive.
	 * @param def If it's null then return this.
	 * @return `Dynamic` ~ The value the variable will hold.
	 */
	public function get(variable:String, ?def:Dynamic):Dynamic {
		for (script in members)
			if (script != null)
				return script.get(variable);
		return def;
	}
	/**
	 * Call's a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @return `Dynamic` ~ Whatever is in the functions return statement.
	 */
	public function call(func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		for (script in members)
			if (script != null)
				return script.call(func, args);
		return def;
	}
	/**
	 * Call's a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		for (script in members) {
			if (!script.active) continue;
			event.returnCall = call(func, [event]);
			if (event.stopped && @:privateAccess !event.continueLoop) break;
		}
		return event;
	}

	/**
	 * Adds a new script to the group.
	 * @param script The script you want to add to the group.
	 * @param allowDuplicate If true, it allow scripts of the same mod path to be added.
	 */
	public function add(script:Script, allowDuplicate:Bool = false):Void {
		if (!allowDuplicate && isDuplicate(script)) return;
		members.push(script);
		setupScript(script);
	}
	/**
	 * Inserts a new script to the group at the specified position.
	 * @param position The position that the new script should be inserted at.
	 * @param script The script you want to insert into the group.
	 * @param allowDuplicate If true, it allow scripts of the same mod path to be added.
	 */
	public function insert(position:Int, script:Script, allowDuplicate:Bool = false):Void {
		if (!allowDuplicate && isDuplicate(script)) return;
		members.insert(position, script);
		setupScript(script);
	}
	/**
	 * Removes the specified script from the group.
	 * @param script The script you want to remove.
	 */
	public function remove(script:Script):Void
		members.remove(script);

	function isDuplicate(script:Script):Bool {
		var check:Script = getByPath(script.path);
		var isDup:Bool = check != null;
		if (isDup) script.destroy();
		return isDup;
	}

	function setupScript(script:Script):Void {
		if (parent != null) script.parent = parent;
		script.setPublicMap(publicVars);
		for (name => thing in extraVars)
			script.set(name, thing);
	}

	/**
	 * Improper scripts get removed from the group.
	 */
	public function clearInvaild():Void {
		for (script in members) {
			if (script != null && script.type.dummy) {
				remove(script);
				script.destroy();
			}
		}
	}

	override public function destroy():Void {
		for (script in members)
			if (script != null)
				script.destroy();
		super.destroy();
	}

	/**
	 * Get's a script from within the group via it's mod path.
	 * @param path The mod path.
	 * @return `Script` ~ The returned script.
	 */
	public function getByPath(path:String):Script {
		var result:Script = null;
		for (script in members)
			if (script != null && script.path == path) {
				result = script;
				break;
			}
		return result;
	}
	/**
	 * Get's a script from within the group via it's name.
	 * @param name The name.
	 * @return `Script` ~ The returned script.
	 */
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
