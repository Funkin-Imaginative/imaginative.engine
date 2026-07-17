package imaginative.backend.systems;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

// @:autoBuild(imaginative.backend.macro.ConductorReactiveMacro.build())
interface IConductorReactive {}

typedef MusicMeta = {
	/**
	 * The song id / folder name.
	 */
	var ?id:ModPath;
	/**
	 * The display name of the song.
	 */
	var name:String;
	/**
	 * The person (or people) who composed the song.
	 */
	var composer:String;
	/**
	 * The list of time changes in the song.
	 */
	var ?checkpoints:Array<CheckpointMeta>;
	/**
	 * How long the song is **(in steps)**.
	 */
	var ?length:Float;
}

typedef RawCheckpointMeta = {
	/**
	 * The time of the change **(in milliseconds, eventually steps maybe?)**.
	 */
	var time:Float;
	/**
	 * The BPM of the change.
	 */
	var bpm:Float;
	/**
	 * The time signature of the change.
	 */
	var signature:Array<Int>;
}
@:forward abstract CheckpointMeta(RawCheckpointMeta) {
	/**
	 * The time signature numerator.
	 */
	public var beatsPerMeasure(get, set):Int;
	inline function get_beatsPerMeasure():Int return this.signature[0];
	inline function set_beatsPerMeasure(value:Int):Int return this.signature[0] = value;
	/**
	 * The time signature denominator.
	 */
	public var stepsPerBeat(get, set):Int;
	inline function get_stepsPerBeat():Int return this.signature[1];
	inline function set_stepsPerBeat(value:Int):Int return this.signature[1] = value;

	public var stepsPerMeasure(get, never):Int;
	inline function get_stepsPerMeasure():Int return beatsPerMeasure * stepsPerBeat;
}

class Conductor extends flixel.FlxBasic {
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

	@:unreflective inline static function init():Void {
		menu = new Conductor('Menu', true);
		song = new Conductor('Song');
		cutscene = new Conductor('Cutscene', true);
		charter = new Conductor('Charter');
	}

	/**
	 * The conductor id.
	 *
	 * This is completely optional and is only used in the debug console.
	 */
	public final id:String;

	/**
	 * If true, when the audio ends, it will loop.
	 */
	public var canLoop:Bool;

	var group:FlxSoundGroup;

	/**
	 * Whether the conductor is playing or not.
	 */
	public var playing(default, null):Bool = false;

	/**
	 * The volume of the conductor.
	 */
	public var volume(get, set):Float;
	inline function get_volume():Float return group.volume;
	inline function set_volume(value:Float):Float return group.volume = value;

	/**
	 * How fast the song should play.
	 */
	public var rate(default, set):Float;
	inline function set_rate(value:Float):Float {
		for (sound in group.sounds)
			sound.pitch = value;
		return value;
	}

	/**
	 * The current song time **(in milliseconds)**.
	 */
	public var time(default, null):Float = 0;

	public function new(id:String = 'Unknown', canLoop:Bool = false) {
		super();

		this.id = id;
		this.canLoop = canLoop;
		group = new FlxSoundGroup();

		FlxG.signals.focusGained.add(onFocus);
		FlxG.signals.focusLost.add(onFocusLost);
		FlxG.plugins.addPlugin(this);
	}

	/**
	 * Plays the conductor's audio.
	 * @param startTime The starting time. **Can be negative.**
	 * @param startVolume The starting volume.
	 */
	inline public function play(startTime:Float = 0, startVolume:Float = 1):Void {
		time = startTime;
		volume = startVolume;
		playing = true;
		resyncVocals(true);
	}

	/**
	 * Pauses the conductor's audio.
	 */
	inline public function pause():Void {
		group.pause();
		playing = false;
	}

	/**
	 * Resumes the conductor's audio.
	 */
	inline public function resume():Void {
		group.resume();
		playing = true;
		resyncVocals(true);
	}

	/**
	 * Stops the conductor's audio.
	 */
	inline public function stop():Void {
		stopFade();
		for (sound in group.sounds)
			sound.stop();
		playing = false;
	}

