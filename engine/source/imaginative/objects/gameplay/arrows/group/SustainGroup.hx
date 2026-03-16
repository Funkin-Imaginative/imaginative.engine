package imaginative.objects.gameplay.arrows.group;

class SustainGroup extends FlxTypedGroup<Sustain> {
	/**
	 * The field the sustain group is assigned to.
	 */
	public var setField(get, never):ArrowField;
	inline function get_setField():ArrowField
		return parentNoteGroup.setField;
	/**
	 * The parent note group the sustain members come from.
	 */
	public var parentNoteGroup(default, null):NoteGroup;

	override public function new(notes:NoteGroup) {
		parentNoteGroup = notes;
		super();
	}

	/**
	 * Applies a function to all rendered members.
	 * @param func A function that modifies one sustain at a time.
	 */
	public function forEachRendered(func:Sustain->Void):Void {
		members.sort(Note.sortTail);
		forEachExists((sustain:Sustain) -> {
			sustain.isBeingRendered = false;
			if (!setField.activateNoteRendering) return;
			if (sustain.setHead.isBeingRendered) {
				sustain.isBeingRendered = true;
				func(sustain);
			}
		});
	}

	override public function update(elapsed:Float):Void {
		forEachRendered(
			(sustain:Sustain) ->
				if (sustain.visible)
					sustain.update(elapsed)
		);
	}

	@:access(flixel.FlxCamera)
	override public function draw():Void {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null) FlxCamera._defaultCameras = _cameras;
		forEachRendered(
			(sustain:Sustain) ->
				if (sustain.visible)
					sustain.draw()
		);
		FlxCamera._defaultCameras = oldDefaultCameras;
	}
}