package fnf.objects.note.groups;

class StrumGroup extends FlxTypedGroup<Strum> {
	public var extra:Map<String, Dynamic> = [];

	public var onHit:FlxTypedSignal<Dynamic->Void> = new FlxTypedSignal<Dynamic->Void>();
	public var onMiss:FlxTypedSignal<Dynamic->Void> = new FlxTypedSignal<Dynamic->Void>();
	public var notes:NoteGroup;
	public var splashes:SplashGroup;
	public var vocals:FlxSound;

	public function new(x:Float, y:Float, pixel:Bool = false) {
		super();
		var amount:Int = 4;
		for (i in 0...amount) {
			var babyArrow:Strum = new Strum(x - (Note.swagWidth / 2), y, i, pixel);
			babyArrow.x += Note.swagWidth * i;
			babyArrow.x -= (Note.swagWidth * ((amount - 1) / 2));
			if (SaveManager.getOption('prefs.strumShift')) babyArrow.x -= Note.swagWidth / 2.4;
			insert(i, babyArrow);
		}

		notes = new NoteGroup();
		splashes = new SplashGroup();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		notes.update(elapsed);
		splashes.update(elapsed);
	}

	private function drawNotes(allow:Bool) {
		for (note in notes) {
			if (note != null && note.exists && note.visible) {
				if (note.isSustainNote) {
					if (allow) {
						note.cameras = cameras;
						note.draw();
					}
				} else {
					note.cameras = cameras;
					note.draw();
				}
			}
		}
	}
	override public function draw() {
		var sustainsUnderStrums:Bool = SaveManager.getOption('prefs.sustainsUnderStrums');
		drawNotes(sustainsUnderStrums);
		super.draw();
		splashes.cameras = cameras;
		drawNotes(!sustainsUnderStrums);
		splashes.draw();
	}
}