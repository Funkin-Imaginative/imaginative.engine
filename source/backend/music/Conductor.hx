package backend.music;

typedef BPMChange = {
	var stepTime:Float;
	var songTime:Float;
	var bpm:Float;
	var beatsPM:Int;
	var stepsPB:Int;
}

typedef CheckpointTyping = {
	var time:Float;
	var bpm:Float;
	var signature:Array<Int>;
}
typedef AudioData = {
	@:default('Unassigned') @:optional var artist:String;
	var name:String;
	@:default(100) var bpm:Float;
	@:default([4, 4]) var signature:Array<Int>;
	@:default(0) @:optional var offset:Float;
	@:default([]) var checkpoints:Array<CheckpointTyping>;
}

enum abstract SongTimeType(String) from String to String {
	var STEP;
	var BEAT;
	var MEASURE;
}

class Conductor implements IFlxDestroyable implements IBeat {
	// FlxSignals.
	public var onBPMChange:FlxTypedSignal<(Float, Int, Int) -> Void> = new FlxTypedSignal<(Float, Int, Int) -> Void>();
	public var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public var onMeasureHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	// Main Conductors.
	public static var menu(default, null):Conductor = new Conductor();
	public static var song(default, null):Conductor = new Conductor();

	/**
	 * Contains data for the song to play.
	 */
	public var data(default, null):AudioData = {
		name: 'None',
		bpm: 100,
		signature: [4, 4],
		checkpoints: []
	}
	public var conductorSoundGroup(default, null):FlxSoundGroup;
	/**
	 * The song tied to the conductor.
	 */
	public var audio(default, null):FlxSound;
	/**
	 * Used to sync up other audio instances to said conductor. Mainly used for vocals in songs.
	 */
	public var extra(default, null):Array<FlxSound> = [];

	// BPM's.
	/**
	 * Starting BPM.
	 */
	public var startBpm(default, null):Float = 100;
	/**
	 * Previous BPM. (is the start bpm on start)
	 */
	public var prevBpm(default, null):Float = 100;
	/**
	 * Current BPM.
	 */
	public var bpm(default, null):Float = 100;

	/**
	 * The current step.
	 */
	public var curStep(default, null):Int = 0;
	/**
	 * The current beat.
	 */
	public var curBeat(default, null):Int = 0;
	/**
	 * The current measure.
	 */
	public var curMeasure(default, null):Int = 0;

	/**
	 * The current step, as a float instead.
	 */
	public var curStepFloat(default, null):Float = 0;
	/**
	 * The current beat, as a float instead.
	 */
	public var curBeatFloat(get, never):Float;
	inline function get_curBeatFloat():Float
		return curStepFloat / stepsPerBeat;
	/**
	 * The current measure, as a float instead.
	 */
	public var curMeasureFloat(get, never):Float;
	inline function get_curMeasureFloat():Float
		return curBeatFloat / beatsPerMeasure;

	// time signature
	/**
	 * The number of beats per measure.
	 */
	public var beatsPerMeasure(default, null):Int = 4;
	/**
	 * The number of steps per beat.
	 */
	public var stepsPerBeat(default, null):Int = 4;

	/**
	 * How long a beat is in milliseconds.
	 */
	public var crochet(get, never):Float;
	inline function get_crochet():Float
		return 60 / bpm * 1000;
	/**
	 * How long a step is in milliseconds.
	 */
	public var stepCrochet(get, never):Float;
	inline function get_stepCrochet():Float
		return crochet / stepsPerBeat;
	/**
	 * How long a measure is in milliseconds.
	 */
	public var partCrochet(get, never):Float;
	inline function get_partCrochet():Float
		return crochet * beatsPerMeasure;

	/**
	 * Current position of the song in milliseconds.
	 */
	public var songPosition(default, null):Float;
	public var lastSongPos(default, null):Float;
	public var posOffset(get, null):Float = 0;
	inline function get_posOffset():Float {
		if (posOffset != data.offset) posOffset = data.offset;
		return posOffset;
	}

	/**
	 * Array of all the BPM changes that will occur.
	 */
	public var bpmChanges:Array<BPMChange> = [];

	public function new() {
		conductorSoundGroup = new FlxSoundGroup();
		audio = new FlxSound();
		audio.autoDestroy = false; // jic
		FlxG.signals.preUpdate.add(update);
		FlxG.signals.focusGained.add(onFocus);
		FlxG.signals.focusLost.add(onFocusLost);
	}

