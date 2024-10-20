package backend.interfaces;

/**
 * Implementing this interface means this class will be used to handle scripting capabilities.
 */
interface IScript {
	/**
	 * This variable holds the root path of where this the script is located.
	 */
	var rootPath:String;
	/**
	 * This variable holds the mod path of where this the script is located.
	 */
	var path:String;
	/**
	 * This variable holds the name of the script.
	 */
	var name:String;
	/**
	 * This variable holds the name of the file extension.
	 */
	var extension:String;

	private var canRun:Bool;
	/**
	 * States the type of script this is.
	 */
	var type(get, never):ScriptType;
	private function get_type():ScriptType;

	private function renderNecessities():Void;

	private var code:String;
	private function renderScript(path:String, ?code:String):Void;
	private function loadCodeString(code:String):Void;

	/**
	 * Load's code from string.
	 * @param code The script code.
	 * @param vars Variables to input into the script instance.
	 * @param funcToRun Function to run inside the script instance.
	 * @param fungArgs Arguments to run for said function.
	 */
	function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?fungArgs:Array<Dynamic>):Script;

	var loaded:Bool;
	function load():Void;
	function reload():Void;

	var parent(get, set):Dynamic;
	private function get_parent():Dynamic;
	private function set_parent(value:Dynamic):Dynamic;

	function setPublicVars(map:Map<String, Dynamic>):Void;

	function set(variable:String, value:Dynamic):Void;
	function get(variable:String, ?def:Dynamic):Dynamic;
	function call(funcName:String, ?args:Array<Dynamic>):Dynamic;
	function event<SC:ScriptEvent>(func:String, event:SC):SC;
}