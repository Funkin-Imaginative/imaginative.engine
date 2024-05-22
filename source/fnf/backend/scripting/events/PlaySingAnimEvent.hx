package fnf.backend.scripting.events;

import fnf.objects.Character.AnimType;

final class PlaySingAnimEvent extends ScriptEvent {
	public var direction:Int;
	public var suffix:String = '';
	public var animType:AnimType = NONE;
	public var force:Bool = true;
	public var reverse:Bool = false;
	public var frame:Int = 0;

	public function new(direction:Int, suffix:String = '', animType:AnimType = SING, force:Bool = true, reverse:Bool = false, frame:Int = 0) {
		super();
		this.direction = direction;
		this.suffix = suffix;
		this.animType = animType;
		this.force = force;
		this.reverse = reverse;
		this.frame = frame;
	}
}