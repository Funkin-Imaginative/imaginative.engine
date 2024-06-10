package fnf.backend.scripting.events;

import fnf.objects.note.groups.StrumGroup;
import fnf.objects.note.Note;

final class NoteMissEvent extends ScriptEvent {
	public var note:Note;
	public var direction:Int;
	public var strumGroup:StrumGroup;

	override public function new(note:Note, ?direction:Int, strumGroup:StrumGroup) {
		super();
		this.note = note;
		this.direction = direction == null ? note.data : direction;
		this.strumGroup = strumGroup == null ? note.strumGroup : strumGroup;
	}
}