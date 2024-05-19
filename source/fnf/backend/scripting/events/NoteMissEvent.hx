package fnf.backend.scripting.events;

import fnf.objects.note.Note;

final class NoteMissEvent extends ScriptEvent {
	public var note:Note;
	public var direction:Int;

	override public function new(note:Note, ?direction:Int) {
		super();
		this.note = note;
		this.direction = direction == null ? note.ID : direction;
	}
}