package fnf.backend.scripting.events;

import fnf.objects.note.Note;

final class NoteHitEvent extends ScriptEvent {
	public var note:Note;
	public var direction:Int;
	public var showSplash:Bool = false;
	public var stopStrumConfirm:Bool = false;

	override public function new(note:Note, ?direction:Int) {
		super();
		this.note = note;
		this.direction = direction == null ? note.ID : direction;
	}
}