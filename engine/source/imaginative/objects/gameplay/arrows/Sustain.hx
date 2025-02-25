package imaginative.objects.gameplay.arrows;

class Sustain extends FlxSprite {
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
	 * The field the sustain is assigned to.
	 */
	public var setField(get, never):ArrowField;
	inline function get_setField():ArrowField
		return setHead.setField;
	/**
	 * The parent strum of this note.
	 */
	public var setStrum(get, null):Strum;
	inline function get_setStrum():Strum
		return setHead.setStrum;
	/**
	 * The parent note of this sustain.
	 */
	public var setHead(default, null):Note;

	/**
	 * The direction the notes will come from.
	 * This offsets from the parent note speed.
	 */
	public var scrollAngle(default, set):Float = 0;
	@:access(imaginative.objects.gameplay.arrows.ArrowModifier.update_angle)
	inline function set_scrollAngle(value:Float):Float {
		scrollAngle = value;
		mods.update_angle();
		return value;
	}

	/**
	 * The strum lane index.
	 */
	public var id(get, never):Int;
	inline function get_id():Int
		return setHead.id;
	/**
	 * Its just id but with % applied.
	 */
	public var idMod(get, never):Int;
	inline function get_idMod():Int
		return id % setField.strumCount;

	/**
	 * NOTE: As of rn this is actually in milliseconds!!!!!
	 * The sustain position in steps, is an offset of the parent's time.
	 */
	public var time:Float;
	/**
	 * States if this sustain piece is the tail end.
	 */
	public var isEnd(default, null):Bool;

	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float {
		return setField.settings.enablePersonalScrollSpeed ? setField.settings.personalScrollSpeed : (mods.handler.speedIsMult ? setHead.__scrollSpeed * mods.speed : mods.speed);
	}

	/**
	 * Any characters in this array will overwrite the sustains parent field array.
	 * `May make it contain string instead.`
	 */
	public var assignedActors(get, set):Array<Character>;
	inline function get_assignedActors():Array<Character>
		return setHead.assignedActors;
	inline function set_assignedActors(value:Array<Character>):Array<Character>
		return setHead.assignedActors = value;
	inline public function renderActors():Array<Character>
		return setHead.renderActors();

	public var canHit(get, never):Bool;
	inline function get_canHit():Bool {
		return (time + setHead.time) >= setField.conductor.time - Settings.setupP1.maxWindow && (time + setHead.time) <= setField.conductor.time + Settings.setupP1.maxWindow;
	}
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		return (time + setHead.time) < setField.conductor.time - (300 / Math.abs(__scrollSpeed)) && !wasHit;
	}
	public var wasHit:Bool = false;
	public var wasMissed:Bool = false;

	public var canDie:Bool = false;

	public var mods:ArrowModifier;

	override public function new(parent:Note, time:Float, end:Bool = false) {
		setHead = parent;
		this.time = time;
		isEnd = end;

		super(setHead.x, setHead.y);

		var name:String = isEnd ? 'end' : 'hold';
		var dir:String = ['left', 'down', 'up', 'right'][idMod];
		this.loadTexture('gameplay/arrows/funkin');
		animation.addByPrefix(name, '$dir note $name', 24, false);

		animation.play(name, true);
		scale.scale(0.7);
		updateHitbox();
		animation.play(name, true);
		updateHitbox();

		mods = new ArrowModifier(this);
		mods.alpha = 0.6;
	}

	/**
	 * This function applies the base Y scaling to a sustain.
	 * `97 * 0.7 = 67.9` The math to get the perfect sustain scale.
	 * It is the perfect one btw, I tested with makeGraphic.
	 * Though for some skins it may look off.
	 * @param sustain The sustain to apply it to.
	 * @param mult The scale multiplier.
	 *             You'd most likely put the scroll speed here.
	 */
	inline public static function applyBaseScaleY(sustain:Sustain, mult:Float = 1):Void {
		// prevent scaling on sustain end
		if (sustain.isEnd) return;

		// setGraphicSize
		sustain.scale.y = (67.9 / sustain.frameHeight) * mult;

		// updateHitbox
		sustain.height = Math.abs(sustain.scale.y) * sustain.frameHeight;
		sustain.offset.y = -0.5 * (sustain.height - sustain.frameHeight);

		// centerOrigin
		sustain.origin.y = sustain.frameHeight * 0.5;
	}
}