package imaginative.backend.scripting.events.menus;

final class ChoiceEvent extends MenuSFXEvent {
	/**
	 * The resulting name.
	 */
	public var choice:String;

	override public function new(choice:String) {
		super();
		this.choice = choice;
	}
}