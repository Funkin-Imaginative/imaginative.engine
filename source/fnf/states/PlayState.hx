package fnf.states;

import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.ui.FlxBar;

import fnf.states.menus.StoryMenuState;

import fnf.objects.BGSprite;
import fnf.objects.Character;
import fnf.objects.PlayField;
import fnf.objects.FunkinBar;
import fnf.objects.background.*;
import fnf.objects.note.groups.*;
import fnf.objects.note.*;

import fnf.ui.DialogueBox;
import fnf.ui.HealthIcon;

import fnf.graphics.FunkinCamera;
import fnf.graphics.shaders.WiggleEffect;
import fnf.graphics.shaders.WiggleEffect.WiggleEffectType;
import fnf.graphics.shaders.BuildingShaders.BuildingShader;
import fnf.graphics.shaders.BuildingShaders;
import fnf.graphics.shaders.ColorSwap;

class PlayState extends MusicBeatState {
	public static var direct:PlayState = null; // SCRIPTING BABY

	// keeping for now since there static and get used in other states
	public static var storyDifficulty:Int = 1;
	public static var daPixelZoom:Float = 6;
	public var curSong:String = '';

	public static var SONG:SwagSong;

	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var campaignList:Array<String> = [];
	public static var difficulties:Array<String> = [];
	public static var curDifficulty:String = 'Normal';

	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;

	public static var campaignScore:Int = 0;
	public static var seenCutscene:Bool = false;
	public var inCutscene:Bool = false;

	public var defaultCamZoom:Float = 0.9;

	public var characters(default, never):Array<Character> = [];
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	// may or may not keep
	public var gfSpeed(get, set):Int;
	inline function set_gfSpeed(value:Int):Int return gf.bopSpeed = value;
	inline function get_gfSpeed():Int return gf.bopSpeed;

	public var camGame:FunkinCamera;
	public var camHUD:FlxCamera;

	public var camPoint:CameraPoint;
	@:isVar public var cameraSpeed(get, set):Float;
	inline function get_cameraSpeed():Float return camPoint.lerpMult;
	inline function set_cameraSpeed(value:Float):Float return camPoint.lerpMult = value;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var vocalsFinished:Bool = false;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var startedCountdown:Bool = false;
	public var canPause:Bool = true;

	public static var curStage:String = '';
	public var gameScripts:ScriptGroup;

	/**
	 * for convenience sake
	 * and my sanity
	 * @Zyflx
	 */
	public var playField(default, null):PlayField;
	public var strumLines(get, never):Array<StrumGroup>;
	public var opponentStrumLine(get, never):StrumGroup;
	public var playerStrumLine(get, never):StrumGroup;
	public var healthBar(get, never):FunkinBar;
	inline function get_strumLines():Array<StrumGroup> return playField.strumLines;
	inline function get_opponentStrumLine():StrumGroup return playField.opponentStrumLine;
	inline function get_playerStrumLine():StrumGroup return playField.playerStrumLine;
	inline function get_healthBar():FunkinBar return playField.healthBar;

	public var minHealth(get, set):Float; // >:)
	inline function get_minHealth():Float return playField.minHealth;
	inline function set_minHealth(value:Float):Float return playField.minHealth = value;
	public var health(get, set):Float;
	inline function get_health():Float return playField.health;
	inline function set_health(value:Float):Float return playField.health = value;
	public var maxHealth(get, set):Float;
	inline function get_maxHealth():Float return playField.maxHealth;
	inline function set_maxHealth(value:Float):Float return playField.maxHealth = value;