	/**
	 * Resets the conductor.
	 */
	inline public function reset():Void {
		stop();
		for (sound in group.sounds) {
			if (sound.group != null)
				if (group.sounds.contains(sound))
					group.remove(sound);
				else if (sound.group.sounds.contains(sound))
					sound.group.remove(sound);
			sound.destroy();
		}

		// TODO: do rest
	}

	/**
	 * Pulled the fade code from FlxSound, lmao.
	 */
	var fadeTween:FlxTween;
	/**
	 * Fades in the conductor's audio.
	 *
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
	 * Fades out the conductor's audio.
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
	 * Sets up music to play.
	 * @param music The music id.
	 * @param cacheType The cache type.
	 * @param persistenceType The persistence level.
	 */
	public function loadMusic(music:ModPath, cacheType:CacheType = CacheAsset, persistenceType:PersistenceType = IsVulnerable):Void {
		reset();
		var audio:FlxSound = FlxG.sound.load(Assets.music(music, cacheType, persistenceType, true), group);
		if (@:privateAccess audio._sound != null) {
			#if FLX_PITCH audio.pitch = rate; #end
			audio.persist = true;
		} else group.remove(audio);
		getMetadata(music.path, Paths.music(music), cacheType);
	}
	/**
	 * Sets up a song to play.
	 * @param song The song id.
	 * @param variant The variation key. **Can be null.**
	 * @param reloadCache If true, it reloads the cache.
	 */
	public function loadSong(song:ModPath, ?variant:String, reloadCache:Bool = false):Void {
		reset();
		var audio:FlxSound = FlxG.sound.load(Assets.inst(song, variant, reloadCache, true), group);
		if (@:privateAccess audio._sound != null) {
			#if FLX_PITCH audio.pitch = rate; #end
			audio.persist = true;
		} else group.remove(audio);
		getMetadata(song.path, Paths.inst(song, variant), reloadCache ? OverrideCache : CacheAsset);
	}

	static function getMetadata(id:String, path:ModPath, cacheType:CacheType):MusicMeta {
		var meta:MusicMeta = Assets.json(path, cacheType, true);
		if (meta == null) return {name: 'Failed Parse', composer: 'Failed Parse'}
		meta.id = new ModPath(id, path.type, path.moduleId);
		meta.composer ??= 'Unknown';
		return meta;
	}

	@:unreflective var _printResyncMessage:Bool = false;
	/**
	 * Resyncs all sounds to the conductor time when called.
	 * @param force If true, it will force a resync.
	 */
	inline public function resyncVocals(force:Bool = false):Void {
		if (force || !playing) return;
		_printResyncMessage = false;
		for (sound in group.sounds) {
			// idea from psych
			if (time < sound.length) {
				if (force || Math.abs(time - sound.time) > 5) {
					sound.play(true, time);
					_printResyncMessage = true;
				}
			} else if (sound.playing)
				sound.pause();
		}
		if (_printResyncMessage)
			trace(force ? 'Manually resynced Conductor "$id".' : 'Conductor "$id" resynced all tracks to it\'s time.');
	}

	var _elapsed:Float = 0;
	var processAnyway:Bool = false;
	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!playing) if (!processAnyway) return;

		if (playing) {
			// copied persnake's FlxRhythmConductor code, lol
			_elapsed = elapsed * 1000;
			time += _elapsed;
			resyncVocals();
		}

		// TODO: BPM shit
	}

	/**
	 * An internal variable that states if the song was playing before lost focus kicked in.
	 */
	@:unreflective var _wasPlaying:Bool = false;
	inline function onFocus():Void {
		if (FlxG.autoPause)
			if (_wasPlaying)
				resume();
	}
	inline function onFocusLost():Void {
		if (FlxG.autoPause) {
			_wasPlaying = playing;
			pause();
		}
	}

	override public function destroy():Void {
		reset();
		FlxG.plugins.remove(this);
		FlxG.signals.focusGained.remove(onFocus);
		FlxG.signals.focusLost.remove(onFocusLost);
		super.destroy();
	}
}