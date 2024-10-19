package backend.scripting.events.objects.sprites;

final class PlaySpecialAnimEvent extends ScriptEvent {
	var __animTypeName:String = '';
	public var animTypeName(get, never):String;
	inline function get_animTypeName():String return __animTypeName;

	public var force:Bool = false;
	public var animContext:AnimContext = Unclear;
	public var reverse:Bool = false;
	public var frame:Int = 0;

	public function new(animTypeName:String, force:Bool = false, animContext:AnimContext = Unclear, reverse:Bool = false, frame:Int = 0) {
		super();
		__animTypeName = animTypeName;
		this.force = force;
		this.animContext = animContext;
		this.reverse = reverse;
		this.frame = frame;
	}
}