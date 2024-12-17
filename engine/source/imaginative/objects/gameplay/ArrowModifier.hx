package imaginative.objects.gameplay;

typedef ArrowModHandler = {
	/**
	 * If true, the tied object will follow any parent like object it has ties with.
	 * Strum follows field, note follows strum and sustain follows note.
	 * Note that this system doesn't always apply.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var followLead:Bool;

	/**
	 * Applyers for x and y position individually.
	 * Setting either to false completely stops the note from following it's target strum.
	 * EFFCTS: Note, Sustain
	 */
	public var position:TypeXY<Bool>;
	/**
	 * Apply the scale multiplier?
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var scale:Bool;
	/**
	 * Apply the alpha multiplier?
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var alpha:Bool;

	/**
	 * If true, the speed var becomes a multiplier.
	 * If false, it is the direct speed.
	 */
	public var speedIsMult:Bool;
}

class ArrowModifier {
	// parent variables
	var strum(null, null):Strum;
	var note(null, null):Note;
	var sustain(null, null):Sustain;

	/**
	 * Handles what mods should be enabled.
	 */
	public var apply:ArrowModHandler = {
		followLead: true,
		position: new TypeXY<Bool>(true, true),
		scale: true,
		alpha: true,
		speedIsMult: true
	}

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
	public var angle:Float = 1;
	/**
	 * This is an alpha multiplier.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var alpha:Float = 1;
	/**
	 * This is an scroll speed variable.
	 * EFFCTS: Strum, Note, Sustain
	 */
	public var speed:Float = 1;

	public function new(?strum:Strum, ?note:Note, ?sustain:Sustain) {
		if ([strum == null, note == null, sustain == null].filter((nil:Bool) -> return !nil).length != 1)
			throw 'Only **one** parent is allowed.'; // mostly exists for scripters
		this.strum = strum;
		this.note = note;
		this.sustain = sustain;
	}

	// should probably do "set_" shit instead for this at some point
	@:allow(imaginative.objects.gameplay.Strum)
	@:allow(imaginative.objects.gameplay.Note)
	@:allow(imaginative.objects.gameplay.Sustain)
	function update(elapsed:Float):Void {
		if (strum != null) {
			if (apply.scale) {
				strum.scale.set( // 0.7 being base scale, which will be given a variable at some point
					0.7 * scale.x,
					0.7 * scale.y
				);
			}
			if (apply.alpha) {
				strum.alpha = (apply.followLead ? strum.setField.strums.alpha : 1) * alpha;
			}
		}
		if (note != null) {
			if (apply.scale) {
				note.scale.set(
					0.7 * scale.x,
					0.7 * scale.y
				);
			}
			if (apply.alpha)
				note.alpha = (apply.followLead ? note.setStrum.alpha : 1) * alpha;
		}
		if (sustain != null) {
			if (apply.scale) {
				sustain.scale.set(
					(apply.followLead ? sustain.setHead.scale.x : 0.7) * scale.x,
					(apply.followLead ? sustain.setHead.scale.y : 0.7) * scale.y
				);
				Sustain.applyBaseScaleY(sustain, Math.abs(sustain.__scrollSpeed)); // will be triggered on a "set_" at some point
			}
			if (apply.alpha)
				sustain.alpha = (apply.followLead ? sustain.setHead.alpha : 1) * alpha;
		}
	}
}