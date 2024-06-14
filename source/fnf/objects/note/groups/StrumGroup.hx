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

typedef HitFuncs = {
	var noteHit:NoteHitEvent->Void;
	var noteMiss:NoteMissEvent->Void;
}
typedef NoteSignals = {
	var noteHit:FlxTypedSignal<NoteHitEvent->Void>;
	var noteMiss:FlxTypedSignal<NoteMissEvent->Void>;
	var noteSpawn:FlxTypedSignal<BasicNoteEvent->Void>;
	var noteDestroy:FlxTypedSignal<BasicNoteEvent->Void>;
	var splashSpawn:FlxTypedSignal<SplashSpawnEvent->Void>;
}

private typedef SplashXCover = flixel.util.typeLimit.OneOfTwo<Splash, HoldCover>;

class StrumGroup extends FlxTypedGroup<Strum> {
	public var extra:Map<String, Dynamic> = [];

	// Even tho you can have a but ton of StrumGroup's you can ONLY play as one!
	inline public static function swapTargetGroups() {
		var prevOppo:StrumGroup = enemy;
		var prevPlay:StrumGroup = player;
		enemy = prevPlay;
		player = prevOppo;
	}
	public static var enemy:Null<StrumGroup> = null; // enemy play be like
	public static var player:Null<StrumGroup> = null;
	public var status(get, set):Null<Bool>;
	inline function get_status():Null<Bool> {
		if (this == enemy) return false;
		if (this == player) return true;
		return null;
	}
	function set_status(value:Null<Bool>):Null<Bool> {
		switch (value) {
			case false:
				if (enemy == player) swapTargetGroups();
				else enemy = this;
			case true:
				if (player == enemy) swapTargetGroups();
				else player = this;
			case null:
				var prevStatus:Null<Bool> = status; // jic
				if (prevStatus != null) prevStatus ? player = null : enemy = null;
		}
		return status;
	}

	public var __helper:Null<Bool> = null;
	public var helper(get, set):Null<Bool>;
	function get_helper():Null<Bool> return status == null ? __helper : status;
	function set_helper(value:Null<Bool>):Null<Bool> return __helper = value;
	public function helperConvert(value:Float):Float {
		if (helper == null) return 0;
		else return value * (helper ? 1 : -1);
	}

	public static var hitFuncs(default, never):HitFuncs = {noteHit: null, noteMiss: null}
	public var signals(default, never):NoteSignals = {
		noteHit: new FlxTypedSignal<NoteHitEvent->Void>(),
		noteMiss: new FlxTypedSignal<NoteMissEvent->Void>(),
		noteSpawn: new FlxTypedSignal<BasicNoteEvent->Void>(),
		noteDestroy: new FlxTypedSignal<BasicNoteEvent->Void>(),
		splashSpawn: new FlxTypedSignal<SplashSpawnEvent->Void>()
	}

	public var notes(default, null):NoteGroup;
	public var splashes(default, null):FlxTypedGroup<Splash>;
	public var holdCovers(default, null):FlxTypedGroup<HoldCover>;
	public function spawn(classType:Class<SplashXCover>, note:Note):SplashXCover {
		if (classType == Splash) return splashes.add(splashes.recycle(Splash).setupSplash(note));
		if (classType == HoldCover) return holdCovers.add(holdCovers.recycle(HoldCover).setupCover(note));
		return null;
	}

	public var vocals:FlxSound;
	public var vocalsFinished:Bool = false;
	public var character:Character;

