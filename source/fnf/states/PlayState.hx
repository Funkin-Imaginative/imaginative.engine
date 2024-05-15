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
	public var paused:Bool = false;
	public var startedCountdown:Bool = false;
	public var canPause:Bool = true;

	public static var curStage:String = '';
	public var scripts:ScriptGroup;

	/**
	 * for convenience sake
	 * and my sanity
	 * @Zyflx
	 */
	public var playField(default, null):PlayField;
	public var opponentStrumLine(get, never):StrumGroup;
	inline function get_opponentStrumLine():StrumGroup return playField.opponentStrumLine;
	public var playerStrumLine(get, never):StrumGroup;
	inline function get_playerStrumLine():StrumGroup return playField.playerStrumLine;
	public var healthBar(get, never):FunkinBar;
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

	override function create():Void {
		direct = this;
		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		persistentUpdate = persistentDraw = true;

		scripts = new ScriptGroup(this);
		if (SONG == null) SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		Conductor.songPosition = -5000;

		FlxG.cameras.reset(camGame = new FunkinCamera());
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor = FlxColor.TRANSPARENT;

		characters.push(dad = new Character(100, 100, false, 'boyfriend', 'normal'));
		characters.push(boyfriend = new Character(770, 100, true, 'boyfriend', 'normal'));
		characters.push(gf = new Character(400, 130, false, 'gf', 'none'));
		add(gf);
		add(dad);
		add(boyfriend);

		var lol:FlxPoint = dad.getCamPos();
		camPoint = new CameraPoint(lol.x, lol.y, 0.04);
		camPoint.offsetLerp = function():Float return camPoint.pointLerp * 1.5;
		camPoint.setPoint(lol.x, lol.y);
		add(camPoint);
		lol.putWeak();

		camPoint.snapPoint();
		FlxG.camera.follow(camPoint.realPosFollow, LOCKON, 0.04); // Edit followLerp from the CameraPoint's pointLerp and offsetLerp vars.
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.followLerp = 0.04;

		playField = new PlayField(this);
		playField.cameras = [camHUD];
		add(playField);

		super.create();
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

		for (strumLine in playField.strumLines) strumLine.generateSong(songData.notes);

		generatedMusic = true;
	}

	function startSong():Void {
		// startingSong = false;
		// FlxG.sound.setMusic(inst);
		// FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.play();

		if (vocals == null) vocals = new FlxSound();
		vocals.onComplete = function() vocalsFinished = true;
		vocals.play();
	}

	override function beatHit():Void {
		super.beatHit();
		for (char in characters)
			if (!char.preventIdleBopping && curBeat % Math.round(char.bopSpeed * char.beatInterval) == 0)
				char.tryDance();
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			// if (FlxG.sound.music != null) FlxG.sound.music.pause();
			// vocals.pause();

			// if (!startTimer.finished)
			// 	startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (controls.PAUSE && canPause) {
			persistentUpdate = false;
			persistentDraw = paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1)) FlxG.switchState(new GitarooPause()); // gitaroo man easter egg
			else openSubState(new fnf.states.sub.PauseSubState());
		}
	}

	override function onFocus():Void super.onFocus();
	override function onFocusLost():Void {
		super.onFocusLost();
		if (SaveManager.getOption('gameplay.pauseOnLostFocus') && canPause && !paused) {
			persistentUpdate = false;
			persistentDraw = paused = true;
			openSubState(new fnf.states.sub.PauseSubState());
		}
	}

	override function destroy():Void {
		direct = null;
		super.destroy();
	}
}