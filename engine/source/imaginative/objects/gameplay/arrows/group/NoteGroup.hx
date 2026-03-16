package imaginative.objects.gameplay.arrows.group;

class NoteGroup extends FlxTypedGroup<Note> {
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
		if (renderDistanceSteps != null) return renderDistanceSteps * note.getDefaultCamera().zoom * 1000;
		return note.getDefaultCamera().height / note.getDefaultCamera().zoom / 0.45 / Math.min(note.scrollSpeed, 1);
	}

	/**
	 * The field the note group is assigned to.
	 */
	public var setField(get, never):ArrowField;
	inline function get_setField():ArrowField
		return parentStrumGroup.setField;
	/**
	 * The parent strum group the notes members come from.
	 */
	public var parentStrumGroup(default, null):StrumGroup;

	override public function new(strums:StrumGroup) {
		parentStrumGroup = strums;
		super();
	}

	/**
	 * Applies a function to all rendered members.
	 * @param func A function that modifies one note at a time.
	 */
	public function forEachRendered(func:Note->Void):Void {
		members.sort(Note.sortNotes);
		var shouldRender:Bool = true;
		forEachExists((note:Note) -> {
			note.isBeingRendered = false;
			if (!setField.activateNoteRendering) return;

			shouldRender = true;
			if ((note.time + note.length) < setField.conductor.time - setField.settings.maxWindow) shouldRender = false;
			if (note.time > setField.conductor.time + getRenderDistanceSteps(note)) shouldRender = false;

			if (shouldRender) {
				note.isBeingRendered = true;
				func(note);
			}
		});
	}

	override public function update(elapsed:Float):Void {
		forEachRendered(
			(note:Note) ->
				if (note.visible)
					note.update(elapsed)
		);
	}

	@:access(flixel.FlxCamera)
	override public function draw():Void {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null) FlxCamera._defaultCameras = _cameras;
		forEachRendered(
			(note:Note) ->
				if (note.visible)
					note.draw()
		);
		FlxCamera._defaultCameras = oldDefaultCameras;
	}
}