package fnf.backend.scripting.events;

import fnf.objects.Character.AnimType;

final class PlaySpecialAnimEvent extends ScriptEvent {
	@:unreflective /*lol*/ private var __animTypeName:String = '';
	public var animTypeName(get, never):String; private function get_animTypeName():String return __animTypeName;
	public var force:Bool = false;
	public var animType:AnimType = NONE;
	public var reverse:Bool = false;
	public var frame:Int = 0;

	public function new(animTypeName:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		super();
		__animTypeName = animTypeName;
		this.force = force;
		this.animType = animType;
		this.reverse = reverse;
		this.frame = frame;
	}
}