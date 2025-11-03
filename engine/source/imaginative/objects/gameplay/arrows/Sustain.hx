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
	 * Returns the previous sustain in line.
	 * Unlike notes this goes through tail members, not field members.
	 */
	public var previousMember(get, never):Null<Sustain>;
	function get_previousMember():Null<Sustain> {
		setHead.tail.sort(Note.sortTail); // jic
		var index:Int = setHead.tail.indexOf(this) - 1;
		if (index < 0) return null;
		return setHead.tail[index];
	}
	/**
	 * Returns the next sustain in line.
	 * Unlike notes this goes through tail members, not field members.
	 */
	public var nextMember(get, never):Null<Sustain>;
	function get_nextMember():Null<Sustain> {
		setHead.tail.sort(Note.sortTail); // jic
		var index:Int = setHead.tail.indexOf(this) + 1;
		if (index > setHead.tail.length - 1) return null;
		return setHead.tail[index];
	}

	/**
	 * The field the sustain is assigned to.
	 */
	public var setField(get, set):ArrowField;
	inline function get_setField():ArrowField
		return setHead.setField;
	inline function set_setField(value:ArrowField):ArrowField
		return setHead.setField = value;
	/**
	 * The parent strum of this sustain.
	 */
	public var setStrum(get, never):Strum;
	inline function get_setStrum():Strum
		return setHead.setStrum;
	/**
	 * The parent note of this sustain.
	 */
	public var setHead(default, null):Note;

	/**
	 * The direction the sustains will come from.
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
	 * The lane index.
	 */
	public var id(get, set):Int;
	inline function get_id():Int
		return setHead.id;
	// TODO: Have it update the sustain skin on set once added.
	inline function set_id(value:Int):Int
		return setHead.id = value;

	// NOTE: As of rn this is actually in milliseconds!!!!!
	/**
	 * The sustain position in steps, is an offset of the parent's time.
	 */
	public var time:Float;
	/**
	 * States if this sustain piece is the tail end.
	 */
	public var isEnd(default, null):Bool;

	/**
	 * The scroll speed of this sustain.
	 */
	public var __scrollSpeed(get, never):Float;
	inline function get___scrollSpeed():Float
		return setHead.__scrollSpeed;

	/**
	 * Any characters in this array will overwrite the sustains parent field array.
	 * `May make it contain string instead.`
	 */
	public var assignedActors(get, set):Array<Character>;
	inline function get_assignedActors():Array<Character>
		return setHead.assignedActors;
	inline function set_assignedActors(value:Array<Character>):Array<Character>
		return setHead.assignedActors = value;
	/**
	 * Returns which characters will sing.
	 * @return Array<Character>
	 */
	inline public function renderActors():Array<Character>
		return setHead.renderActors();

	/**
	 * If true the sustain can be hit.
	 */
	public var canHit(get, never):Bool;
	inline function get_canHit():Bool {
		if (setField == null) return false;
		return (time + setHead.time) >= setField.conductor.time - setField.settings.maxWindow && (time + setHead.time) <= setField.conductor.time + setField.settings.maxWindow;
	}
	/**
	 * If true it's too late to hit the sustain.
	 */
	public var tooLate(get, never):Bool;
	inline function get_tooLate():Bool {
		if (setField == null) return false;
		return (time + setHead.time) < setField.conductor.time - (300 / Math.abs(__scrollSpeed)) && !wasHit;
	}
	/**
	 * If true this sustain has been hit.
	 */
	public var wasHit:Bool = false;
	/**
	 * If true this sustain has been missed.
	 */
	public var wasMissed:Bool = false;

	/**
	 * If true then this sustain is being rendered and can be seen in song.
	 */
	public var isBeingRendered(get, default):Bool = false;
	inline function get_isBeingRendered():Bool {
		if (setField == null) return false;
		if (!setField.activateNoteRendering)
			return false;
		return isBeingRendered;
	}

	/**
	 * The sustains modifiers.
	 */
	public var mods:ArrowModifier;

	override public function new(parent:Note, time:Float, end:Bool = false) {
		setHead = parent;
		this.time = time;
		isEnd = end;

		super(-10000, -10000);

		this.loadTexture('gameplay/arrows/funkin');
		var name:String = isEnd ? 'end' : 'hold';
		var dir:String = ['left', 'down', 'up', 'right'][id];
		animation.addByPrefix(name, '$dir note $name', 24, false);

		animation.play(name, true);
		scale.scale(ArrowField.arrowScale);
		updateHitbox();
		animation.play(name, true);
		updateHitbox();

		mods = new ArrowModifier(this);
		mods.alpha = 0.6;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (_update != null)
			_update(elapsed);
	}

	/**
	 * This function applies the base Y scaling to a sustain.
	 * `97 * 0.7 = 67.9` The math to get the perfect sustain scale.
	 * It is the perfect one btw, I tested with makeGraphic.
	 * Though for some skins it may look off.
	 * @param sustain The sustain to apply it to.
	 * @param mult The scale multiplier, you'd most likely put the scroll speed here.
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

	override public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('Time', setHead.time + time),
			LabelValuePair.weak('ID', id),
			LabelValuePair.weak('Was Hit', wasHit),
			LabelValuePair.weak('Was Missed', wasMissed),
			LabelValuePair.weak('Too Late', tooLate),
			LabelValuePair.weak('Tail Length', setHead.length),
			LabelValuePair.weak('Tail Count', setHead.tail.length)
		]);
	}
}