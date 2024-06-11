package fnf.backend.scripting.events;

import fnf.objects.FunkinSprite.AnimType;

final class PlayAnimEvent extends ScriptEvent {
	public var anim:String;
	public var force:Bool = false;
	public var animType:AnimType = NONE;
	public var reverse:Bool = false;
	public var frame:Int = 0;

	public function new(anim:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		super();
		this.anim = anim;
		this.force = force;
		this.animType = animType;
		this.reverse = reverse;
		this.frame = frame;
	}
}