package imaginative.backend.music;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef BPMChange = {
	var stepTime:Float;
	var songTime:Float;
	var bpm:Float;
	var beatsPM:Int;
	var stepsPB:Int;
}

typedef CheckpointTyping = {
	/**
	 * The position of the song in milliseconds.
	 */
	var time:Float;
	/**
	 * The "beats per minute" at that point.
	 */
	var bpm:Float;
	/**
	 * The time signature at that point.
	 */
	var signature:Array<Int>;
}
typedef AudioData = {
	/**
	 * The composer of the song.
	 */
	@:default('Unassigned') var artist:String;
	/**
	 * The display name of the song.
	 */
	var name:String;
	/**
	 * The bpm at the start of the song.
	 */
	@:default(100) var bpm:Float;
	/**
	 * The time signature at the start of the song.
	 */
	@:default([4, 4]) var signature:Array<Int>;
	/**
	 * The audio offset.
	 */
	@:default(0) var ?offset:Float;
	/**
	 * Contains all known bpm changes.
	 */
	var checkpoints:Array<CheckpointTyping>;
}

// MAYBE: Add documentation.
@SuppressWarnings('checkstyle:FieldDocComment')
enum abstract SongTimeType(String) from String to String {
	var IsStep = 'Step';
	var IsBeat = 'Beat';
	var IsMeasure = 'Measure';
}

/**
 * The main powerhouse of funkin, The Song Conductor!
 */
@:access(flixel.system.frontEnds.SoundFrontEnd.loadHelper)
class Conductor implements IFlxDestroyable implements IBeat {
	@:allow(imaginative.states.EngineProcess)
	static function init():Void {
		menu = new Conductor('Menu', true);
		song = new Conductor('Song');
		cutscene = new Conductor('Cutscene', true);
		charter = new Conductor('Charter');
	}

	/**
	 * The conductor id.
	 * This is completely optional and is only used in the debug console.
	 */
	public var id(default, null):String;

	/**
	 * If true, when the audio ends it will loop.
	 */
	public var canLoop:Bool;

