package backend.scripting.events.objects.gameplay;

final class NoteHitEvent extends ScriptEvent {
	public var note:Note;
	public var id:Int;
	public var field:ArrowField;
	public var createSplash:Bool = false;
	public var createHoldCover:Bool = true;
	public var stopStrumConfirm:Bool = false;

	override public function new(note:Note, ?id:Int, ?field:ArrowField) {
		super();
		this.note = note;
		this.id = id ?? note.id;
		this.field = field ?? note.setField;
	}
}