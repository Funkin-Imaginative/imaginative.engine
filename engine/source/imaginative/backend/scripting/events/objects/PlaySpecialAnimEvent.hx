package imaginative.backend.scripting.events.objects;

final class PlaySpecialAnimEvent extends ScriptEvent {
	/**
	 * The animation type.
	 */
	public var type(default, null):String;

	/**
	 * If true, the game won't care if another one is already playing.
	 */
	public var force:Bool = true;
	/**
	 * The context for the upcoming animation.
	 */
	public var context:AnimationContext = Unclear;
	/**
	 * If true, the animation will play backwards.
	 */
	public var reverse:Bool = false;
	/**
	 * The starting frame. By default it's 0.
	 * Although if reversed it will use the last frame instead.
	 */
	public var frame:Int = 0;

	public function new(type:String, force:Bool = true, context:AnimationContext = Unclear, reverse:Bool = false, frame:Int = 0) {
		super();
		this.type = type;
		this.force = force;
		this.context = context;
		this.reverse = reverse;
		this.frame = frame;
	}
}