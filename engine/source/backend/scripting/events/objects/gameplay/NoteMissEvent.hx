package backend.scripting.events.objects.gameplay;

final class NoteMissEvent extends ScriptEvent {
	public var note:Note;
	public var id:Int;
	public var field:ArrowField;

	override public function new(note:Note, ?id:Int, ?field:ArrowField) {
		super();
		this.note = note;
		this.id = id ?? note.id;
		this.field = field ?? note.setField;
	}
}