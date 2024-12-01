package backend.scripting.events.objects.gameplay;

final class GeneralMissEvent extends ScriptEvent {
	public var id:Int;
	public var field:ArrowField;

	override public function new(id:Int, field:ArrowField) {
		super();
		this.id = id;
		this.field = field;
	}
}