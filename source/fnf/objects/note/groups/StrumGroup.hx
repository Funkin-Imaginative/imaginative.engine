package fnf.objects.note.groups;

import flixel.util.FlxSignal.FlxTypedSignal;

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

typedef BaseNoteSignals = {
	var noteHit:FlxTypedSignal<Note->Void>;
	var noteMiss:FlxTypedSignal<(Note, Int)->Void>;
}
typedef NoteSignals = {
	> BaseNoteSignals,
	var noteSpawn:FlxTypedSignal<Note->Void>;
	var noteDestroy:FlxTypedSignal<Note->Void>;
	var splashSpawn:FlxTypedSignal<Void->Void>;
}

class StrumGroup extends FlxTypedGroup<Strum> {
	public var extra:Map<String, Dynamic> = [];

	// Even tho you can have a but ton of StrumGroup's you can ONLY play as one!
	public static function swapTargetGroups() {
		var prevOppo:StrumGroup = opponent;
		var prevPlay:StrumGroup = player;
		opponent = prevPlay;
		player = prevOppo;
	}
	public static var opponent:Null<StrumGroup> = null; // opponent play be like
	public static var player:Null<StrumGroup> = null;
	public var status(get, set):Null<Bool>;
	private function get_status():Null<Bool> {
		if (this == opponent) return false;
		if (this == player) return true;
		return null;
	}
	private function set_status(value:Null<Bool>):Null<Bool> {
		switch (value) {
			case false:
				if (opponent == player) swapTargetGroups();
				else opponent = this;
			case true:
				if (player == opponent) swapTargetGroups();
				else player = this;
			case null:
				var prevStatus:Null<Bool> = status; // jic
				if (prevStatus != null) prevStatus ? player = null : opponent = null;
		}
		return status;
	}

	public static var baseSignals(default, never):BaseNoteSignals = {
		noteHit: new FlxTypedSignal<Note->Void>(),
		noteMiss: new FlxTypedSignal<(Note, Int)->Void>()
	};
	public var signals(default, never):NoteSignals = {
		noteHit: new FlxTypedSignal<Note->Void>(),
		noteMiss: new FlxTypedSignal<(Note, Int)->Void>(),
		noteSpawn: new FlxTypedSignal<Note->Void>(),
		noteDestroy: new FlxTypedSignal<Note->Void>(),
		splashSpawn: new FlxTypedSignal<Void->Void>()
	};

	public var notes(default, null):NoteGroup;
	public var splashes(default, null):SplashGroup;
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
			@:privateAccess Strum.setStrumGroup(babyArrow, this);
			insert(i, babyArrow);
		}
		notes = new NoteGroup();
		splashes = new SplashGroup();
	}

	private function generateNotes(noteData:Array<SwagSection>) {
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3) gottaHitNote = !section.mustHitSection;

				if (status == gottaHitNote) {
					var oldNote:Note;
					if (notes.length > 0) oldNote = notes.members[Std.int(notes.length - 1)];
					else oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.altNote = songNotes[3];

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					notes.add(swagNote);
					@:bypassAccessor swagNote.strumGroup = this;

					for (susNote in 0...Math.floor(susLength)) {
						oldNote = notes.members[Std.int(notes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
						swagNote.tail.push(sustainNote);
						notes.add(sustainNote);
						@:bypassAccessor sustainNote.strumGroup = this;
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
			note.setPosition(members[note.ID].x + (note.isSustainNote ? members[note.ID].width / 2 : 0), (members[note.ID].y + (Conductor.songPosition - note.strumTime) * (0.45 * PlayState.SONG.speed)) + (note.isSustainNote ? (Note.swagWidth / 2) : 0) * note.downscrollMult);
		});

		var controls:Controls = PlayerSettings.player1.controls;
		var keys:KeySetupArray = {
			hold: [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT],
			press: [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P],
			release: [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R]
		};
		if (status != null && PlayUtil.opponentPlay == !status) {
			if ((keys.hold.contains(true) || PlayUtil.botplay) /* && !boyfriend.stunned */) {
				// trace('hit the fucking note you idiot');
				notes.forEachAlive(function(note:Note) {
					if (note.isSustainNote && note.canHit && keys.hold[note.ID])
						noteHit(note);
				});
			}

			if ((keys.press.contains(true) || PlayUtil.botplay) /* && !boyfriend.stunned */) {
				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later

				notes.forEachAlive(function(note:Note) {
					if (note.canHit && !note.tooLate && !note.wasHit) {
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

				for (note in dumbNotes) deleteNote(note);

				possibleNotes.sort(NoteGroup.noteSortFunc_ArrayVer);

				if (possibleNotes.length > 0) {
					for (shit in 0...keys.press.length)
						// if a direction is hit that shouldn't be
					for (deNote in possibleNotes) {
						if (keys.press[shit] && !directionList.contains(deNote.ID))
							noteMiss(deNote);
						if (keys.press[deNote.ID] || PlayUtil.botplay)
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
				if (key.press && strum.animation.name != 'confirm' && !PlayUtil.botplay)
					strum.playAnim('press');
				if (!key.hold) strum.playAnim('static');
			}
		}
	}

	public static function noteHit(note:Note) {
		if (!note.wasHit) {
			note.wasHit = true;
			// FlxG.state.noteHit(note);
			baseSignals.noteHit.dispatch(note);
			note.strumGroup.signals.noteHit.dispatch(note);
		}
	}
	public static function noteMiss(note:Note) {
		// FlxG.state.noteMiss(note);
		baseSignals.noteMiss.dispatch(note, note.ID);
		note.strumGroup.signals.noteMiss.dispatch(note, note.ID);
	}

	public function deleteNote(note:Note) {
		if (note == null) return;
		signals.noteDestroy.dispatch(note);
		note.kill();
		notes.remove(note, true);
		note.destroy();
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
		if (status) PlayUtil.botplay = false; // resets botplay
		splashes.destroy();
		notes.destroy();
		super.destroy();
	}
}