package backend.interfaces;

/* extern */ interface IScript {
	// static final exts:Array<String>;
	var rootPath:String;
	var path:String;
	var name:String;
	var extension:String;

	private var canRun:Bool;
	var type(get, never):ScriptType;
	private function get_type():ScriptType;

	// static function getScriptImports(script:Script):Map<String, Dynamic>;

	private function renderNecessities():Void;

	private var code:String;
	private function renderScript(path:String, ?code:String):Void;
	private function loadCodeString(code:String):Void;

	function loadCodeFromString(code:String, ?vars:Map<String, Dynamic>, ?funcToRun:String, ?fungArgs:Array<Dynamic>):Void;

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