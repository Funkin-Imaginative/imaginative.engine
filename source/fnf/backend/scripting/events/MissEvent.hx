package fnf.backend.scripting.events;

import fnf.objects.note.groups.StrumGroup;

final class MissEvent extends ScriptEvent {
	public var direction:Int;
	public var strumGroup:StrumGroup;

	override public function new(direction:Int, strumGroup:StrumGroup) {
		super();
		this.direction = direction;
		this.strumGroup = strumGroup;
	}
}