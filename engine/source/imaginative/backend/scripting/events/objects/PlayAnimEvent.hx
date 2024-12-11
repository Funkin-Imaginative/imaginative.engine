package imaginative.backend.scripting.events.objects;

// is extended for the note/sustain hit/missed events
class PlayAnimEvent extends ScriptEvent {
	/**
	 * The animation name.
	 */
	public var name:String;
	/**
	 * If true, the game won't care if another one is already playing.
	 */
	public var force:Bool = true;
	/**
	 * The context for the upcoming animation.
	 */
	public var context:AnimationContext = Unclear;
	/**
	 * The animation suffix.
	 */
	public var suffix:String;
	/**
	 * If true, the animation will play backwards.
	 */
	public var reverse:Bool = false;
	/**
	 * The starting frame. By default it's 0.
	 * Although if reversed it will use the last frame instead.
	 */
	public var frame:Int = 0;

	override public function new(name:String, force:Bool = true, context:AnimationContext = Unclear, ?suffix:String, reverse:Bool = false, frame:Int = 0) {
		super();
		this.name = name;
		this.force = force;
		this.context = context;
		this.reverse = reverse;
		this.frame = frame;
	}
}