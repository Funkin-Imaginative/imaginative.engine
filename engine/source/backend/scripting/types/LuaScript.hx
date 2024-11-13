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
				trace('${script.pathing.format()}: $value');
			}
		];

	@:allow(backend.scripting.Script.create)
	override function new(file:ModPath, ?code:String) {
		trace('Lua scripting isn\'t supported... yet.');
		super(file, code);
	}
	#else
	@:allow(backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		trace('Lua scripting isn\'t supported in this build.');
		super(file, null);
	}
	#end
}