	// FlxSignals.
	/**
	 * Dispatches when the bpm changes.
	 * @param bpm The bpm.
	 * @param beatsPM The number of beats per measure.
	 * @param stepsPB The number of steps per beat.
	 */
	public var onBPMChange(default, null):FlxTypedSignal<(Float, Int, Int) -> Void> = new FlxTypedSignal<(Float, Int, Int) -> Void>();
	/**
	 * Dispatches when the next step happens.
	 * @param curStep The current step.
	 */
	public var onStepHit(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	/**
	 * Dispatches when the next beat happens.
	 * @param curBeat The current beat.
	 */
	public var onBeatHit(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	/**
	 * Dispatches when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	public var onMeasureHit(default, null):FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	/**
	 * Dispatches when the audio ends.
	 */
	public var onComplete(default, null):FlxTypedSignal<ScriptEvent->Void> = new FlxTypedSignal<ScriptEvent->Void>();
	/**
	 * Same as above but this is a one time use.
	 * As it kills itself after it's called.
	 */
	public var _onComplete:ScriptEvent->Void;
	/**
	 * Dispatches when the audio loops.
	 */
	public var onLoop(default, null):FlxTypedSignal<ScriptEvent->Void> = new FlxTypedSignal<ScriptEvent->Void>();

	// Main Conductors.
	/**
	 * The conductor for menu music.
	 */
	public static var menu(default, null):Conductor;
	/**
	 * The conductor for songs in PlayState.
	 */
	public static var song(default, null):Conductor;
	/**
	 * The conductor for cutscene audio.
	 */
	public static var cutscene(default, null):Conductor;
	/**
	 * The conductor for the chart editor.
	 */
	public static var charter(default, null):Conductor;

	@:unreflective static var isSub:Bool = false;
	// Direct access.
	/**
	 * The current state or substate conductor instance.
	 */
	public static var direct(get, never):Conductor;
	static function get_direct():Conductor {
		var stopWhile:Bool = false;
		var state:FlxState = FlxG.state;
		isSub = false;
		while (!stopWhile) {
			if (state.subState != null && state.subState is IBeat) {
				state = state.subState;
				isSub = true;
			} else stopWhile = true;
		}
		return isSub ? cast(state, BeatSubState).conductor : cast(state, BeatState).conductor;
	}
	/**
	 * The current state conductor instance.
	 */
	public static var mainDirect(get, never):Conductor;
	inline static function get_mainDirect():Conductor {
		var lol:Conductor = get_direct(); // doing it like this so isSub gets set properly
		return isSub ? null : lol;
	}
	/**
	 * The current substate conductor instance.
	 */
	public static var subDirect(get, never):Conductor;
	inline static function get_subDirect():Conductor {
		var lol:Conductor = get_direct(); // doing it like this so isSub gets set properly
		return isSub ? lol : null;
	}

	/**
	 * Contains data for the song to play.
	 */
	public var data(default, null):AudioData = {
		artist: 'Unassigned',
		name: 'None',
		bpm: 100,
		signature: [4, 4],
		checkpoints: [],
		offset: 0
	}
	/**
	 * The sound group all conductor audio is tied to.
	 */
	public var soundGroup(default, null):FlxSoundGroup;
	/**
	 * The audio tied to the conductor.
	 */
	public var audio(default, null):FlxSound;
	/**
	 * Used to sync up other audio instances to said conductor. Mainly used for vocals in songs.
	 */
	public var extra(default, null):Array<FlxSound> = [];

	/**
	 * States if the conductor should update the time itself.
	 * Mostly used for when the song time is under or above the audio time length.
	 */
	public var autoSetTime(get, never):Bool;
	inline function get_autoSetTime():Bool {
		if (time > 0 && (time < audio.length || audioEnded))
			return false;
		return true;
	}

	/**
	 * States if the conductor audio is playing or not.
	 */
	public var playing(default, null):Bool = false;

	/**
	 * The conductor's volume level.
	 */
	public var volume(get, set):Float;
	inline function get_volume():Float
		return soundGroup.volume;
	inline function set_volume(value:Float):Float
		return soundGroup.volume = value;

	#if FLX_PITCH
	/**
	 * Set pitch, which also alters the playback speed. Default is 1.
	 */
	public var pitch(get, set):Float;
	inline function get_pitch():Float
		return audio == null ? 1 : audio.pitch;
	inline function set_pitch(value:Float):Float {
		if (audio == null) return 1;
		for (sound in soundGroup.sounds)
			sound.pitch = audio.pitch;
		return value;
	}
	#end

	// BPM's.
	/**
	 * Starting BPM.
	 */
	public var startBpm(default, null):Float = 100;
	/**
	 * Previous bpm. (is the `startBpm` on start)
	 */
	public var prevBpm(default, null):Float = 100;
	/**
	 * The beats per second, bpm for short.
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
	 * How long a step is in milliseconds.
	 */
	public var stepTime(get, never):Float;
	inline function get_stepTime():Float
		return beatTime / stepsPerBeat;
	/**
	 * How long a beat is in milliseconds.
	 */
	public var beatTime(get, never):Float;
	inline function get_beatTime():Float
		return 60 / bpm * 1000;
	/**
	 * How long a measure is in milliseconds.
	 */
	public var measureTime(get, never):Float;
	inline function get_measureTime():Float
		return beatTime * beatsPerMeasure;

	/**
	 * Current position of the song in milliseconds.
	 */
	public var time(default, null):Float = 0;
	/**
	 * Previous time.
	 */
	public var prevTime(default, null):Float;
	/**
	 * The audio offset.
	 */
	public var timeOffset(get, null):Float = 0;
	inline function get_timeOffset():Float {
		if (timeOffset != data.offset)
			timeOffset = data.offset;
		return timeOffset;
	}

	/**
	 * Array of all the BPM changes that will occur.
	 */
	public var bpmChanges(default, null):Array<BPMChange> = [];

	/**
	 * Creates a new conductor instance.
	 * @param id This is completely optional and is only used in the debug console.
	 * @param canLoop If true, when the audio ends it will loop.
	 */
	public function new(?id:String = 'Unknown', canLoop:Bool = false) {
		this.id = id;
		this.canLoop = canLoop;
		soundGroup = new FlxSoundGroup();

		audio = FlxG.sound.list.add(new FlxSound());
		audio.autoDestroy = false; // jic

		FlxG.signals.preUpdate.add(update);
		FlxG.signals.focusGained.add(onFocus);
		FlxG.signals.focusLost.add(onFocusLost);
	}

	var audioEnded:Bool = false;
	inline function onCompleteFunc():Void {
		var event:ScriptEvent = new ScriptEvent();
		if (canLoop) {
			prevTime = time = curStepFloat = curStep = curBeat = curMeasure = 0;
			applyBPMChanges();
			onLoop.dispatch(event);
		} else {
			onComplete.dispatch(event);
			if (_onComplete != null) {
				_onComplete(event);
				_onComplete = null;
			}
			playing = false; // ugh
			audioEnded = true;
		}
	}

	inline function destroySound(sound:FlxSound):Void {
		if (sound.group != null)
			if (soundGroup.sounds.contains(sound))
				soundGroup.remove(sound);
			else if (sound.group.sounds.contains(sound))
				sound.group.remove(sound);
		sound.destroy();
	}

	/**
	 * An internal function for playing the conductor audio.
	 */
	inline function _play():Void {
		audioEnded = false;
		if (!autoSetTime)
			for (sound in soundGroup.sounds)
				sound.play(time);
		playing = true;
		resyncVocals();
	}
	/**
	 * Play's the conductor audio from a specified time of your choosing.
	 * @param startTime The song starting time.
	 * @param startVolume The song starting volume.
	 */
	inline public function playFromTime(startTime:Float = 0, startVolume:Float = 1):Void {
		time = startTime;
		play(startVolume);
	}
	/**
	 * Play's the conductor audio.
	 * @param startVolume The song starting volume.
	 */
	inline public function play(startVolume:Float = 1):Void {
		volume = startVolume;
		_play();
	}

	/**
	 * Pause's the conductor audio.
	 */
	inline public function pause():Void {
		soundGroup.pause();
		playing = false;
	}

	/**
	 * Resume's the conductor audio.
	 */
	inline public function resume():Void {
		if (!autoSetTime)
			soundGroup.resume();
		playing = true;
		resyncVocals(true);
	}

	/**
	 * Stop's the conductor audio.
	 */
	inline public function stop():Void {
		for (sound in soundGroup.sounds)
			sound.stop();
		playing = false;
	}

	/**
	 * Reset's the conductor.
	 */
	inline public function reset():Void {
		stop();
		for (sound in extra)
			destroySound(sound);
		extra = [];

		prevTime = time = curStepFloat = curStep = curBeat = curMeasure = 0;
		bpmChanges = [];
		changeBPM();
		startBpm = prevBpm = bpm;
	}

	/**
	 * Pulled the fade code from FlxSound, lmao.
	 */
	var fadeTween:FlxTween;
	/**
	 * Fades in the conductor audio.
	 * Note: Always starts from 0.
	 * @param duration The amount of time the fade in should take.
	 * @param to The value to tween to.
	 */
	inline public function fadeIn(duration:Float = 1, to:Float = 1, ?onComplete:FlxTween->Void):Void {
		if (!playing)
			play();

		stopFade();
		fadeTween = FlxTween.num(0, to, duration, {onComplete: onComplete}, (value:Float) -> volume = value);
	}
	/**
	 * Fades out the conductor audio.
	 * @param duration The amount of time the fade out should take.
	 * @param to The value to tween to.
	 */
	inline public function fadeOut(duration:Float = 1, to:Float = 0, ?onComplete:FlxTween->Void):Void {
		stopFade();
		fadeTween = FlxTween.num(volume, to, duration, {onComplete: onComplete}, (value:Float) -> volume = value);
	}
	/**
	 * Stops the fade tween dead in it's tracks.
	 * @param returnValue Do you wish to have the conductor volume return to a different value?
	 */
	inline public function stopFade(?returnValue:Float):Void {
		if (fadeTween != null)
			fadeTween.cancel();
		if (returnValue != null)
			volume = returnValue;
	}

	/**
	 * Sets the music it should play.
	 * @param music The name of the audio file.
	 * @param afterLoad Function that runs after the audio has loaded.
	 */
	public function loadMusic(music:ModPath, ?afterLoad:FlxSound->Void):Void {
		reset();
		if (audio == null)
			audio = FlxG.sound.list.add(new FlxSound());

		audio.loadEmbedded(Assets.music(music));
		FlxG.sound.loadHelper(audio, 1, soundGroup);
		audio.persist = true;

		data = getMetadata('${music.type}:music/${music.path}');
		applyBPMChanges();

		#if FLX_PITCH pitch = pitch; #end
		if (afterLoad != null)
			afterLoad(audio);
	}

	/**
	 * Sets the song inst it should play.
	 * @param song The name of the song.
	 * @param variant The variant of the song to play.
	 * @param afterLoad Function that runs after the audio has loaded.
	 */
	public function loadSong(song:String, variant:String = 'normal', ?afterLoad:FlxSound->Void):Void {
		reset();
		if (audio == null)
			audio = FlxG.sound.list.add(new FlxSound());

		audio.loadEmbedded(Assets.inst(song, variant));
		FlxG.sound.loadHelper(audio, 1, soundGroup);
		audio.persist = true;

		data = getMetadata('content/songs/$song/audio${variant == 'normal' ? '' : '-$variant'}');
		applyBPMChanges();

		#if FLX_PITCH pitch = pitch; #end
		if (afterLoad != null)
			afterLoad(audio);
	}

	/**
	 * Adds an extra music track to run.
	 * @param music The name of the audio file.
	 * @param afterLoad Function that runs after the audio has loaded.
	 * @return `FlxSound` ~ Added audio track.
	 */
	public function addExtraAudio(music:ModPath, ?afterLoad:FlxSound->Void):FlxSound {
		var file:ModPath = Paths.music(music);
		if (!Paths.fileExists(file)) {
			log('Failed to find audio "${music.format()}".', WarningMessage);
			return null;
		}
		var music:FlxSound = FlxG.sound.list.add(new FlxSound());

		music.loadEmbedded(Assets.music(file));
		FlxG.sound.loadHelper(music, 1, soundGroup);
		music.persist = true;

		#if FLX_PITCH music.pitch = pitch; #end
		extra.push(music);
		if (afterLoad != null)
			afterLoad(music);
		return music;
	}

	/**
	 * Adds a vocal track to run, used for songs.
	 * @param song The name of the song.
	 * @param suffix The vocal suffix.
	 * @param variant The variant of the vocals to play.
	 * @param afterLoad Function that runs after the audio has loaded.
	 * @return `FlxSound` ~ Added vocal track.
	 */
	public function addVocalTrack(song:String, suffix:String, variant:String = 'normal', ?afterLoad:FlxSound->Void):FlxSound {
		var file:ModPath = Paths.vocal(song, suffix, variant);
		if (!Paths.fileExists(file)) {
			log('Failed to find ${suffix.isNullOrEmpty() ? 'base ' : ''}vocal track for song "$song"${variant == 'normal' ? '' : ', variant "$variant"'}${suffix.isNullOrEmpty() ? '' : ' with a suffix of "$suffix"'}.', WarningMessage);
			return null;
		}
		var vocals:FlxSound = FlxG.sound.list.add(new FlxSound());

		vocals.loadEmbedded(Assets.vocal(song, suffix, variant));
		FlxG.sound.loadHelper(vocals, 1, soundGroup);
		vocals.persist = true;

		#if FLX_PITCH vocals.pitch = pitch; #end
		extra.push(vocals);
		if (afterLoad != null)
			afterLoad(vocals);
		return vocals;
	}

	/**
	 * Sets the song it should play.
	 * @param song The name of the song.
	 * @param difficulty The difficulty of to chart load from.
	 * @param variant The variant of the song to play.
	 * @param afterLoad Function that runs after the audio has loaded.
	 * @return `ChartData`
	 */
	public function loadFullSong(song:String, difficulty:String, variant:String = 'normal', ?afterLoad:FlxSound->Void):Null<imaginative.states.editors.ChartEditor.ChartData> {
		var chart:imaginative.states.editors.ChartEditor.ChartData = null;
		loadSong(song, variant, (_:FlxSound) -> {
			try {
				chart = ParseUtil.chart(song, difficulty, variant);
				var vocalSuffixes:Array<String> = [];
				for (base in chart.characters) {
					var charVocals:String = null;
					try {
						charVocals = ParseUtil.object('characters/${base.name}', IsCharacterSprite).character.vocals;
					} catch(error:haxe.Exception) {}
					var suffix:String = base.vocals ?? charVocals ?? base.tag; // since charVocals can be name, i'ma just go with this
					if (!vocalSuffixes.contains(suffix))
						vocalSuffixes.push(suffix);
				}
				var tracks:Array<FlxSound> = [];
				for (suffix in vocalSuffixes) {
					var track:Null<FlxSound> = addVocalTrack(song, suffix, variant);
					if (track != null)
						tracks.push(track);
				}
				// loads main suffixes
				if (tracks.empty()) {
					var enemyTrack:FlxSound = addVocalTrack(song, 'Enemy', variant);
					if (enemyTrack != null)
						tracks.push(enemyTrack);
					var playerTrack:FlxSound = addVocalTrack(song, 'Player', variant);
					if (playerTrack != null)
						tracks.push(playerTrack);
				}
				// loads general track
				if (tracks.empty())
					addVocalTrack(song, '', variant);
			} catch(error:haxe.Exception) {
				log('Chart parse for song "$song"${variant.trim() == 'normal' ? '' : ', variant "${FunkinUtil.getDifficultyDisplay(variant)}"'} failed.', ErrorMessage);

				var tracks:Array<FlxSound> = [];
				// loads main suffixes
				var enemyTrack:FlxSound = addVocalTrack(song, 'Enemy', variant);
				if (enemyTrack != null)
					tracks.push(enemyTrack);
				var playerTrack:FlxSound = addVocalTrack(song, 'Player', variant);
				if (playerTrack != null)
					tracks.push(playerTrack);
				// loads general track
				if (tracks.empty())
					addVocalTrack(song, '', variant);
			}

			if (afterLoad != null)
				afterLoad(_);
		});
		return chart;
	}

	/**
	 * Get's song metadata.
	 * @param file Json path for the metadata.
	 * @return `AudioData`
	 */
	public function getMetadata(file:String):AudioData {
		try {
			var jsonPath:ModPath = Paths.json(file);
			var content:AudioData = new json2object.JsonParser<AudioData>().fromJson(Assets.text(jsonPath), jsonPath.format());
			if (content == null) {
				log('$file: Metadata parse failed.', ErrorMessage);
				return {
					artist: 'Unassigned',
					name: 'None',
					bpm: 100,
					signature: [4, 4],
					checkpoints: [],
					offset: 0
				}
			}
			return content;
		} catch(error:haxe.Exception) {
			log('$file: ${error.message}', ErrorMessage);
			return {
				artist: 'Unassigned',
				name: 'None',
				bpm: 100,
				signature: [4, 4],
				checkpoints: [],
				offset: 0
			}
		}
	}

	var _printResyncMessage(null, null):Bool = false;
	/**
	 * Resync's the extra tracks to the inst time when called.
	 * @param force If true, it will force the vocals to resync.
	 */
	inline public function resyncVocals(force:Bool = false):Void {
		if ((force || !playing) && !autoSetTime) return;
		_printResyncMessage = false;
		for (sound in soundGroup.sounds) {
			// idea from psych
			if (audio.time < sound.length) {
				if (force || Math.abs(time - sound.time) > 25) {
					sound.pause();
					sound.time = time;
					sound.play();
					_printResyncMessage = true;
				}
			} else if (sound.playing)
				sound.pause();
		}
		if (_printResyncMessage)
			_log(force ? 'Manually resynced Conductor "$id".' : 'Conductor "$id" resynced all tracks to it\'s time.', SystemMessage);
	}

	@SuppressWarnings('checkstyle:FieldDocComment')
	public function update():Void {
		if (!playing)
			return;

		if (audio == null) {
			prevTime = audio == null ? 0 : (audio.playing ? audio.time : time);
			return;
		} else { // jic
			if (audio.onComplete != onCompleteFunc)
				audio.onComplete = onCompleteFunc;
		}

		if (!audio.playing && !autoSetTime)
			audio.play();
		if (audio.playing && autoSetTime)
			audio.pause();

		if (audio.playing && !audioEnded) {
			if (prevTime != (prevTime = audio.time))
				time = prevTime; // update conductor
			else time += FlxG.elapsed * 1000;
			resyncVocals();
		} else time += FlxG.elapsed * 1000;

		if (bpm > 0 || beatsPerMeasure > 0 || stepsPerBeat > 0) {
			var lastChange:BPMChange = {
				stepTime: 0,
				songTime: 0,
				bpm: 0,
				beatsPM: 0,
				stepsPB: 0
			}
			for (change in bpmChanges)
				if (time >= change.songTime)
					lastChange = change;

			if (
				(lastChange.bpm > 0 && bpm != lastChange.bpm) /* ||
				(lastChange.beatsPM > 0 && beatsPerMeasure != lastChange.beatsPM) ||
				(lastChange.stepsPB > 0 && stepsPerBeat != lastChange.stepsPB) */
			) changeBPM(lastChange.bpm);

			// beat and measure versions update automatically
			curStepFloat = lastChange.stepTime + ((time - lastChange.songTime) / stepTime);

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

	var _wasPlaying(null, null):Bool = false;
	inline function onFocus():Void {
		if (FlxG.autoPause) {
			playing = _wasPlaying;
			if (_wasPlaying)
				soundGroup.resume();
		}
	}
	inline function onFocusLost():Void {
		if (FlxG.autoPause) {
			_wasPlaying = playing;
			soundGroup.pause();
		}
	}

	@:allow(imaginative.backend.music.states.BeatState) static var beatStates:Array<BeatState> = [];
	@:allow(imaginative.backend.music.states.BeatSubState) static var beatSubStates:Array<BeatSubState> = [];
	function callToState(timeType:SongTimeType, curTime:Int):Void {
		for (state in beatStates)
			if (state != null && state.conductor == this && (state.persistentUpdate || state.subState == null))
				switch (timeType) {
					case IsStep:
						state.stepHit(curTime);
						GlobalScript.stepHit(curTime, state.conductor);
					case IsBeat:
						state.beatHit(curTime);
						GlobalScript.beatHit(curTime, state.conductor);
					case IsMeasure:
						state.measureHit(curTime);
						GlobalScript.measureHit(curTime, state.conductor);
				}
		for (state in beatSubStates)
			if (state != null && state.conductor == this && (state.persistentUpdate || state.subState == null))
				switch (timeType) {
					case IsStep:
						state.stepHit(curTime);
					case IsBeat:
						state.beatHit(curTime);
					case IsMeasure:
						state.measureHit(curTime);
				}
	}

	/**
	 * Runs when the next step happens.
	 * @param curStep The current step.
	 */
	inline public function stepHit(curStep:Int):Void {
		onStepHit.dispatch(curStep);
		callToState(IsStep, curStep);
	}
	/**
	 * Runs when the next beat happens.
	 * @param curBeat The current beat.
	 */
	inline public function beatHit(curBeat:Int):Void {
		onBeatHit.dispatch(curBeat);
		callToState(IsBeat, curBeat);
	}
	/**
	 * Runs when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	inline public function measureHit(curMeasure:Int):Void {
		onMeasureHit.dispatch(curMeasure);
		callToState(IsMeasure, curMeasure);
	}

	/**
	 * Changes the current BPM of this part of the song.
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
		changeBPM(startBpm = prevBpm = data.bpm, data.signature[0], data.signature[1]);

		var curBPM:Float = data.bpm;
		var curSig:Array<Int> = data.signature;
		var songTime:Float = 0;
		var stepTime:Float = 0;
		for (checkpoint in data.checkpoints) {
			if (
				checkpoint.bpm == curBPM /* &&
				curSig[0] == checkpoint.signature[0] &&
				curSig[1] == checkpoint.signature[1] */
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

		for (sound in soundGroup.sounds)
			destroySound(sound);
		extra = [];
	}
}