	inline function destroySound(sound:FlxSound):Void {
		if (sound.group != null && sound.group.sounds.contains(sound))
			sound.group.remove(sound);
		sound.destroy();
	}

	/**
	 * Plays Conductor audio.
	 */
	inline public function play():Void
		for (sound in conductorSoundGroup.sounds)
			sound.play();

	/**
	 * Pauses Conductor audio.
	 */
	inline public function pause():Void
		conductorSoundGroup.pause();

	/**
	 * Resumes Conductor audio.
	 */
	inline public function resume():Void
		conductorSoundGroup.resume();

	/**
	 * Stops Conductor audio.
	 */
	inline public function stop():Void
		for (sound in conductorSoundGroup.sounds)
			sound.stop();

	/**
	 * Resets Conductor.
	 */
	inline public function reset():Void {
		audio.stop();
		for (sound in extra)
			destroySound(sound);
		extra = [];

		songPosition = lastSongPos = curStepFloat = curStep = curBeat = curMeasure = 0;
		bpmChanges = [];
		changeBPM();
		startBpm = prevBpm = bpm;
	}

	/**
	 * Sets the audio it should play.
	 * @param music The name of the audio file.
	 * @param volume What should the volume be?
	 * @param afterLoad Function that runs after the audio has loaded.
	 */
	inline public function loadMusic(music:String, volume:Float = 1, ?afterLoad:FlxSound->Void):Void {
		reset();
		if (audio == null) audio = new FlxSound();
		else if (audio.active) audio.stop();

		audio.loadEmbedded(Paths.music(music), true);
		@:privateAccess FlxG.sound.loadHelper(audio, volume, conductorSoundGroup);
		audio.persist = true;

		data = getMetadata('music/$music');
		applyBPMChanges();
		changeBPM(data.bpm, data.signature[0], data.signature[1]);
		if (afterLoad != null) afterLoad(audio);
	}

	/**
	 * Sets the song it should play.
	 * @param song The name of the song.
	 * @param variant The variant of the song to play.
	 * @param afterLoad Function that runs after the audio has loaded.
	 */
	inline public function loadSong(song:String, variant:String = 'normal', ?afterLoad:FlxSound->Void):Void {
		reset();
		if (audio == null) audio = new FlxSound();
		else if (audio.active) audio.stop();

		audio.loadEmbedded(Paths.inst(song, variant));
		@:privateAccess FlxG.sound.loadHelper(audio, 1, conductorSoundGroup);
		audio.persist = false;

		data = getMetadata('content/songs/$song/audio${variant == 'normal' ? '' : '-$variant'}');
		applyBPMChanges();
		changeBPM(data.bpm, data.signature[0], data.signature[1]);
		if (afterLoad != null) afterLoad(audio);
	}

	/**
	 * Add's a vocal track to run, used for songs.
	 * @param song The name of the song.
	 * @param suffix The vocal suffix.
	 * @param variant The variant of the vocals to play.
	 * @param afterLoad Function that runs after the audio has loaded.
	 * @return `FlxSound` ~ Added Vocal Track
	 */
	inline public function addVocalTrack(song:String, suffix:String, variant:String = 'normal', ?afterLoad:FlxSound->Void):FlxSound {
		var path:String = Paths.voices(song, suffix, variant);
		if (!Paths.fileExists(path, false)) {
			trace('Failed to find ${suffix.trim() == '' ? 'base ' : ''}vocal track for song "$song"${variant == 'normal' ? '' : ', variant "$variant"'}${suffix.trim() == '' ? '' : ' with a suffix of "$suffix"'}.');
			return null;
		}

		var vocals:FlxSound = new FlxSound();
		vocals.autoDestroy = false; // jic

		vocals.loadEmbedded(path);
		@:privateAccess FlxG.sound.loadHelper(vocals, audio.volume, conductorSoundGroup);
		vocals.persist = audio.persist;

		extra.push(vocals);
		if (afterLoad != null) afterLoad(vocals);
		return vocals;
	}

	/**
	 * Get's song metadata.
	 * @param path Json path for the metadata.
	 * @return `AudioData`
	 */
	inline public function getMetadata(path:String):AudioData {
		try {
			final content:AudioData = new json2object.JsonParser<AudioData>().fromJson(Paths.getFileContent(Paths.json(path)), Paths.json(path));
			if (content == null) trace('Metadata parse failed.');
			return content.getDefault({
				name: 'None',
				bpm: 100,
				signature: [4, 4],
				checkpoints: []
			});
		} catch(error:haxe.Exception) {
			trace('Error occured when attempting to parse the json: ${error.message}');
			return {
				name: 'None',
				bpm: 100,
				signature: [4, 4],
				checkpoints: []
			}
		}
	}

