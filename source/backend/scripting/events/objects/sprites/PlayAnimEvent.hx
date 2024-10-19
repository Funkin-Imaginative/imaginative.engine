package backend.scripting.events.objects.sprites;

final class PlayAnimEvent extends ScriptEvent {
	public var anim:String;
	public var force:Bool = false;
	public var animContext:AnimContext = Unclear;
	public var reverse:Bool = false;
	public var frame:Int = 0;

	public function new(anim:String, force:Bool = false, animContext:AnimContext = Unclear, reverse:Bool = false, frame:Int = 0) {
		super();
		this.anim = anim;
		this.force = force;
		this.animContext = animContext;
		this.reverse = reverse;
		this.frame = frame;
	}
}