package backend.scripting.events;

import objects.note.groups.StrumGroup;
import objects.note.Note;

final class NoteHitEvent extends ScriptEvent {
	public var note:Note;
	public var direction:Int;
	public var strumGroup:StrumGroup;
	public var showSplash:Bool = false;
	public var stopStrumConfirm:Bool = false;

	override public function new(note:Note, ?direction:Int, strumGroup:StrumGroup) {
		super();
		this.note = note;
		this.direction = direction == null ? note.data : direction;
		this.strumGroup = strumGroup == null ? note.strumGroup : strumGroup;
	}
}