package imaginative.backend.scripting.events.objects;

final class BopEvent extends ScriptEvent {
	/**
	 * States when the sway would play instead.
	 */
	public var sway:Bool;

	override public function new(sway:Bool) {
		super();
		this.sway = sway;
	}
}