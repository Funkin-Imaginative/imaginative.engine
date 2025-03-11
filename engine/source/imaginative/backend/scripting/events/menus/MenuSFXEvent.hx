package imaginative.backend.scripting.events.menus;

class MenuSFXEvent extends ScriptEvent {
	/**
	 * If true, the menu sound effect will play.
	 */
	public var playSFX(get, default):Bool;
	inline function get_playSFX():Bool
		return sfxVolume > 0 ? playSFX : false;
	/**
	 * The volume of the sound effect.
	 */
	public var sfxVolume:Float;

	/**
	 * Sub folder path/name.
	 */
	public var sfxSubFolder:Null<String>;

	override public function new(playSFX:Bool = true, sfxVolume:Float = 0.7) {
		super();
		this.playSFX = playSFX;
		this.sfxVolume = sfxVolume;
	}
}