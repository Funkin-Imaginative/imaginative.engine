package imaginative.backend.scripting.events.menus;

final class SelectionChangeEvent extends MenuSFXEvent {
	/**
	 * The value before the change.
	 */
	public final previousValue:Int;
	/**
	 * The value after the change.
	 */
	public var currentValue:Int;

	// TODO: Figure out how to account for -1 (unselected).
	/**
	 * The amount of change between the **previousValue** and the **currentValue**.
	 */
	public var changeAmount(get, never):Int;
	inline function get_changeAmount():Int
		return currentValue - previousValue;
	/**
	 * States if the amount of change between the **previousValue** and the **currentValue** is unchanged.
	 */
	public var noChange(get, never):Bool;
	inline function get_noChange():Bool
		return changeAmount == 0;

	override public function playMenuSFX(sound:MenuSFX, forcePlay:Bool = false, ?onComplete:Void->Void):Null<FlxSound> {
		if (noChange) return null;
		return super.playMenuSFX(sound, forcePlay, onComplete);
	}

	override public function new(previousValue:Int, currentValue:Int) {
		super();
		this.previousValue = previousValue;
		this.currentValue = currentValue;
	}
}