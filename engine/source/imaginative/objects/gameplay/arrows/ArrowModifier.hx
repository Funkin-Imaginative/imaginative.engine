package imaginative.objects.gameplay.arrows;

enum abstract ArrowModFollowType(String) from String to String {
	var FIELD;
	var STRUM;
	var NOTE;
	// var SUSTAIN; // useless, as the system can't go backwards
	var NONE = null;
}

@:access(imaginative.objects.gameplay.arrows.ArrowModifier)
class ArrowModHandler {
	var parent(null, null):ArrowModifier;

	/**
	 * States what object to follow.
	 * By default, Strum follows field, note follows strum and sustain follows note.
	 * Note that this system doesn't always apply. Also it can't go backwards, that would be a pain in the ass to deal with.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var followType(default, set):ArrowModFollowType;
	inline function set_followType(value:ArrowModFollowType):ArrowModFollowType {
		followType = value;
		try {
			parent.update_scale();
			parent.update_angle();
			parent.update_alpha();
		} catch(error:haxe.Exception) {}
		return followType;
	}

	/**
	 * Appliers for x and y position individually.
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

	public function new (parent:ArrowModifier, ?startFollowType:ArrowModFollowType) {
		this.parent = parent;
		followType = startFollowType;
	}
}

class ArrowModifier {
	// parent variables
	var strum(null, null):Strum;
	var note(null, null):Note;
	var sustain(null, null):Sustain;

	/**
	 * Handles what mods should be enabled.
	 */
	public var handler:ArrowModHandler;

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

		var startType:ArrowModFollowType = NONE;
		if (strum != null) startType = FIELD;
		if (note != null) startType = STRUM;
		if (sustain != null) startType = NOTE;
		handler = new ArrowModHandler(this, startType);
	}

	function update_scale():Void {
		if (handler.scale) {
			if (strum != null) {
				var followScale:Array<Float> = switch (handler.followType) {
					case FIELD: [strum.setField.scale.x, strum.setField.scale.y];
					default: [1, 1];
				}
				strum.scale.set( // 0.7 being base scale, which might be given a variable at some point
					0.7 * followScale[0] * scale.x,
					0.7 * followScale[1] * scale.y
				);
				for (note in strum.setField.notes.members.copy().filter((note:Note) -> return note.id == strum.id))
					note.mods.update_scale();
			}
			if (note != null) {
				var followScale:Array<Float> = switch (handler.followType) {
					case FIELD: [0.7 * note.setField.scale.x, 0.7 * note.setField.scale.y];
					case STRUM: [note.setStrum.scale.x, note.setStrum.scale.y];
					default: [0.7, 0.7];
				}
				note.scale.set(
					followScale[0] * scale.x,
					followScale[1] * scale.y
				);
				for (sustain in note.tail)
					sustain.mods.update_scale();
			}
			if (sustain != null) {
				var followScale:Array<Float> = switch (handler.followType) {
					case FIELD: [0.7 * sustain.setField.scale.x, 0.7 * sustain.setField.scale.y];
					case STRUM: [sustain.setStrum.scale.x, sustain.setStrum.scale.y];
					case NOTE: [sustain.setHead.scale.x, sustain.setHead.scale.y];
					default: [0.7, 0.7];
				}
				sustain.scale.set(
					followScale[0] * scale.x,
					followScale[1] * scale.y
				);
				Sustain.applyBaseScaleY(sustain, Math.abs(sustain.__scrollSpeed));
			}
		}
	}

	function update_angle():Void {
		if (handler.angle) {
			if (strum != null) {
				var followAngle:Float = switch (handler.followType) {
					case FIELD: strum.setField.strums.angle;
					default: 0;
				}
				strum.angle = followAngle + angle;
				for (note in strum.setField.notes.members.copy().filter((note:Note) -> return note.id == strum.id))
					note.mods.update_angle();
			}
			if (note != null) {
				var followAngle:Float = switch (handler.followType) {
					case FIELD: note.setField.strums.angle;
					case STRUM: note.setStrum.angle;
					default: 0;
				}
				note.angle = followAngle + angle;
			}
			// doesn't follow specific object, plus it's probably better this way
			if (sustain != null)
				sustain.angle = sustain.setField.scrollAngle + sustain.setStrum.scrollAngle + sustain.setHead.scrollAngle + sustain.scrollAngle + 90 + angle;
		}
	}

	function update_alpha():Void {
		if (handler.alpha) {
			if (strum != null) {
				var followAlpha:Float = switch (handler.followType) {
					case FIELD: strum.setField.alpha;
					default: 1;
				}
				strum.alpha = followAlpha * alpha;
				for (note in strum.setField.notes.members.copy().filter((note:Note) -> return note.id == strum.id))
					note.mods.update_alpha();
			}
			if (note != null) {
				var followAlpha:Float = switch (handler.followType) {
					case FIELD: note.setField.alpha;
					case STRUM: note.setStrum.alpha;
					default: 1;
				}
				note.alpha = followAlpha * alpha;
				for (sustain in note.tail)
					sustain.mods.update_alpha();
			}
			if (sustain != null) {
				var followAlpha:Float = switch (handler.followType) {
					case FIELD: sustain.setField.alpha;
					case STRUM: sustain.setStrum.alpha;
					case NOTE: sustain.setHead.alpha;
					default: 1;
				}
				sustain.alpha = followAlpha * alpha;
			}
		}
	}
}