	var __offsetViolation:Float = 0;

	@:dox(hide)
	@SuppressWarnings('checkstyle:FieldDocComment')
	public function update():Void {
		if (audio == null || !audio.playing) {
			lastSongPos = audio != null ? audio.time - posOffset : -posOffset;
			return;
		}
		if (lastSongPos != (lastSongPos = audio.time - posOffset))
			songPosition = lastSongPos; // update conductor
		else songPosition += posOffset + FlxG.elapsed * 1000;
		audio.update(FlxG.elapsed);

		for (sound in extra) {
			// idea from psych
			if (audio.time < sound.length) {
				// CNE's method.
				if ((__offsetViolation = Math.max(0, __offsetViolation + (sound.time != audio.time ? FlxG.elapsed : -FlxG.elapsed / 2))) > 25) {
					sound.pause();
					sound.time = audio.time;
					sound.play();
					__offsetViolation = 0;
				}
			} else sound.pause();
			sound.update(FlxG.elapsed);
		}

		if (bpm > 0 || beatsPerMeasure > 0 || stepsPerBeat > 0) {
			var lastChange:BPMChange = {
				stepTime: 0,
				songTime: 0,
				bpm: 0,
				beatsPM: 0,
				stepsPB: 0
			}
			for (change in bpmChanges)
				if (songPosition >= change.songTime)
					lastChange = change;

			if (
				(lastChange.bpm > 0 && bpm != lastChange.bpm) /* ||
				(lastChange.beatsPM > 0 && beatsPerMeasure != lastChange.beatsPM) ||
				(lastChange.stepsPB > 0 && stepsPerBeat != lastChange.stepsPB) */
			) changeBPM(lastChange.bpm);

			// beat and measure versions update automatically
			curStepFloat = lastChange.stepTime + ((songPosition - lastChange.songTime) / stepCrochet);

			// update step
			if (curStep != (curStep = Math.floor(curStepFloat))) {
				var oldStep:Int = curStep;
				var oldBeat:Int = curBeat;
				var oldMeasure:Int = curMeasure;
				if (curStep < oldStep && oldStep - curStep < 2)
					return;

				// update beat and measure
				var updateBeat:Bool = curBeat != (curBeat = Math.floor(curBeatFloat));
				var updateMeasure:Bool = updateBeat && (curMeasure != (curMeasure = Math.floor(curMeasureFloat)));

				if (curStep > oldStep)
					for (i in oldStep...curStep)
						stepHit(i + 1);
				if (updateBeat && curBeat > oldBeat)
					for (i in oldBeat...curBeat)
						beatHit(i + 1);
				if (updateMeasure && curMeasure > oldMeasure)
					for (i in oldMeasure...curMeasure)
						measureHit(i + 1);
			}
		}
	}

	@:dox(hide)
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline public function onFocus():Void {
		if (audio != null)
			@:privateAccess audio.onFocus();
		for (sound in extra)
			@:privateAccess sound.onFocus();
	}

	@:dox(hide)
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline public function onFocusLost():Void {
		if (audio != null)
			@:privateAccess audio.onFocusLost();
		for (sound in extra)
			@:privateAccess sound.onFocusLost();
	}

	@:allow(backend.music.states.BeatState) static var beatStates:Array<BeatState> = [];
	@:allow(backend.music.states.BeatSubState) static var beatSubStates:Array<BeatSubState> = [];
	inline function callToState(timeType:SongTimeType, curTime:Int):Void {
		for (state in beatStates)
			if (state != null && state.conductor == this && (state.persistentUpdate || state.subState == null))
				switch (timeType) {
					case STEP:
						state.stepHit(curTime);
						GlobalScript.stepHit(curTime, state.conductor);
					case BEAT:
						state.beatHit(curTime);
						GlobalScript.beatHit(curTime, state.conductor);
					case MEASURE:
						state.measureHit(curTime);
						GlobalScript.measureHit(curTime, state.conductor);
				}
		for (state in beatSubStates)
			if (state != null && state.conductor == this && (state.persistentUpdate || state.subState == null))
				switch (timeType) {
					case STEP:
						state.stepHit(curTime);
					case BEAT:
						state.beatHit(curTime);
					case MEASURE:
						state.measureHit(curTime);
				}
	}

