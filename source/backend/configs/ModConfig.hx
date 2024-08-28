package backend.configs;

class ModConfig {
	// for scripting's sake
	@:unreflective public static var soloOnlyMode:Bool = false;
	@:unreflective public static var personalSolo:Bool = false;

	public static var isSoloOnly(get, never):Bool;
	inline static function get_isSoloOnly():Bool
		return soloOnlyMode || personalSolo;

	public static var curSolo:String = 'funkin';
	public static var curMod:String = 'example mod';
	public static var globalMods:Array<String> = [];
}