package imaginative.objects.gameplay.arrows.group;

class NoteGroup extends BeatTypedGroup<Note> {
	// NOTE: As of rn this is actually in milliseconds!!!!!
	/**
	 * The render distance for how far a note must be in a song to be rendered.
	 * If left null it does some automatic math in the get function.
	 */
	public var renderDistanceSteps:Null<Float> = null;
	/**
	 * Gets the final render distance for how far a note must be in a song to be rendered.
	 * @param note The note to get the scroll speed of.
	 * @return Float ~ The calculated distance.
	 */
	public function getRenderDistanceSteps(note:Note):Float {
		return renderDistanceSteps ?? FlxG.height / 0.45 / Math.min(note.__scrollSpeed, 1);
	}

	/**
	 * The field the note group is assigned to.
	 */
	public var setField(default, null):ArrowField;

	public function new(field:ArrowField) {
		setField = field;
		super();

		memberAdded.add((_:Note) -> members.sort(Note.sortNotes));
		memberRemoved.add((_:Note) -> members.sort(Note.sortNotes));
	}

	/**
	 * Applies a function to all rendered members.
	 * @param func A function that modifies one note at a time.
	 */
	public function forEachRendered(func:Note->Void):Void {
		forEachExists((note:Note) -> {
			note.isBeingRendered = false;
			if (!setField.activateNoteRendering) return;

			var shouldRender:Bool = true;
			if (note.time < note.setField.conductor.time - note.setField.settings.maxWindow) shouldRender = false;
			if (note.time > note.setField.conductor.time + getRenderDistanceSteps(note)) shouldRender = false;

			if (shouldRender) {
				note.isBeingRendered = true;
				func(note);
			}
		});
	}

	override public function update(elapsed:Float):Void {
		forEachRendered((note:Note) -> note.update(elapsed));
	}

	@:access(flixel.FlxCamera)
	override public function draw():Void {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null)
			FlxCamera._defaultCameras = _cameras;
		forEachRendered((note:Note) -> note.draw());
		FlxCamera._defaultCameras = oldDefaultCameras;
	}
}