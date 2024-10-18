package backend.scripting.types;

final class LuaScript extends Script {
	/**
	 * All possible lua script extension types.
	 */
	public static final exts:Array<String> = ['lua'];

	#if CAN_LUA_SCRIPT
	public static function getScriptImports(script:LuaScript):Map<String, Dynamic>
		return [
			'disableScript' => () -> {
				script.active = false;
			},
			'print' => (value:Dynamic) -> {
				trace('${script.rootPath}: $value');
			}
		];

	override public function new(path:String) {
		trace('Lua scripting isn\'t supported... yet.');
		super(path);
	}
	#else
	override public function new(path:String) {
		trace('Lua scripting isn\'t supported in this build.');
		super(path);
	}
	#end
}