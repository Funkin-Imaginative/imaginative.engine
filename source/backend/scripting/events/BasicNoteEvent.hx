package backend.scripting.events;

import objects.note.Note;

final class BasicNoteEvent extends ScriptEvent {
	public var note:Note;
	public var splash:objects.note.Splash;

	override public function new(note:Note) {
		super();
		this.note = note;
	}
}