package imaginative.objects.gameplay;

@:access(imaginative.objects.gameplay.ArrowModifier)
class ArrowModHandler {
	var parent(null, null):ArrowModifier;

	/**
	 * If true, the tied object will follow any parent like object it has ties with.
	 * Strum follows field, note follows strum and sustain follows note.
	 * Note that this system doesn't always apply.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var followLead(default, set):Bool = true;
	inline function set_followLead(value:Bool):Bool {
		followLead = value;
		parent.update_scale();
		parent.update_angle();
		parent.update_alpha();
		return followLead;
	}

	/**
	 * Applyers for x and y position individually.
	 * Setting either to false completely stops the note from following it's target strum.
	 * EFFCTS: Note, Sustain
	 */
	public var position:TypeXY<Bool> = new TypeXY<Bool>(true, true);
	/**
	 * Apply the scale multiplier?
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var scale(default, set):Bool = true;
	inline function set_scale(value:Bool):Bool {
		scale = value;
		parent.update_scale();
		return scale;
	}
	/**
	 * This is an angle offset.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var angle(default, set):Bool = true;
	inline function set_angle(value:Bool):Bool {
		angle = value;
		parent.update_angle();
		return angle;
	}
	/**
	 * Apply the alpha multiplier?
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var alpha:Bool = true;
	inline function set_alpha(value:Bool):Bool {
		alpha = value;
		parent.update_alpha();
		return alpha;
	}

	/**
	 * If true, the speed var becomes a multiplier.
	 * If false, it is the direct speed.
	 */
	public var speedIsMult:Bool = true;
	inline function set_speedIsMult(value:Bool):Bool {
		speedIsMult = value;
		parent.update_scale();
		return speedIsMult;
	}

	public function new (parent:ArrowModifier)
		this.parent = parent;
}

class ArrowModifier {
	// parent variables
	var strum(null, null):Strum;
	var note(null, null):Note;
	var sustain(null, null):Sustain;

	/**
	 * Handles what mods should be enabled.
	 */
	public var apply:ArrowModHandler;

	// arrow mods
	/**
	 * This is a position offset.
	 * EFFCTS: Note, Sustain
	 */
	public var offset:Position = new Position();
	/**
	 * This is a scale multiplier.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var scale:Position = new Position(1, 1);
	/**
	 * This is an angle offset.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var angle(default, set):Float = 0;
	inline function set_angle(value:Float):Float {
		angle = value;
		update_angle();
		return angle;
	}
	/**
	 * This is an alpha multiplier.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var alpha(default, set):Float = 1;
	inline function set_alpha(value:Float):Float {
		alpha = value;
		update_alpha();
		return alpha;
	}
	/**
	 * This is an scroll speed variable.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var speed(default, set):Float = 1;
	inline function set_speed(value:Float):Float {
		speed = value;
		update_scale();
		return speed;
	}

	public function new(?strum:Strum, ?note:Note, ?sustain:Sustain) {
		if ([strum == null, note == null, sustain == null].filter((nil:Bool) -> return !nil).length != 1)
			throw 'Only **one** parent is allowed.'; // mostly exists for scripters

		this.strum = strum;
		this.note = note;
		this.sustain = sustain;

		scale.set_x = (value:Float) -> {
			scale.x = value;
			update_scale();
			return scale.x;
		}
		scale.set_y = (value:Float) -> {
			scale.y = value;
			update_scale();
			return scale.y;
		}

		apply = new ArrowModHandler(this);
	}

	function update_scale():Void {
		if (strum != null) {
			if (apply.scale) {
				strum.scale.set( // 0.7 being base scale, which will be given a variable at some point
					(apply.followLead ? strum.setField.strums.scale.x : 0.7) * scale.x,
					(apply.followLead ? strum.setField.strums.scale.y : 0.7) * scale.y
				);
				for (note in strum.setField.notes)
					note.mods.update_scale();
			}
		}
		if (note != null) {
			if (apply.scale) {
				note.scale.set( // not sure how to do this rn
					(apply.followLead ? note.setStrum.scale.x : 0.7) * scale.x,
					(apply.followLead ? note.setStrum.scale.y : 0.7) * scale.y
				);
				for (sustain in note.tail)
					sustain.mods.update_scale();
			}
		}
		if (sustain != null) {
			if (apply.scale) {
				sustain.scale.set(
					(apply.followLead ? sustain.setHead.scale.x : 0.7) * scale.x,
					(apply.followLead ? sustain.setHead.scale.y : 0.7) * scale.y
				);
				Sustain.applyBaseScaleY(sustain, Math.abs(sustain.__scrollSpeed));
			}
		}
	}

	function update_angle():Void {
		if (strum != null) {
			if (apply.angle)
				strum.angle = apply.followLead ? strum.setField.strums.angle + angle : angle;
			for (note in strum.setField.notes)
				note.mods.update_angle();
		}
		if (note != null) {
			if (apply.angle)
				note.angle = apply.followLead ? note.setStrum.angle + angle : angle;
			/* for (sustain in note.tail)
				sustain.mods.update_angle(); */
		}
		/* if (sustain != null) {
			if (apply.angle)
				sustain.angle = apply.followLead ? sustain.setStrum.angle + angle : angle;
		} */
	}

	function update_alpha():Void {
		if (strum != null) {
			if (apply.alpha)
				strum.alpha = (apply.followLead ? strum.setField.strums.alpha : 1) * alpha;
			for (note in strum.setField.notes)
				note.mods.update_alpha();
		}
		if (note != null) {
			if (apply.alpha)
				note.alpha = (apply.followLead ? note.setStrum.alpha : 1) * alpha;
			for (sustain in note.tail)
				sustain.mods.update_alpha();
		}
		if (sustain != null) {
			if (apply.alpha)
				sustain.alpha = (apply.followLead ? sustain.setHead.alpha : 1) * alpha;
		}
	}
}