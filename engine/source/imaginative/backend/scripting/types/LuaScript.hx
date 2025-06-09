package imaginative.backend.scripting.types;

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
	@:access(imaginative.backend.Console.formatLogInfo)
	static function getScriptImports(script:LuaScript):Map<String, Dynamic> {
		return [
			'print' => (value:Dynamic) ->
				_log(Console.formatLogInfo(value, LogMessage, script.scriptPath.format(), FromLua)),
			'log' => (value:Dynamic, level:String = LogMessage) ->
				_log(Console.formatLogInfo(value, level, script.scriptPath.format(), FromLua)),

			'disableScript' => () ->
				script.active = false
		];
	}

	@:allow(imaginative.backend.scripting.Script.create)
	override function new(file:ModPath, ?code:String) {
		log('Lua scripting isn\'t supported... yet.', SystemMessage);
		super(file, code);
	}
	#else
	@:allow(imaginative.backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		log('Lua scripting isn\'t supported in this build.', SystemMessage);
		super(file, null);
	}
	#end
}