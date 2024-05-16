package fnf.objects.note.groups;

private typedef KeySetupArray = {
	var hold:Array<Bool>;
	var press:Array<Bool>;
	var release:Array<Bool>;
}
private typedef KeySetup = {
	var hold:Bool;
	var press:Bool;
	var release:Bool;
}
private typedef BotplayTypedefShiz = {
	var p1:Bool;
	var p2:Bool; // only works in co-op
}

typedef NoteSignals = {
	var noteHit:FlxTypedSignal<Void->Void>;
	var noteMiss:FlxTypedSignal<Void->Void>;
	@:optional var noteSpawn:FlxTypedSignal<Void->Void>;
	@:optional var noteDestroy:FlxTypedSignal<Void->Void>;
	@:optional var splashSpawn:FlxTypedSignal<Void->Void>;
}

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

	public static var botplay(default, never):BotplayTypedefShiz = {p1: false, p2: false};
	@:isVar public static var botplayP1(get, set):Bool = false;
	private static function get_botplayP1():Bool return botplay.p1;
	private static function set_botplayP1(value:Bool):Bool return botplay.p1 = value;
	@:isVar public static var botplayP2(get, set):Bool = false;
	private static function get_botplayP2():Bool return botplay.p2;
	private static function set_botplayP2(value:Bool):Bool return botplay.p2 = value;

	/* @:unreflective */ private static var baseSignals(default, never):NoteSignals = {
		noteHit: new FlxTypedSignal<Void->Void>(),
		noteMiss: new FlxTypedSignal<Void->Void>()
	};
	public var signals(default, never):NoteSignals = {
		noteHit: new FlxTypedSignal<Void->Void>(),
		noteMiss: new FlxTypedSignal<Void->Void>(),
		noteSpawn: new FlxTypedSignal<Void->Void>(),
		noteDestroy: new FlxTypedSignal<Void->Void>(),
		splashSpawn: new FlxTypedSignal<Void->Void>()
	};

	public var notes:NoteGroup;
	public var splashes:SplashGroup;
	public var vocals:FlxSound;
	public var vocalsFinished:Bool = false;

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

	private function generateSong(noteData:Array<SwagSection>) {
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

		vocals = new FlxSound();

		notes.sortSelf();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		notes.update(elapsed);
		splashes.update(elapsed);

		notes.forEachAlive(function(note:Note) {
			note.setPosition((members[note.ID].width - note.width) / 2, (note.strumTime - Conductor.songPosition) * (0.45 * CoolUtil.quantize(PlayState.SONG.speed, 100)));
			if (note.isSustainNote) note.y += (Note.swagWidth / 2);
		});

		var controls:Controls = PlayerSettings.player1.controls;
		var keys:KeySetupArray = {
			hold: [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT],
			press: [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P],
			release: [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R]
		};
		if (getStatus()) {
			if ((keys.hold.contains(true) || botplayP1) /* && !boyfriend.stunned */) {
				notes.forEachAlive(function(note:Note) {
					if (note.isSustainNote && note.canBeHit && keys.hold[note.ID])
						noteHit(note);
				});
			}

			if ((keys.press.contains(true) || botplayP1) /* && !boyfriend.stunned */) {
				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later

				notes.forEachAlive(function(note:Note) {
					if (note.canBeHit && !note.tooLate && !note.wasGoodHit) {
						if (directionList.contains(note.ID)) {
							for (coolNote in possibleNotes) {
								if (coolNote.ID == note.ID && Math.abs(note.strumTime - coolNote.strumTime) < 10){
									// if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(note);
									break;
								} else if (coolNote.ID == note.ID && note.strumTime < coolNote.strumTime) {
									// if note is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(note);
									break;
								}
							}
						} else {
							possibleNotes.push(note);
							directionList.push(note.ID);
						}
					}
				});

				for (note in dumbNotes) {
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (possibleNotes.length > 0) {
					for (shit in 0...keys.press.length)
						// if a direction is hit that shouldn't be
					for (deNote in possibleNotes) {
						if (keys.press[shit] && !directionList.contains(deNote.ID))
							noteMiss(deNote);
						if (keys.press[deNote.ID] || botplayP1)
							noteHit(deNote);
					}
				} /* else
					for (shit in 0...keys.press.length)
						if (keys.press[shit])
							if (!SaveManager.getOption('gameplay.ghostTapping'))
								noteMiss(shit); */
			}

			for (index => strum in members) {
				var key:KeySetup = {hold: keys.hold[index], press: keys.press[index], release: keys.release[index]};
				if (strum.animation.name != 'confirm' && !botplayP1) {
					if (key.press) strum.playAnim('press');
					if (!key.hold) strum.playAnim('static');
				}
			}
		}
	}

	public static function noteHit(note:Note) {
		// FlxG.state.noteHit(note);
		baseSignals.noteHit.dispatch();
		note.strumGroup.signals.noteHit.dispatch();
	}
	public static function noteMiss(note:Note) {
		// FlxG.state.noteMiss(note);
		baseSignals.noteMiss.dispatch();
		note.strumGroup.signals.noteMiss.dispatch();
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

	override function destroy() {
		var status:Null<Bool> = getStatus();
		if (status != null)
			if (status) botplay.p1 = false;
			else botplay.p2 = false;

		splashes.destroy();
		notes.destroy();
		super.destroy();
	}
}