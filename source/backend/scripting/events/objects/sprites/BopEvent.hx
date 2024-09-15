package backend.scripting.events.objects.sprites;

final class BopEvent extends ScriptEvent {
	public var sway:Bool;

	public function new(sway:Bool) {
		super();
		this.sway = sway;
	}
}