	override public function create():Void {
		direct = this;
		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		persistentUpdate = persistentDraw = true;

		gameScripts = new ScriptGroup(this);
		if (SONG == null) SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		Conductor.songPosition = -5000;

		FlxG.cameras.reset(camGame = new FunkinCamera());
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor = FlxColor.TRANSPARENT;

		persistentUpdate = persistentDraw = true;
		gameScripts.load();

		characters.push(dad = new Character(100, 100, false, 'boyfriend', 'normal'));
		characters.push(boyfriend = new Character(770, 100, true, 'boyfriend', 'normal'));
		characters.push(gf = new Character(400, 130, false, 'gf', 'none'));
		add(gf);
		add(dad);
		add(boyfriend);

		playField = new PlayField(this);
		playField.cameras = [camHUD];
		add(playField);

		generateSong();


		var lol:FlxPoint = dad.getCamPos();
		camPoint = new CameraPoint(lol.x, lol.y, 0.04);
		camPoint.offsetLerp = function():Float return camPoint.pointLerp * 1.5;
		camPoint.setPoint(lol.x, lol.y);
		add(camPoint);
		lol.putWeak();

		FlxG.camera.follow(camPoint.realPosFollow, LOCKON, 0.04); // Edit followLerp from the CameraPoint's pointLerp and offsetLerp vars.
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.followLerp = 0.04;
		camPoint.snapPoint();

		gameScripts.call('create');

		startingSong = true;
		if (isStoryMode && !seenCutscene) {
			// inCutscene = true;
			switch (curSong) {
				default:
					startCountdown();
			}
		} else startCountdown();

		super.create();
		gameScripts.call('createPost');

		@:privateAccess StrumGroup.baseSignals.noteHit.add(function(note:Note) {
			if (!note.wasHit) {
				if (!note.isSustainNote) {
					// combo += 1;
					// popUpScore(note.strumTime, note);
				}

				health += 0.023;

				boyfriend.playSingAnim(note.ID, '', false, true);
				playerStrumLine.members[note.ID].playAnim('confirm', true);
				// if (cameraRightSide) {
				// 	var ah = hate(note.ID);
				// 	camPoint.setOffset(ah[0] / FlxG.camera.zoom, ah[1] / FlxG.camera.zoom);
				// }
				// if (coolCamReturn != null) coolCamReturn.cancel();
				// coolCamReturn.start((Conductor.stepCrochet / 1000) * (note.isSustainNote ? 0.6 : 1.6), function(timer:FlxTimer) camPoint.setOffset());

				note.wasHit = true;
				vocals.volume = 1;

				/* if (!note.isSustainNote) {
					note.kill();
					notes.remove(note, true);
					note.destroy();
				} */
			}
		});
		@:privateAccess StrumGroup.baseSignals.noteMiss.add(function(note:Note) {
			// whole function used to be encased in if (!boyfriend.stunned)
			health -= 0.04;
			// killCombo();

			// if (!practiceMode) songScore -= 10;

			vocals.volume = 0;
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			boyfriend.playSingAnim(note.ID, '', true, true);
			// if (coolCamReturn != null) coolCamReturn.cancel();
			// camPoint.setOffset();
			// camPoint.snapPoint();
		});
	}

	override public function openSubState(SubState:FlxSubState) {
		gameScripts.call('openingSubState', [SubState]);
		if (paused) {
			for (strumLine in strumLines) strumLine.vocals.pause();
			vocals.pause();
			inst.pause();
			if (!countdownTimer.finished) countdownTimer.active = false;
		}
		super.openSubState(SubState);
	}
	override public function closeSubState() {
		gameScripts.call('closingSubState', [subState]);
		if (paused) {
			for (strumLine in strumLines) strumLine.vocals.resume();
			vocals.resume();
			inst.resume();
			if (!countdownTimer.finished) countdownTimer.active = true;
		}
		super.closeSubState();
	}

	public var countdownLength:Int = 4;
	public var countdownTimer:FlxTimer = new FlxTimer();
	public function startCountdown() {
		inCutscene = false;
		for (strumLine in strumLines) {
			for (index => strum in strumLine) {
				if (!isStoryMode) {
					strum.y -= 10;
					strum.alpha = 0;
					FlxTween.tween(strum, {y: strum.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * index)});
				}
			}
		}

		gameScripts.call('onStartCountdown');

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * countdownLength;

		var onCount:Int = 0;
		countdownTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
			for (char in characters)
				if (!char.preventIdleBopping && onCount % Math.round(char.bopSpeed * char.beatInterval) == 0)
					char.tryDance();

			var introSprPaths:Array<String> = ['', 'ready', 'set', 'go'];
			var altSuffix:String = '';

			if (curStage.startsWith('school')) {
				altSuffix = '-pixel';
				introSprPaths = ['', 'weeb/pixelUI/ready', 'weeb/pixelUI/set', 'weeb/pixelUI/date'];
			}

			var introSndPaths:Array<String> = ['intro3', 'intro2', 'intro1', 'introGo'];

