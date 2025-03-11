package imaginative.backend.scripting.events.menus;

class MenuSFXEvent extends ScriptEvent {
	/**
	 * If true, the menu sound effect will play.
	 */
	public var playMenuSFX(get, default):Bool;
	inline function get_playMenuSFX():Bool
		return sfxVolume > 0 ? playMenuSFX : false;
	/**
	 * The volume of the sound effect.
	 */
	public var sfxVolume:Float;

	/**
	 * Sub folder path/name.
	 */
	public var sfxSubFolder:Null<String>;

	override public function new(playMenuSFX:Bool = true, sfxVolume:Float = 0.7) {
		super();
		this.playMenuSFX = playMenuSFX;
		this.sfxVolume = sfxVolume;
	}
}