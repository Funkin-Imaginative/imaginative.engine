package fnf.backend.scripting.events;

final class BopEvent extends ScriptEvent {
	public var sway:Bool;

	public function new(sway:Bool) {
		super();
		this.sway = sway;
	}
}