			if (onCount > 0) {
				var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introSprPaths[onCount] + altSuffix));
				if (curStage.startsWith('school')) spr.setGraphicSize(Std.int(spr.width * daPixelZoom));
				spr.updateHitbox();
				spr.screenCenter();
				spr.cameras = [camHUD];
				add(spr);
				FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(tween:FlxTween) {spr.destroy();}
				});
			}
			FlxG.sound.play(Paths.sound(introSndPaths[onCount] + altSuffix), 0.6);

			onCount += 1;
		}, countdownLength);
		gameScripts.call('onStartCountdownPost');
	}

	private function generateSong():Void {
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		curSong = songData.song;

		FlxG.sound.music = inst = FlxG.sound.load(Paths.inst(SONG.song));
		vocals = FlxG.sound.load(Paths.voices(SONG.song));

		inst.group = FlxG.sound.defaultMusicGroup;
		vocals.group = FlxG.sound.defaultMusicGroup;
		inst.persist = vocals.persist = false;

		for (strumLine in strumLines) @:privateAccess strumLine.generateNotes(songData.notes);

		generatedMusic = true;
	}

	function startSong():Void {
		startingSong = false;
		// inst.onComplete = endSong;
		if (!paused) inst.play();

		if (vocals == null) vocals = new FlxSound();
		vocals.onComplete = function() vocalsFinished = true;
		if (!paused) vocals.play();
		for (strumLine in strumLines) {
			if (strumLine.vocals == null) strumLine.vocals = new FlxSound();
			strumLine.vocals.onComplete = function() strumLine.vocalsFinished = true;
			if (!paused) strumLine.vocals.play();
		}
	}

	override public function beatHit():Void {
		super.beatHit();
		for (char in characters)
			if (!char.preventIdleBopping && curBeat % Math.round(char.bopSpeed * char.beatInterval) == 0)
				char.tryDance();
	}

	var __vocalOffsetViolation:Float;
	override public function update(elapsed:Float):Void {
		gameScripts.call('update', [elapsed]);

		if (inCutscene) {
			super.update(elapsed);
			gameScripts.call('updatePost', [elapsed]);
			return;
		}

		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += elapsed * 1000;
				if (Conductor.songPosition >= 0) {
					startSong();
				}
			}
		} else {
			Conductor.songPosition = inst.time;

			// using cne's since being on update instead is definitely 10x better... plus idk how else to make this better XD
			var instTime:Float = inst.time;
			var isOffsync:Bool = vocals.time != instTime || [for(strumLine in strumLines) strumLine.vocals.time != instTime].contains(true);
			__vocalOffsetViolation = Math.max(0, __vocalOffsetViolation + (isOffsync ? elapsed : -elapsed / 2));
			if (__vocalOffsetViolation > 25) {
				resyncVocals();
				__vocalOffsetViolation = 0;
			}
		}

		super.update(elapsed);
		if (controls.PAUSE && startedCountdown && canPause) {
			// 1 / 1000 chance for Gitaroo Man easter egg
			paused = true;
			if (FlxG.random.bool(0.1)) FlxG.switchState(new GitarooPause()); // gitaroo man easter egg
			else openSubState(new fnf.states.sub.PauseSubState());
		}

		gameScripts.call('updatePost', [elapsed]);
	}

	function resyncVocals() {
		for (strumLine in strumLines) strumLine.vocals.pause();
		vocals.pause();
		Conductor.songPosition = inst.time;
		vocals.time = Conductor.songPosition;
		for (strumLine in strumLines) {
			strumLine.vocals.time = vocals.time;
			strumLine.vocals.resume();
		}
		vocals.resume();
		gameScripts.call('resyncedVocals');
	}

	override public function onFocus():Void {
		if (!paused && FlxG.autoPause) {
			for (strumLine in strumLines) strumLine.vocals.resume();
			vocals.resume();
			inst.resume();
		}
		gameScripts.call('focus');
		super.onFocus();
	}
	override public function onFocusLost():Void {
		if (!paused && FlxG.autoPause) {
			for (strumLine in strumLines) strumLine.vocals.pause();
			vocals.pause();
			inst.pause();
		}
		if (SaveManager.getOption('gameplay.pauseOnLostFocus') && canPause && !paused) {
			paused = true;
			openSubState(new fnf.states.sub.PauseSubState());
		}
		gameScripts.call('lostFocus');
		super.onFocusLost();
	}

	override public function destroy():Void {
		gameScripts.destroy();
		direct = null;
		super.destroy();
	}
}