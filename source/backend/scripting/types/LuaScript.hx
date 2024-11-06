package backend.scripting.types;

#if CAN_LUA_SCRIPT
#end

/**
 * This class handles script instances under the lua language.
 */
final class LuaScript extends Script {
	/**
	 * All possible lua extension types.
	 */
	public static final exts:Array<String> = ['lua'];

	#if CAN_LUA_SCRIPT
	static function getScriptImports(script:LuaScript):Map<String, Dynamic>
		return [
			'disableScript' => () -> {
				script.active = false;
			},
			'print' => (value:Dynamic) -> {
				trace('${script.rootPath}: $value');
			}
		];

	@:allow(backend.scripting.Script.create)
	override function new(path:String, ?code:String) {
		trace('Lua scripting isn\'t supported... yet.');
		super(path, code);
	}
	#else
	@:allow(backend.scripting.Script.create)
	override function new(path:String, ?_:String) {
		trace('Lua scripting isn\'t supported in this build.');
		super(path, null);
	}
	#end
}