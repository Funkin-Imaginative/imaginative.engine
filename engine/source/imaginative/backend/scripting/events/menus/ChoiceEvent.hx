package imaginative.backend.scripting.events.menus;

final class ChoiceEvent extends MenuSFXEvent {
	/**
	 * The resulting name.
	 */
	public var choice:String;

	override public function new(choice:String, playSFX:Bool = true, sfxVolume:Float = 0.7) {
		super(playSFX, sfxVolume);
		this.choice = choice;
	}
}