package imaginative.objects.gameplay.arrows.group;

class SustainGroup extends BeatTypedGroup<Sustain> {
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

	public function new(notes:NoteGroup) {
		parentNoteGroup = notes;
		super();

		memberAdded.add((_:Sustain) -> members.sort(Note.sortTail));
		memberRemoved.add((_:Sustain) -> members.sort(Note.sortTail));
	}

	/**
	 * Applies a function to all rendered members.
	 * @param func A function that modifies one sustain at a time.
	 */
	public function forEachRendered(func:Sustain->Void):Void {
		var renderedSustains:Array<Sustain> = [];
		forEachExists((sustain:Sustain) -> {
			sustain.isBeingRendered = false;
			if (!setField.activateNoteRendering) return;

			var shouldRender:Bool = true;
			if ((sustain.setHead.time + sustain.time) < sustain.setField.conductor.time - sustain.setField.settings.maxWindow) shouldRender = false;
			if ((sustain.setHead.time + sustain.time) > sustain.setField.conductor.time + parentNoteGroup.getRenderDistanceSteps(sustain.setHead)) shouldRender = false;

			if (shouldRender) {
				sustain.isBeingRendered = true;
				renderedSustains.push(sustain);
			}
		});
		renderedSustains.sort(Note.sortTail);
		for (sustain in renderedSustains)
			if (sustain.isBeingRendered)
				func(sustain);
		renderedSustains.clearArray();
	}

	override public function update(elapsed:Float):Void {
		forEachRendered(
			(sustain:Sustain) ->
				sustain.update(elapsed)
		);
	}

	@:access(flixel.FlxCamera)
	override public function draw():Void {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null)
			FlxCamera._defaultCameras = _cameras;
		forEachRendered(
			(sustain:Sustain) ->
				if (sustain.visible)
					sustain.draw()
		);
		FlxCamera._defaultCameras = oldDefaultCameras;
	}
}