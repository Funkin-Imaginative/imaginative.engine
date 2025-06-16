package imaginative.backend.scripting.interfaces;

/**
 * Implementing this interface means this class will be used to handle scripting capabilities.
 */
interface IScript {
	/**
	 * Contains the mod path information.
	 */
	var scriptPath(default, null):ModPath;

	/**
	 * This variable holds the name of the script.
	 */
	var fileName(get, never):String;
	/**
	 * This variable holds the name of the file extension.
	 */
	var extension(get, never):String;

	/**
	 * States the type of script this is.
	 */
	var type(get, never):ScriptType;

	// /**
	//  * Loads code from string.
	//  * @param code The script code.
	//  * @param vars Variables to input into the script instance.
	//  * @param funcToRun Function to run inside the script instance.
	//  * @param funcArgs Arguments to run for said function.
	//  * @return `Script` ~ The script instance from string.
	//  */
	// function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?funcArgs:Array<Dynamic>):Script;

	/**
	 * If true, the script is active and can mess around with the game.
	 */
	var active(get, default):Bool;
	/**
	 * States if the script has loaded.
	 */
	var loaded(default, null):Bool;
	/**
	 * Loads the script, pretty self-explanatory.
	 */
	function load():Void;

	/**
	 * The parent object that the script is tied to.
	 */
	var parent(get, set):Dynamic;

	/**
	 * Sets a variable to the script.
	 * @param variable The variable to apply.
	 * @param value The value the variable will hold.
	 */
	function set(variable:String, value:Dynamic):Void;
	/**
	 * Gets a variable from the script.
	 * @param variable The variable to receive.
	 * @param def If it's null then return this.
	 * @return `T` ~ The value the variable will hold.
	 */
	function get<T>(variable:String, ?def:T):T;
	/**
	 * Calls a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @param def If your using this to return something, then this would be if it returns null.
	 * @return `T` ~ Whatever is in the functions return statement.
	 */
	function call<T>(func:String, ?args:Array<Dynamic>, ?def:T):T;
	/**
	 * Calls a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	function event<SC:ScriptEvent>(func:String, event:SC):SC;

	/**
	 * Ends the script, basically **destroy**, but with an extra step.
	 * @param funcName The function name to call that tells the script that it's time is over.
	 */
	function end(funcName:String = 'end'):Void;
}