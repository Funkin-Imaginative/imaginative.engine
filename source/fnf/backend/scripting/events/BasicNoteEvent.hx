package fnf.backend.scripting.events;

import fnf.objects.note.Note;

final class BasicNoteEvent extends ScriptEvent {
	public var note:Note;
	public var splash:fnf.objects.note.Splash;

	override public function new(note:Note) {
		super();
		this.note = note;
	}
}