	public function new(x:Float, y:Float, pixel:Bool = false, amount:Int = 4) {
		super(9); // lol
		for (i in 0...amount) {
			var babyArrow:Strum = new Strum(x - (Note.swagWidth / 2), y, i, pixel);
			babyArrow.x += Note.swagWidth * i;
			babyArrow.x -= (Note.swagWidth * ((amount - 1) / 2));
			@:privateAccess Strum.setStrumGroup(babyArrow, this);
			if (SaveManager.getOption('strumShift')) babyArrow.x -= Note.swagWidth / 2.4;
			insert(i, babyArrow);
		}
		notes = new NoteGroup();
		splashes = new FlxTypedGroup<Splash>();
		holdCovers = new FlxTypedGroup<HoldCover>();

		var splash:Splash = new Splash(notes.members[0]);
		splash.alpha = 0.0001;
		splashes.add(splash);
		var cover:HoldCover = new HoldCover(notes.members[0]);
		cover.alpha = 0.0001;
		holdCovers.add(cover);
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

		var vocalsPath:String = Paths.voices(PlayState.SONG.song, status ? 'Player' : 'Enemy');
		vocals = FileSystem.exists(vocalsPath) ? FlxG.sound.load(vocalsPath) : new FlxSound();

		vocals.group = FlxG.sound.defaultMusicGroup;
		vocals.persist = false;

		notes.sortSelf();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		notes.update(elapsed);
		splashes.update(elapsed);
		holdCovers.update(elapsed);

		notes.forEachAlive((note:Note) ->
			if (note.strumTime <= Conductor.songPosition)
				if (note.forceHit) PlayField.noteHit(note, this)
		);

		var controls:Controls = PlayerSettings.player1.controls;
		var keys:KeySetupArray = {
			hold: [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT],
			press: [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P],
			release: [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R]
		}
		if (status != null && status == !PlayUtil.enemyPlay && !PlayUtil.botplay) {
			if (keys.hold.contains(true) /* && !boyfriend.stunned */) {
				// trace('hit the fucking note you idiot');
				notes.forEachAlive((note:Note) ->
					if (note.isSustain && note.canHit && keys.hold[note.data])
						PlayField.noteHit(note, this)
				);
			}

			if (keys.press.contains(true) /* && !boyfriend.stunned */) {
				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later

				notes.forEachAlive((note:Note) ->
					if (note.canHit && !note.tooLate && !note.wasHit && !note.wasMissed) {
						if (directionList.contains(note.data)) {
							for (coolNote in possibleNotes) {
								if (coolNote.data == note.data && Math.abs(note.strumTime - coolNote.strumTime) < 10){
									// if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(note);
									break;
								} else if (coolNote.data == note.data && note.strumTime < coolNote.strumTime) {
									// if note is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(note);
									break;
								}
							}
						} else {
							possibleNotes.push(note);
							directionList.push(note.data);
						}
					}
				);

				for (note in dumbNotes) deleteNote(note);

				possibleNotes.sort(NoteGroup.noteSortArray);

				if (possibleNotes.length > 0) {
					for (deNote in possibleNotes) {
						// for (shit in 0...keys.press.length)
						// if a direction is hit that shouldn't be
						if (!keys.press[deNote.data] && !directionList.contains(deNote.data))
							PlayField.noteMiss(deNote, deNote.data, this);
						if (keys.press[deNote.data])
							PlayField.noteHit(deNote, this);
					}
				} else
					for (shit in 0...keys.press.length)
						if (!SaveManager.getOption('ghostTapping') && keys.press[shit])
							PlayField.noteMiss(null, shit, this);
			}

			for (index => strum in members) {
				var key:KeySetup = {hold: keys.hold[index], press: keys.press[index], release: keys.release[index]}
				if (key.press && strum.animation.name != 'confirm') strum.playAnim('press');
				if (!key.hold) strum.playAnim('static');
			}
		} else {
			notes.forEachAlive((note:Note) ->
				if (note.strumTime <= Conductor.songPosition)
					if (note.forceMiss) PlayField.noteMiss(note, note.data, this)
					else PlayField.noteHit(note, this)
			);
		}

		for (note in notes) {
			if (!note.isSustain) {
				var doKill:Bool = false;
				var array:Array<Note> = note.tail.copy(); array.push(note);
				for (lol in array) {
					doKill = (lol.wasHit || lol.wasMissed) && !lol.isOnScreen();
					if (!doKill) break;
				}
				if (doKill)
					for (lol in array)
						deleteNote(lol);
			}
		}
	}

	inline public function deleteNote(note:Note) {
		if (note != null) {
			signals.noteDestroy.dispatch(new BasicNoteEvent(note));
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function drawNotes(drawNote:Bool, drawSustain:Bool) {
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
		var sustainsUnderStrums:Bool = SaveManager.getOption('sustainsUnderStrums');
		drawNotes(false, sustainsUnderStrums);
		super.draw();
		drawNotes(true, !sustainsUnderStrums);
		holdCovers.cameras = cameras;
		holdCovers.draw();
		splashes.cameras = cameras;
		splashes.draw();
	}

	override public function destroy() {
		if (status) PlayUtil.botplay = false; // resets botplay
		holdCovers.destroy();
		splashes.destroy();
		notes.destroy();
		super.destroy();
	}
}