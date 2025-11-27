package imaginative.backend.scripting.group;

// TODO: Rethink this class.
/**
 * This class is to utilize several scripts in a single place.
 */
class ScriptGroup extends FlxTypedGroup<Script> implements IScript {
	/**
	 * Public variables throughout the group.
	 */
	public var globalVariables:Map<String, Dynamic> = new Map<String, Dynamic>();
	/**
	 * Shared variables throughout the group.
	 */
	public var extraVariables:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * The parent object that the script group is tied to.
	 */
	@:isVar public var parent(get, set):Dynamic;
	inline function get_parent():Dynamic return parent; // so IScript won't yell at me
	inline function set_parent(value:Dynamic):Dynamic {
		forEach((script:Script) -> script.parent = value);
		return parent = value;
	}

	/**
	 * Imports a script into the group.
	 * @param file The mod path.
	 * @return Script
	 */
	public function importScript(file:ModPath):Script {
		final script:Script = Script.create(file);
		if (script.type.dummy) {
			script.destroy();
			log('Script at "${file.format()}", doesn\'t exist.', WarningMessage);
			return null;
		}
		add(script);
		script.load();
		return script;
	}

	public function new(?parent:Dynamic) {
		super();
		extraVariables['importScript'] = importScript;
		this.parent = parent;
		memberAdded.add(setupScript);
	}

	/**
	 * Loads the scripts in the group, pretty self-explanatory.
	 */
	public function load():Void {
		clearInvalid();
		forEach((script:Script) -> script.load());
	}

	/**
	 * Sets a variable in all scripts.
	 * @param name The name of the variable.
	 * @param value The value to apply.
	 */
	public function set(name:String, value:Dynamic):Void
		forEach((script:Script) -> script.set(name, value));
	/**
	 * Gets a variable from any of the scripts.
	 * @param name The name of the variable.
	 * @param def If it doesn't exist or is null, return this.
	 * @return Dynamic ~ The value.
	 */
	public function get<V>(name:String, ?def:V):V {
		// var commonValue:V;
		forEach((script:Script) -> script.get(name));
		return def;
	}
	/**
	 * Calls a function in all the scripts.
	 * @param func The name of the function.
	 * @param args Arguments of the said function.
	 * @param def If it returns null, then return this.
	 * @return Dynamic ~ Whatever the function returns.
	 */
	public function call<R>(func:String, ?args:Array<Dynamic>, ?def:R):R {
		// var commonValue:V;
		forEach((script:Script) -> script.call(func, args));
		return def;
	}
	/**
	 * Calls an event in the script instance.
	 * @param func The name of the function to call.
	 * @param event The event class.
	 * @return ScriptEvent
	 */
	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		forEach((script:Script) -> {
			event.returnCall = script.call(func, [event]);
			if (event.prevented && !event.continueLoop) return;
		});
		return event;
	}

	@:deprecated('It doesn\'t make sense for ScriptGroup to have the power to recycle.')
	override public function recycle(?objectClass:Class<Script>, ?objectFactory:Void->Script, force:Bool = false, revive:Bool = true):Script return null;

	function isDuplicate(script:Script):Bool {
		var check:Script = getByPath(script.filePath.path);
		var isDup:Bool = check != null;
		if (isDup) script.end('onDuplicate');
		return isDup;
	}

	function setupScript(script:Script):Void {
		if (parent != null) script.parent = parent;
		script.setGlobalVariables(globalVariables);
		for (name => thing in extraVariables)
			script.set(name, thing);
	}

	/**
	 * Improper scripts get removed from the group.
	 */
	public function clearInvalid():Void {
		forEach((script:Script) -> {
			if (script.type.dummy) {
				remove(script, true);
				script.end('onInvalid');
			}
		});
	}

	/**
	 * Ends the script group.
	 * @param funcName Custom function call name.
	 */
	inline public function end(funcName:String = 'end'):Void {
		call(funcName);
		destroy();
	}

	override public function destroy():Void {
		globalVariables.clear(); // jic
		extraVariables.clear();
		super.destroy();
	}

	/**
	 * Gets a script from within the group via it's mod path.
	 * @param path The mod path.
	 * @return Script ~ The returned script.
	 */
	public function getByPath(path:String):Script {
		var result:Script = null;
		forEach((script:Script) -> {
			if (script.filePath.path == path) {
				result = script;
				return;
			}
		});
		return result;
	}
	/**
	 * Gets a script from within the group via it's file name.
	 * @param name The name.
	 * @return Script ~ The returned script.
	 */
	public function getByName(name:String):Script {
		var result:Script = null;
		forEach((script:Script) -> {
			if (script.name == name) {
				result = script;
				return;
			}
		});
		return result;
	}
}
