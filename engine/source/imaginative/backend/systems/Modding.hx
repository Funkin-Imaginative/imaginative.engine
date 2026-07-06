package imaginative.backend.systems;

class Modding {
	#if Modding
	/**
	 * The current master mod.
	 */
	public var masterMod(default, null):Null<String> = null;
	/**
	 * The current module mod.
	 */
	public var moduleMod:Null<String> = null;

	/**
	 * The active module mods.
	 */
	public var moduleList:Array<String> = [];

	/**
	 * If true, the current master mod is the engines fallback mod.
	 */
	public var masterIsFallback(get, never):Bool;
	inline static function get_masterIsFallback():Bool
		return masterMod == Game.fallbackMod;
	#end
}