	/**
	 * Ran when the next step happens.
	 * @param curStep The current step.
	 */
	inline public function stepHit(curStep:Int):Void {
		onStepHit.dispatch(curStep);
		callToState(STEP, curStep);
	}
	/**
	 * Ran when the next beat happens.
	 * @param curBeat The current beat.
	 */
	inline public function beatHit(curBeat:Int):Void {
		onBeatHit.dispatch(curBeat);
		callToState(BEAT, curBeat);
	}
	/**
	 * Ran when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	inline public function measureHit(curMeasure:Int):Void {
		onMeasureHit.dispatch(curMeasure);
		callToState(MEASURE, curMeasure);
	}

	/**
	 * Changes the current BPM position of the song.
	 * @param bpm New "beats per minute" number.
	 * @param beatsPerMeasure New "beats per measure" number.
	 * @param stepsPerBeat New "steps per beat" number.
	 */
	inline public function changeBPM(bpm:Float = 100, beatsPerMeasure:Int = 4, stepsPerBeat:Int = 4):Void {
		prevBpm = this.bpm;

		this.bpm = bpm;
		this.beatsPerMeasure = beatsPerMeasure;
		this.stepsPerBeat = stepsPerBeat;

		if (prevBpm != bpm || this.beatsPerMeasure != beatsPerMeasure || this.stepsPerBeat != stepsPerBeat)
			onBPMChange.dispatch(bpm, beatsPerMeasure, stepsPerBeat);
	}

	/**
	 * Renders any bpm change that happen throughout the song.
	 */
	public function applyBPMChanges():Void {
		bpmChanges = [
			{
				stepTime: 0,
				songTime: 0,
				bpm: data.bpm,
				beatsPM: data.signature[0],
				stepsPB: data.signature[1]
			}
		];

		var curBPM:Float = data.bpm;
		var curSig:Array<Int> = data.signature;
		var songTime:Float = 0;
		var stepTime:Float = 0;
		for (checkpoint in data.checkpoints) {
			if (
				checkpoint.bpm == curBPM &&
				curSig[0] == checkpoint.signature[0] &&
				curSig[1] == checkpoint.signature[1]
			) continue;
			stepTime += (checkpoint.time - songTime) / ((60 / curBPM) * 1000 / 4);
			songTime = checkpoint.time;
			curBPM = checkpoint.bpm;
			curSig = checkpoint.signature;

			bpmChanges.push({
				stepTime: stepTime,
				songTime: songTime,
				bpm: curBPM,
				beatsPM: curSig[0],
				stepsPB: curSig[1]
			});
		}
	}

	public function getTimeForStep(step:Float):Float {
		var bpmChange:BPMChange = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			beatsPM: beatsPerMeasure,
			stepsPB: stepsPerBeat
		}

		for (change in bpmChanges)
			if (change.stepTime < step && change.stepTime >= bpmChange.stepTime)
				bpmChange = change;

		return bpmChange.songTime + ((step - bpmChange.stepTime) * ((60 / bpmChange.bpm) * (1000 / stepsPerBeat)));
	}

	public function getStepForTime(time:Float):Float {
		var bpmChange:BPMChange = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			beatsPM: beatsPerMeasure,
			stepsPB: stepsPerBeat
		}

		for (change in bpmChanges)
			if (change.songTime < time && change.songTime >= bpmChange.songTime)
				bpmChange = change;

		return bpmChange.stepTime + ((time - bpmChange.songTime) / ((60 / bpmChange.bpm) * (1000 / stepsPerBeat)));
	}

	inline public function getMeasureLength():Float
		return stepsPerBeat * beatsPerMeasure;

	inline public function getMeasuresLength():Float {
		if (audio == null) return 0;
		return getStepForTime(audio.length) / getMeasureLength();
	}

	/**
	 * When called it destroys the Conductor.
	 * Unless it's a main one, then don't destroy it please.
	 */
	public function destroy():Void {
		FlxG.signals.preUpdate.remove(update);
		FlxG.signals.focusGained.remove(onFocus);
		FlxG.signals.focusLost.remove(onFocusLost);

		onBPMChange.destroy();
		onStepHit.destroy();
		onBeatHit.destroy();
		onMeasureHit.destroy();

		destroySound(audio);
		for (sound in extra)
			destroySound(sound);
		extra = [];
	}
}