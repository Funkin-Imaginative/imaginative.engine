package imaginative.objects.gameplay;

class Strum extends FlxSprite {
	// Cool variables.
	/**
	 * Custom update function.
	 */
	public var _update:Float->Void;
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * The field the strum is assigned to.
	 */
	public var setField(default, null):ArrowField;

	// Strum specific variables.
	/**
	 * The strum lane index.
	 */
	public var id(default, null):Int;
	/**
	 * Its just id but with % applied.
	 */
	public var idMod(get, never):Int;
	inline function get_idMod():Int
		return id % setField.strumCount;

	// public var scrollSpeed:Float = 0;
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float
		return PlayState.chartData.speed;

	// public var scrollAngle:Float = 270;

	/**
	 * Used to help `glowLength`.
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The amount of time in steps the animation can be forced to last.
	 * If set to 0, the animation that is played, plays out normally.
	 */
	public var glowLength:Float = 4;

	/**
	 * If true, after the glowlength is reached the animation will go back to "static".
	 */
	public var willReset:Bool = false;

	@:allow(imaginative.objects.gameplay.ArrowField.new)
	override function new(field:ArrowField, id:Int) {
		setField = field;
		this.id = id;

		super();

		var dir:String = ['left', 'down', 'up', 'right'][idMod];

		this.loadTexture('gameplay/arrows/funkin');

		animation.addByPrefix('static', '$dir static', 24, false);
		animation.addByPrefix('press', '$dir press', 24, false);
		animation.addByPrefix('confirm', '$dir confirm start', 24, false);
		animation.addByPrefix('confirm-hold', '$dir confirm hold', 24);

		playAnim('static');
		scale.scale(0.7);
		updateHitbox();
		playAnim('static');
		updateHitbox();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (willReset && getAnimName() != 'static')
			if (glowLength > 0 ? (lastHit + (setField.conductor.stepTime * glowLength) < setField.conductor.time) : (getAnimName() == null || isAnimFinished()))
				playAnim(setField.isPlayer ? 'press' : 'static');
	}

	/**
	 * Play's an animation.
	 * @param name The animation name.
	 * @param reset If true, after the glowlength is reached the animation will go back to "static".
	 * @param force If true, the game won't care if another one is already playing.
	 * @param reverse If true, the animation will play backwards.
	 * @param frame The starting frame. By default it's 0.
	 *              Although if reversed it will use the last frame instead.
	 */
	public function playAnim(name:String, reset:Bool = false, force:Bool = true, reverse:Bool = false, frame:Int = 0):Void {
		if (animation.exists(name)) {
			animation.play(name, force, reverse, frame);
			centerOffsets();
			centerOrigin();
			if (reset)
				lastHit = setField.conductor.time;
			willReset = reset;
		}
	}

	/**
	 * Get's the name of the currently playing animation.
	 * The arguments are to reverse the name.
	 * @return `Null<String>` ~ The animation name.
	 */
	inline public function getAnimName():Null<String> {
		if (animation.name != null)
			return animation.name;
		return null;
	}
	/**
	 * Tells you if the animation has finished playing.
	 * @return `Bool`
	 */
	inline public function isAnimFinished():Bool {
		return (animation == null || animation.curAnim == null) ? false : animation.curAnim.finished;
	}
	/**
	 * When run, it forces the animation to finish.
	 */
	inline public function finishAnim():Void
		if (animation.curAnim != null)
			animation.curAnim.finish();
	/**
	 * Check's if the animation exists.
	 * @param name The animation name to check.
	 * @return `Bool` ~ If true, the animation exists.
	 */
	inline public function doesAnimExist(name:String/* , inGeneral:Bool */):Bool {
		return /* inGeneral ? */ animation.exists(name) /* : (animation.exists(name) && anims.exists(name)) */;
	}
}