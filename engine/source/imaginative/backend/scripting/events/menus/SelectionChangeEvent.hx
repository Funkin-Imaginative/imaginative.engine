package imaginative.backend.scripting.events.menus;

final class SelectionChangeEvent extends MenuSFXEvent {
	/**
	 * The value before the change
	 */
	public var previousValue:Int;
	/**
	 * The value after the change
	 */
	public var currentValue:Int;

	/**
	 * The amount of change between the **previousValue** and the **currentValue**.
	 */
	public var changeAmount:Int;

	override public function new(previousValue:Int, currentValue:Int, changeAmount:Int, playSFX:Bool = true, sfxVolume:Float = 0.7) {
		super(previousValue != currentValue ? playSFX : false, sfxVolume);
		this.previousValue = previousValue;
		this.currentValue = currentValue;
	}
}