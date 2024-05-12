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

	public static var storyDifficulty:Int = 1;

	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;

	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulties:Array<String> = [];
	public static var curDifficulty:String = 'Normal';

	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;

	public static var seenCutscene:Bool = false;
	public static var daPixelZoom:Float = 6;
	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 0.9;

	public var characters:Array<Character> = [];
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var camGame:FunkinCamera;
	public var camHUD:FlxCamera;

	public var camPoint:CameraPoint;

	public var playField:PlayField;
	public var maxHealth:Float = 2;
	public var health(default, set):Float = 1;
	inline function set_health(value:Float):Float return health = FlxMath.bound(value, 0, maxHealth);

	public static var curStage:String = '';

	// for convenience sake
	// and my sanity
	// - Zyflx

	public var playerStrumLine(get, never):StrumGroup;
	public var opponentStrumLine(get, never):StrumGroup;
	inline function get_playerStrumLine():StrumGroup return playField.playerStrumLine;
	inline function get_opponentStrumLine():StrumGroup return playField.opponentStrumLine;

	override function create():Void {
		direct = this;
		health = maxHealth / 2;

		camGame = new FunkinCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor = FlxColor.TRANSPARENT;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.add(camHUD, false);

		characters.push(dad = new Character(100, 100, false, 'boyfriend', 'normal'));
		characters.push(gf = new Character(400, 130, false, 'gf', 'none'));
		characters.push(boyfriend = new Character(770, 100, true, 'boyfriend', 'normal'));
		add(dad);
		add(gf);
		add(boyfriend);

		var lol:FlxPoint = dad.getCamPos();
		camPoint = new CameraPoint(lol.x, lol.y, 0.04);
		lol.putWeak();
		camPoint.offsetLerp = function():Float return camPoint.pointLerp * 1.5;
		// camPoint.setPoint(camPos.x, camPos.y);
		add(camPoint);

		FlxG.camera.follow(camPoint.realPosFollow, LOCKON, 999999999); // Edit followLerp from the CameraPoint's pointLerp and offsetLerp vars.
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