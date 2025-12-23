package imaginative.objects.gameplay.arrows;

class Strum extends FlxSprite {
	// Cool variables.
	/**
	 * Custom update function.
	 */
	public var _update:Float->Void;

	/**
	 * The field the strum is assigned to.
	 */
	public final setField:ArrowField;

	// Strum specific variables.
	/**
	 * The lane index.
	 */
	public var id(default, set):Int;
	// TODO: Have it update the strum skin on set once added.
	inline function set_id(value:Int):Int
		return id = value;

	/**
	 * The scroll speed of this strum.
	 */
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float {
		return setField.settings.enablePersonalScrollSpeed ? setField.settings.personalScrollSpeed : (mods.handler.speedIsMult ? setField.getScrollSpeed() * mods.speed : mods.speed);
	}

	/**
	 * The direction the notes will come from.
	 * This offsets from the field speed.
	 */
	public var scrollAngle(default, set):Float = 0;
	@:access(imaginative.objects.gameplay.arrows.ArrowModifier.update_angle)
	inline function set_scrollAngle(value:Float):Float {
		scrollAngle = value;
		for (sustain in setField.sustains.members.copy().filter((sustain:Sustain) -> return sustain.id == id))
			sustain.mods.update_angle();
		return value;
	}

	/**
	 * Used to help "glowLength".
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The amount of time in steps the animation can be forced to last.
	 * If set to 0 the animation that is played plays out normally.
	 */
	public var glowLength:Float = 4;

	/**
	 * If true after the "glowlength" is reached the animation will go back to "static".
	 */
	public var willReset:Bool = false;

	/**
	 * The strums modifiers.
	 */
	public var mods:ArrowModifier;

	override public function new(field:ArrowField, id:Int) {
		setField = field;
		this.id = id;

		super();

		this.loadTexture('gameplay/arrows/funkin');
		var dir:String = ['left', 'down', 'up', 'right'][id];
		animation.addByPrefix('static', '$dir strum static', 24, false);
		animation.addByPrefix('press', '$dir strum press', 24, false);
		animation.addByPrefix('confirm', '$dir strum confirm', 24, false);
		animation.addByPrefix('confirm-end', '$dir strum hold confirm', 24, false);

		animation.onFinish.add((name:String) -> {
			if (doesAnimExist('$name-loop'))
				playAnim('$name-loop');
			if (!setField.isPlayer && name.endsWith('-end'))
				playAnim('static'); // simple fix for now possibly?
			else if (doesAnimExist('$name-end'))
				playAnim('$name-end');
		});

		scale.scale(ArrowField.arrowScale);
		playAnim('static');
		updateHitbox();

		mods = new ArrowModifier(this);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (willReset && getAnimName() != 'static')
			if (glowLength > 0 ? (lastHit + (setField.conductor.stepTime * glowLength) < setField.conductor.time) : (getAnimName() == null || isAnimFinished()))
				playAnim(setField.isPlayer ? 'press' : 'static');
	}

	/**
	 * Plays an animation.
	 * @param name The animation name.
	 * @param reset If true after the glowlength is reached the animation will go back to "static".
	 * @param force If true the game won't care if another one is already playing.
	 * @param reverse If true the animation will play backwards.
	 * @param frame The starting frame. By default it's 0, although if reversed it will use the last frame instead.
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
	 * Gets the name of the currently playing animation.
	 * The arguments are to reverse the name.
	 * @return Null<String> ~ The animation name.
	 */
	inline public function getAnimName():Null<String> {
		if (animation.name != null)
			return animation.name;
		return null;
	}
	/**
	 * Tells you if the animation has finished playing.
	 * @return Bool
	 */
	inline public function isAnimFinished():Bool
		return animation.finished;
	/**
	 * When ran it forces the animation to finish.
	 */
	inline public function finishAnim():Void
		animation.finished = true;
	/**
	 * Checks if the animation exists.
	 * @param name The animation name to check.
	 * @return Bool ~ If true the animation exists.
	 */
	inline public function doesAnimExist(name:String/* , inGeneral:Bool */):Bool {
		return /* inGeneral ? */ animation.exists(name) /* : (animation.exists(name) && anims.exists(name)) */;
	}
}