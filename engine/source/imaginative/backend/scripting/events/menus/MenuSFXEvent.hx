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

	/**
	 * Play's a menu sound effect.
	 * @param sound The sound.
	 * @param forcePlay Forces the sound to play if it gets prevented.
	 * @param onComplete FlxG.sound.play's onComplete function.
	 * @return `FlxSound` ~ The menu sound.
	 */
	inline public function playMenuSFX(sound:MenuSFX, forcePlay:Bool = false, ?onComplete:Void->Void):FlxSound
		return playSFX || forcePlay ? FunkinUtil.playMenuSFX(sound, sfxVolume, sfxSubFolder, onComplete) : new FlxSound();

	override public function new(playSFX:Bool = true, sfxVolume:Float = 0.7) {
		super();
		this.playSFX = playSFX;
		this.sfxVolume = sfxVolume;
	}
}