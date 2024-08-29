package backend.conducting;

import backend.conducting.Song.SwagSong;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

typedef BPMChangeDef = {
	var stepTime:Float;
	var songTime:Float;
	var bpm:Float;
	var beatsPM:Float;
	var stepsPB:Float;
}

enum abstract SongTimeType(String) from String to String {
	var STEP = 'step';
	var BEAT = 'beat';
	var MEASURE = 'measure';
}

class Conductor implements IBeat implements IFlxDestroyable {
	// FlxSignals.
	public var onBPMChange:FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();
	public var onTimeChange:FlxTypedSignal<(Float, Float) -> Void> = new FlxTypedSignal<(Float, Float) -> Void>();
	public var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public var onMeasureHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	// Main Conductors.
	public static var menu:Conductor;
	public static var song:Conductor;

	/**
	 * The song tied to the conductor.
	 */
	public var audio:FlxSound;

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

	// beats/steps
	/**
	 * The number of beats per measure.
	 */
	public var beatsPerMeasure(default, null):Float = 4;
	/**
	 * The number of steps per beat.
	 */
	public var stepsPerBeat(default, null):Float = 4;

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
	public var songPosition(get, default):Float;
	inline function get_songPosition():Float
		return songPosition - posOffset;

	public var lastSongPos(default, null):Float;
	public var posOffset(get, null):Float = 0;

	inline function get_posOffset():Float {
		// if (posOffset != Options.posOffset) trace(posOffset = Options.posOffset);
		return posOffset;
	}

	/**
	 * Array of all the BPM changes that will occur.
	 */
	public var bpmChanges:Array<BPMChangeDef> = [];

	public function new() {
		audio = new FlxSound();
		audio.group = FlxG.sound.defaultMusicGroup;
		audio.stop();
		FlxG.signals.preUpdate.add(update);
		FlxG.signals.focusGained.add(onFocus);
		FlxG.signals.focusLost.add(onFocusLost);
	}

	inline public function reset():Void {
		audio.stop();
		songPosition = lastSongPos = curStepFloat = curStep = curBeat = curMeasure = 0;
		bpmChanges = [];
		changeBPM();
		startBpm = prevBpm = bpm;
	}

	/**
	 * Sets the audio it should play.
	 * @param music The name of the audio file.
	 * @param volume What should the volume be?
	 */
	inline public function setAudio(music:String, volume:Float = 1):Void {
		reset();
		if (audio == null) audio = new FlxSound();
		else if (audio.active) audio.stop();
		audio.loadEmbedded(Paths.music(music), true);
		changeBPM(102);
	}

	/**
	 * Sets the song it should play.
	 * @param song The name of the song.
	 * @param variant The variant of the song to play.
	 */
	inline public function setSong(song:String, variant:String):Void {
		reset();
		if (audio == null) audio = new FlxSound();
		else if (audio.active) audio.stop();
		audio.loadEmbedded(Paths.inst(song, variant));
	}

	public function update():Void {
		if (audio == null || !audio.playing) {
			lastSongPos = audio != null ? audio.time - posOffset : -posOffset;
			return;
		}
		if (lastSongPos != (lastSongPos = audio.time - posOffset))
			songPosition = lastSongPos; // update conductor
		else songPosition += posOffset + FlxG.elapsed * 1000;
		audio.update(FlxG.elapsed);

		if (bpm > 0 || beatsPerMeasure > 0 || stepsPerBeat > 0) {
			var lastChange:BPMChangeDef = {
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
				(lastChange.bpm > 0 && bpm != lastChange.bpm) ||
				(lastChange.beatsPM > 0 && beatsPerMeasure != lastChange.beatsPM) ||
				(lastChange.stepsPB > 0 && stepsPerBeat != lastChange.stepsPB)
			) changeBPM(lastChange.bpm);

			curStepFloat = lastChange.stepTime + ((songPosition - lastChange.songTime) / stepCrochet);
			// beat and measure versions update automatically

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

	inline public function onFocus()
		if (audio != null)
			@:privateAccess audio.onFocus();

	inline public function onFocusLost()
		if (audio != null)
			@:privateAccess audio.onFocusLost();

	inline private function callToState(timeType:SongTimeType, curTime:Int):Void {
		if (FlxG.state != null && FlxG.state.persistentUpdate) {
			var state = cast(FlxG.state, IBeat);
			switch (timeType) {
				case STEP:
					state.stepHit(curTime);
				case BEAT:
					state.beatHit(curTime);
				case MEASURE:
					state.measureHit(curTime);
			}
		}
		if (FlxG.state.subState != null && FlxG.state.subState.persistentUpdate) {
			var subState = cast(FlxG.state.subState, IBeat);
			switch (timeType) {
				case STEP:
					subState.stepHit(curTime);
				case BEAT:
					subState.beatHit(curTime);
				case MEASURE:
					subState.measureHit(curTime);
			}
		}
	}

	inline public function stepHit(curStep:Int):Void {
		callToState(STEP, curStep);
		onStepHit.dispatch(curStep);
	}

	inline public function beatHit(curBeat:Int):Void {
		callToState(BEAT, curBeat);
		onBeatHit.dispatch(curBeat);
	}

	inline public function measureHit(curMeasure:Int):Void {
		callToState(MEASURE, curMeasure);
		onMeasureHit.dispatch(curMeasure);
	}

	inline public function changeBPM(bpm:Float = 100, beatsPerMeasure:Float = 4, stepsPerBeat:Float = 4):Void {
		prevBpm = this.bpm;

		this.bpm = bpm;
		this.beatsPerMeasure = beatsPerMeasure;
		this.stepsPerBeat = stepsPerBeat;

		if (prevBpm != bpm) onBPMChange.dispatch(bpm);
		if (this.beatsPerMeasure != beatsPerMeasure || this.stepsPerBeat != stepsPerBeat)
			onTimeChange.dispatch(beatsPerMeasure, stepsPerBeat);
	}

	public function applyBPMChanges(song:SwagSong):Void {
		bpmChanges = [
			{
				stepTime: 0,
				songTime: 0,
				bpm: song.bpm,
				beatsPM: 4,
				stepsPB: 4
			}
		];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length) {
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
				curBPM = song.notes[i].bpm;
				var event:BPMChangeDef = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM,
					beatsPM: 4,
					stepsPB: 4
				}
				bpmChanges.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace('new BPM map BUDDY ' + bpmChanges);
	}

	public function getTimeForStep(step:Float):Float {
		var bpmChange:BPMChangeDef = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			beatsPM: beatsPerMeasure,
			stepsPB: stepsPerBeat
		};

		for (change in bpmChanges)
			if (change.stepTime < step && change.stepTime >= bpmChange.stepTime)
				bpmChange = change;

		return bpmChange.songTime + ((step - bpmChange.stepTime) * ((60 / bpmChange.bpm) * (1000 / stepsPerBeat)));
	}

	public function getStepForTime(time:Float):Float {
		var bpmChange:BPMChangeDef = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			beatsPM: beatsPerMeasure,
			stepsPB: stepsPerBeat
		};

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

	public function destroy():Void {
		FlxG.signals.preUpdate.remove(update);
		FlxG.signals.focusGained.remove(onFocus);
		FlxG.signals.focusLost.remove(onFocusLost);
		onBPMChange.destroy();
		onTimeChange.destroy();
		onStepHit.destroy();
		onBeatHit.destroy();
		onMeasureHit.destroy();
		@:privateAccess FlxG.sound.destroySound(audio);
	}
}