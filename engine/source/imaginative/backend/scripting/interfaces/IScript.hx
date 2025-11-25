package imaginative.backend.scripting.interfaces;

// TODO: Rework how this is coded.
/**
 * Implementing this interface means this class will be used to handle scripting capabilities.
 */
interface IScript {
	/**
	 * States the type of script this is.
	 */
	var type(get, never):ScriptType;

	/**
	 * Contains the mod path information.
	 */
	final filePath:ModPath;
	/**
	 * Holds the name of the script file.
	 */
	var name(get, never):String;
	/**
	 * Holds the name of the file extension.
	 */
	var extension(get, never):String;

	/**
	 * The parent object that the script is tied to.
	 */
	var parent(get, set):Dynamic;
	/**
	 * Sets the public map for getting global variables.
	 * @param map The map itself.
	 */
	function setGlobalVariables(map:Map<String, Dynamic>):Void;

	/**
	 * States if the script has loaded.
	 */
	var loaded(default, null):Bool;
	/**
	 * Loads the script, pretty self-explanatory.
	 */
	function load():Void;

	/**
	 * Sets a variable in the script.
	 * @param name The name of the variable.
	 * @param value The value to apply.
	 */
	function set(name:String, value:Dynamic):Void;
	/**
	 * Gets a variable from the script.
	 * @param name The name of the variable.
	 * @param def If it doesn't exist or is null, return this.
	 * @return Dynamic ~ The value.
	 */
	function get<V>(name:String, ?def:V):V;
	/**
	 * Calls a function in the script.
	 * @param func The name of the function.
	 * @param args Arguments of the said function.
	 * @param def If it returns null, then return this.
	 * @return Dynamic ~ Whatever the function returns.
	 */
	function call<R>(func:String, ?args:Array<Dynamic>, ?def:R):R;

	/**
	 * Ends the script.
	 * @param funcName Custom function call name.
	 */
	function end(funcName:String = 'end'):Void;
}