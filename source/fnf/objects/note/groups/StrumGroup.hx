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
	var noteHit:FlxTypedSignal<NoteHitEvent->Void>;
	var noteMiss:FlxTypedSignal<NoteMissEvent->Void>;
}
typedef NoteSignals = {
	> BaseNoteSignals,
	var noteSpawn:FlxTypedSignal<BasicNoteEvent->Void>;
	var noteDestroy:FlxTypedSignal<BasicNoteEvent->Void>;
	var splashSpawn:FlxTypedSignal<SplashSpawnEvent->Void>;
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

	public var __helper:Null<Bool> = null;
	public var helper(get, set):Null<Bool>;
	private function get_helper():Null<Bool> return status == null ? __helper : status;
	private function set_helper(value:Null<Bool>):Null<Bool> return __helper = value;
	public function helperConvert(value:Float):Float {
		if (helper == null) return 0;
		else return value * (helper ? 1 : -1);
	}

	public static var baseSignals(default, never):BaseNoteSignals = {
		noteHit: new FlxTypedSignal<NoteHitEvent->Void>(),
		noteMiss: new FlxTypedSignal<NoteMissEvent->Void>()
	}
	public var signals(default, never):NoteSignals = {
		noteHit: new FlxTypedSignal<NoteHitEvent->Void>(),
		noteMiss: new FlxTypedSignal<NoteMissEvent->Void>(),
		noteSpawn: new FlxTypedSignal<BasicNoteEvent->Void>(),
		noteDestroy: new FlxTypedSignal<BasicNoteEvent->Void>(),
		splashSpawn: new FlxTypedSignal<SplashSpawnEvent->Void>()
	}

	public var notes(default, null):NoteGroup;
	public var splashes(default, null):SplashGroup;
	// public var holdCovers(default, null):FlxTypedGroup<HoldCover>;
	public var vocals:FlxSound;
	public var vocalsFinished:Bool = false;
	public var character:Character;

	public function new(x:Float, y:Float, pixel:Bool = false, amount:Int = 4) {
		super();
		for (i in 0...amount) {
			var babyArrow:Strum = new Strum(x - (Note.swagWidth / 2), y, i, pixel);
			babyArrow.x += Note.swagWidth * i;
			babyArrow.x -= (Note.swagWidth * ((amount - 1) / 2));
			@:privateAccess Strum.setStrumGroup(babyArrow, this);
			if (SaveManager.getOption('prefs.strumShift')) babyArrow.x -= Note.swagWidth / 2.4;
			insert(i, babyArrow);
		}
		notes = new NoteGroup();
		splashes = new SplashGroup();
		// holdCovers = new FlxTypedGroup<HoldCover>();
	}

	private function generateNotes(noteData:Array<SwagSection>) {
		var oldNote:Note;
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3) gottaHitNote = !section.mustHitSection;

				if (status == gottaHitNote) {
					oldNote = notes.length > 0 ? notes.members[notes.length - 1] : null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, NOTE);

					swagNote.sustainLength = songNotes[2];
					swagNote.altNote = songNotes[3];

					var susLength:Float = swagNote.sustainLength;
					susLength = susLength / Conductor.stepCrochet;

					for (susNote in 0...Math.floor(susLength)) {
						oldNote = notes.members[notes.length - 1];
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, susNote == Math.floor(susLength) ? END : HOLD);
						(sustainNote.parent = swagNote).tail.push(sustainNote);
						@:bypassAccessor sustainNote.strumGroup = this;
						notes.add(sustainNote);
					}
					@:bypassAccessor swagNote.strumGroup = this;
					notes.add(swagNote);
				}
			}
		}

		var vocalsPath:String = Paths.voices(PlayState.SONG.song, status ? 'Player' : 'Opponent');
		vocals = FileSystem.exists(vocalsPath) ? FlxG.sound.load(vocalsPath) : new FlxSound();

		vocals.group = FlxG.sound.defaultMusicGroup;
		vocals.persist = false;

		notes.sortSelf();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		notes.update(elapsed);
		// holdCovers.update(elapsed);
		splashes.update(elapsed);

		notes.forEachAlive(function(note:Note) {
			if ((note.tooLate || note.wasHit) && !note.isOnScreen()) deleteNote(note);
			if (note.willDraw) {
				var angleDir:Float = Math.PI / 180;
				if (note.isSustain) {
					var scrollAngle:Float = note.parent.scrollAngle + note.scrollAngle;
					angleDir = scrollAngle * angleDir;
					note.angle = scrollAngle - 90;
				} else {
					angleDir = note.scrollAngle * angleDir;
					note.angle = note.parentStrum.angle;
				}
				note.setPosition(note.parentStrum.x - (note.isSustain ? (note.width / 2) : 0) + (note.isSustain ? (Note.swagWidth / 2) : 0), note.parentStrum.y - (((Conductor.songPosition - note.strumTime) * (0.45 * note.__scrollSpeed) + (note.isSustain ? (Note.swagWidth / 2) : 0)) * (SaveManager.getOption('gameplay.downscroll') ? -1 : 1)));
			}
		});

		var controls:Controls = PlayerSettings.player1.controls;
		var keys:KeySetupArray = {
			hold: [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT],
			press: [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P],
			release: [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R]
		}
		if (status != null && status == !PlayUtil.opponentPlay && !PlayUtil.botplay) {
			if (keys.hold.contains(true) /* && !boyfriend.stunned */) {
				// trace('hit the fucking note you idiot');
				notes.forEachAlive(function(note:Note) {
					if (note.isSustain && note.canHit && keys.hold[note.ID])
						PlayField.noteHit(note, this);
				});
			}

			if (keys.press.contains(true) /* && !boyfriend.stunned */) {
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

				possibleNotes.sort(NoteGroup.noteSortArray);

				if (possibleNotes.length > 0) {
					for (deNote in possibleNotes) {
						for (shit in 0...keys.press.length) // if a direction is hit that shouldn't be
							if (keys.press[shit] && !directionList.contains(deNote.ID))
								PlayField.noteMiss(deNote, deNote.ID, this);
						if (keys.press[deNote.ID])
							PlayField.noteHit(deNote, this);
					}
				} else
					for (shit in 0...keys.press.length)
						if (!SaveManager.getOption('gameplay.ghostTapping') && keys.press[shit])
							PlayField.noteMiss(null, shit, this);
			}

			for (index => strum in members) {
				var key:KeySetup = {hold: keys.hold[index], press: keys.press[index], release: keys.release[index]}
				if (key.press && strum.animation.name != 'confirm') strum.playAnim('press');
				if (!key.hold) strum.playAnim('static');
			}
		} else {
			notes.forEachAlive(function(note:Note) {
				if (note.strumTime <= Conductor.songPosition)
					if (note.forceMiss) PlayField.noteMiss(note, note.ID, this);
					else PlayField.noteHit(note, this);
			});
		}
	}

	public function deleteNote(note:Note) {
		if (note == null) return;
		signals.noteDestroy.dispatch(new BasicNoteEvent(note));
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	private function drawNotes(drawNote:Bool, drawSustain:Bool) {
		for (note in notes) {
			if (note != null && note.exists && note.visible) {
				if (drawSustain && note.isSustain) {
					note.cameras = cameras;
					note.draw();
				}
				if (drawNote && !note.isSustain) {
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
		// holdCovers.cameras = cameras;
		// holdCovers.draw();
		splashes.cameras = cameras;
		splashes.draw();
	}

	override function destroy() {
		if (status) PlayUtil.botplay = false; // resets botplay
		// holdCovers.destroy();
		splashes.destroy();
		notes.destroy();
		super.destroy();
	}
}