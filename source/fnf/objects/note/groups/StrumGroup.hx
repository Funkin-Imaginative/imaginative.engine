package fnf.objects.note.groups;

class StrumGroup extends FlxTypedGroup<Strum> {
	public var extra:Map<String, Dynamic> = [];

	// Even tho you can have a but ton of StrumGroup's you can ONLY play as one!
	public static var opponent:StrumGroup;
	public static var player:StrumGroup;
	public inline function getStatus():Null<Bool> {
		if (this == opponent) return false;
		if (this == player) return true;
		return null;
	}

	// public static var botplay:Bool = false;

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

	public function generateSong(noteData:Array<SwagSection>) {
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3) gottaHitNote = !section.mustHitSection;

				if (getStatus() == gottaHitNote) {
					var oldNote:Note;
					if (notes.length > 0) oldNote = notes.members[Std.int(notes.length - 1)];
					else oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.altNote = songNotes[3];

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					notes.add(swagNote);

					for (susNote in 0...Math.floor(susLength)) {
						oldNote = notes.members[Std.int(notes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
						swagNote.tail.push(sustainNote);
						notes.add(sustainNote);
					}
				}
			}
		}

		notes.sortSelf();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		notes.update(elapsed);
		splashes.update(elapsed);
	}

	private function drawNotes(drawNote:Bool, drawSustain:Bool) {
		for (note in notes) {
			if (note != null && note.exists && note.visible) {
				if (note.isSustainNote ? drawSustain : drawNote) {
					note.cameras = cameras;
					note.draw();
				}
			}
		}
	}
	override public function draw() {
		var sustainsUnderStrums:Bool = SaveManager.getOption('prefs.sustainsUnderStrums');
		drawNotes(false, sustainsUnderStrums);
		super.draw();
		drawNotes(true, !sustainsUnderStrums);
		splashes.cameras = cameras;
		splashes.draw();
	}
}