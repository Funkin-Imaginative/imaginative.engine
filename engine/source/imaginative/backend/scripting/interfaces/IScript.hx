package imaginative.backend.scripting.interfaces;

/**
 * Implementing this interface means this class will be used to handle scripting capabilities.
 */
interface IScript {
	/**
	 * This variable holds the name of the script.
	 */
	var name(get, never):String;
	/**
	 * Contains the mod path information.
	 */
	var pathing(default, null):ModPath;
	/**
	 * This variable holds the name of the file extension.
	 */
	var extension(get, never):String;

	private var canRun:Bool;
	/**
	 * States the type of script this is.
	 */
	var type(get, never):ScriptType;

	private function renderNecessities():Void;

	private var code:String;
	private function renderScript(file:ModPath, ?code:String):Void;
	private function loadCodeString(code:String):Void;

	/**
	 * Load's code from string.
	 * @param code The script code.
	 * @param vars Variables to input into the script instance.
	 * @param funcToRun Function to run inside the script instance.
	 * @param funcArgs Arguments to run for said function.
	 * @return `Script` ~ The script instance from string.
	 */
	function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?funcArgs:Array<Dynamic>):Script;

	/**
	 * States if the script has loaded.
	 */
	var loaded(default, null):Bool;
	/**
	 * Load's the script, pretty self-explanatory.
	 */
	function load():Void;
	/**
	 * Reload's the script, pretty self-explanatory.
	 * Only if it's possible for that script type.
	 */
	function reload():Void;

	/**
	 * The parent object that the script is tied to.
	 */
	var parent(get, set):Dynamic;

	/**
	 * Set's the public map for getting global variables.
	 * @param map The map itself.
	 */
	function setPublicMap(map:Map<String, Dynamic>):Void;

	/**
	 * Set's a variable to the script.
	 * @param variable The variable to apply.
	 * @param value The value the variable will hold.
	 */
	function set(variable:String, value:Dynamic):Void;
	/**
	 * Get's a variable from the script.
	 * @param variable The variable to receive.
	 * @param def If it's null then return this.
	 * @return `Dynamic` ~ The value the variable will hold.
	 */
	function get(variable:String, ?def:Dynamic):Dynamic;
	/**
	 * Call's a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @return `Dynamic` ~ Whatever is in the functions return statement.
	 */
	function call(func:String, ?args:Array<Dynamic>):Dynamic;
	/**
	 * Call's a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	function event<SC:ScriptEvent>(func:String, event:SC):SC;

	/**
	 * End's the script.
	 * @param funcName Custom function call name.
	 */
	function end(funcName:String = 'end'):Void;
}