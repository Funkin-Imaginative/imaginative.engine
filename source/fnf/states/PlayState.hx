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
	public static var direct:PlayState = null;

	public static var storyDifficulty:Int = 1; // keeping for now

	public static var SONG:SwagSong;

	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulties:Array<String> = [];
	public static var curDifficulty:String = 'Normal';

	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;

	public static var seenCutscene:Bool = false;
	public static var daPixelZoom:Float = 6; // keeping for now
	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 0.9;

	public var characters(default, never):Array<Character> = [];
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var camGame:FunkinCamera;
	public var camHUD:FlxCamera;

	public var camPoint:CameraPoint;

	public var health(default, set):Float;
	public var maxHealth(default, set):Float = 2;
	inline function set_health(value:Float):Float return health = FlxMath.bound(value, 0, maxHealth);
	inline function set_maxHealth(value:Float):Float {
		if (healthBar != null && healthBar.max == maxHealth)
			healthBar.setRange(healthBar.min, value);
		return maxHealth = value;
	}

	public static var curStage:String = '';
	public var scripts:ScriptGroup;

	// for convenience sake
	// and my sanity
	// - Zyflx

	public var playField(default, null):PlayField;
	public var playerStrumLine(get, never):StrumGroup;
	public var opponentStrumLine(get, never):StrumGroup;
	public var healthBar(get, never):FunkinBar;
	inline function get_playerStrumLine():StrumGroup return playField.playerStrumLine;
	inline function get_opponentStrumLine():StrumGroup return playField.opponentStrumLine;
	inline function get_healthBar():FunkinBar return playField.healthBar;

	override function create():Void {
		direct = this;
		health = maxHealth / 2;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		persistentUpdate = persistentDraw = true;

		(scripts = new ScriptGroup('PlayState')).setParent(this);
		if (SONG == null) SONG = Song.loadFromJson('tutorial');

		FlxG.cameras.reset(camGame = new FunkinCamera());
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor = FlxColor.TRANSPARENT;

		characters.push(dad = new Character(100, 100, false, 'boyfriend', 'normal'));
		characters.push(gf = new Character(400, 130, false, 'gf', 'none'));
		characters.push(boyfriend = new Character(770, 100, true, 'boyfriend', 'normal'));
		add(dad);
		add(gf);
		add(boyfriend);

		var lol:FlxPoint = dad.getCamPos();
		camPoint = new CameraPoint(lol.x, lol.y, 0.04);
		camPoint.offsetLerp = function():Float return camPoint.pointLerp * 1.5;
		camPoint.setPoint(lol.x, lol.y);
		add(camPoint);
		lol.putWeak();

		FlxG.camera.follow(camPoint.realPosFollow, LOCKON, 0.04); // Edit followLerp from the CameraPoint's pointLerp and offsetLerp vars.
		FlxG.camera.zoom = defaultCamZoom;
		camPoint.snapPoint();
		FlxG.camera.followLerp = 0.04;

		playField = new PlayField(this);
		playField.cameras = [camHUD];
		add(playField);

		super.create();
	}

	override function beatHit():Void {
		super.beatHit();
		for (char in characters)
			if (!char.preventIdleOnBeat && curBeat % char.beatInterval == 0)
				char.tryDance();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	override function destroy():Void {
		direct = null;
		super.destroy();
	}
}