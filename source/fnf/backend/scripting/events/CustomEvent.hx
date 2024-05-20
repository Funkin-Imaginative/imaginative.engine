package fnf.backend.scripting.events;

// just for your custom event calls :)

final class CustomEvent extends ScriptEvent {
	public var data:Dynamic;

	override public function new(data:Dynamic) {
		super();
		this.data = data;
	}
}