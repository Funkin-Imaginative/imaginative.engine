package fnf.states;

import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.ui.FlxBar;

import fnf.states.menus.StoryMenuState;

import fnf.objects.Character;
import fnf.objects.BetterBar;
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

class PlayState extends SongState implements ISong {
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
	public static var songScore:Int = 0;
	public var inCutscene:Bool = false;

	public var defaultCamZoom:Float = 0.9;

	public var characterMap:FunkinMap<Character> = new FunkinMap<Character>();
	public var enemy(get, never):Character; inline function get_enemy():Character return characterMap.getTopSlot('enemy');
	public var spectator(get, never):Character; inline function get_spectator():Character return characterMap.getTopSlot('spectator');
	public var player(get, never):Character; inline function get_player():Character return characterMap.getTopSlot('player');
	public function addCharToMap(tag:String, char:Character):Character {
		var resultChar:Character;
		if (characterMap.groupExists(tag)) resultChar = characterMap.addSlotMember(tag, char.charName, char);
		else resultChar = characterMap.createGroup(tag, char.charName, char);
		return resultChar;
	}

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

	/**
	 * for convenience sake
	 * and my sanity
	 * @Zyflx
	 */
	public var strumLines(get, never):Array<StrumGroup>; inline function get_strumLines():Array<StrumGroup> return playField.strumLines;
	public var enemyStrumLine(get, never):StrumGroup; inline function get_enemyStrumLine():StrumGroup return playField.enemyStrumLine;
	public var playerStrumLine(get, never):StrumGroup; inline function get_playerStrumLine():StrumGroup return playField.playerStrumLine;
	public var healthBar(get, never):BetterBar; inline function get_healthBar():BetterBar return playField.healthBar;

	public var minHealth(get, set):Float; // >:)
	inline function get_minHealth():Float return playField.minHealth;
	inline function set_minHealth(value:Float):Float return playField.minHealth = value;
	public var health(get, set):Float;
	inline function get_health():Float return playField.health;
	inline function set_health(value:Float):Float return playField.health = value;
	public var maxHealth(get, set):Float;
	inline function get_maxHealth():Float return playField.maxHealth;
	inline function set_maxHealth(value:Float):Float return playField.maxHealth = value;

	function getSpectatorNames(song:String):Array<String> {
		return switch (song) {
			case 'Satin Panties' | 'High' | 'M.I.L.F.': ['gf', 'windy'];
			case 'Cocoa' | 'Eggnog' | 'Winter Horrorland': ['gf', 'winterwear'];
			case 'Senpai' | 'Roses' | 'Thorns': ['gf', 'pixel'];
			case 'Ugh' | 'Guns': ['gf', 'tankmen'];
			case 'Stress': ['pico', 'speaker'];
			default: ['gf', 'normal'];
		}
	}

	function convertNames(name:String):Array<String> {
		return switch (name) {
			// boyfriend
			case 'bf': ['boyfriend', 'normal'];
			case 'bf-car': ['boyfriend', 'windy'];
			case 'bf-christmas': ['boyfriend', 'winterwear'];
			case 'bf-pixel': ['boyfriend', 'pixel'];
			case 'bf-holding-gf': ['boyfriend', 'holding-gf'];
			// gf
			case 'gf': ['gf', 'normal'];
			case 'gf-car': ['gf', 'windy'];
			case 'gf-christmas': ['gf', 'winterwear'];
			case 'gf-pixel': ['gf', 'pixel'];
			case 'gf-tankmen': ['gf', 'tankmen'];
			// mom
			case 'mom': ['mom', 'normal'];
			case 'mom-car': ['mom', 'windy'];
			// monster
			case 'monster': ['monster', 'normal'];
			case 'monster-christmas': ['monster', 'winterwear'];
			// dad&mom lol
			case 'parents-christmas': ['parents', 'winterwear'];
			// pico
			case 'pico': ['pico', 'normal'];
			case 'pico-speaker': ['pico', 'speaker'];
			// senpai
			case 'senpai': ['senpai', 'normal'];
			case 'senpai-angry': ['senpai', 'angry'];
			default: [name, 'none'];
		}
	}

	override public function create():Void {
		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		persistentUpdate = persistentDraw = true;

		scripts = new ScriptGroup(this);
		if (SONG == null) SONG = Song.loadFromJson('Tutorial', 'Normal');
		for (ext in Script.exts) {
			for (file in Paths.readFolder('songs', ext)) scripts.add(Script.create('songs/$file'));
			for (file in Paths.readFolder('songs/${SONG.song}', ext)) scripts.add(Script.create(file, 'song'));
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		FlxG.cameras.reset(camGame = new FunkinCamera());
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor = FlxColor.TRANSPARENT;

		scripts.load();

		var dadNaming:Array<String> = convertNames(SONG.player2);
		var gfNaming:Array<String> = getSpectatorNames(SONG.song);
		var boyfriendNaming:Array<String> = convertNames(SONG.player1);
		add(addCharToMap('spectator', new Character(400, 130, false, gfNaming[0], gfNaming[1])));
		add(addCharToMap('enemy', new Character(100, 100, false, dadNaming[0], dadNaming[1])));
		add(addCharToMap('player', new Character(770, 100, true, boyfriendNaming[0], boyfriendNaming[1])));

		var event:PlayFieldSetupEvent = scripts.event('playFieldSetup', new PlayFieldSetupEvent(enemy.icon, player.icon, [camHUD]));
		add(playField = new PlayField(this, event.enemyIcon, event.playerIcon)).cameras = event.cameras;
		enemyStrumLine.character = enemy;
		playerStrumLine.character = player;
		scripts.call('playFieldSetupPost', [event]);

		generateSong();
		scripts.call('create');

		var lol:PositionMeta = spectator.getCamPos();
		camPoint = new CameraPoint(lol.x, lol.y, 0.04);
		camPoint.offsetLerp = () -> return camPoint.pointLerp * 1.5;
		camPoint.setPoint(lol.x, lol.y);
		add(camPoint);

		FlxG.camera.follow(camPoint.realPosFollow, LOCKON, 0.04); // Edit followLerp from the CameraPoint's pointLerp and offsetLerp vars.
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.followLerp = 0.04;
		camPoint.snapPoint();

		startingSong = true;
		if (isStoryMode && !seenCutscene) {
			// inCutscene = true;
			switch (curSong) {
				default:
					startCountdown();
			}
		} else startCountdown();

		super.create();
		scripts.call('createPost');

		StrumGroup.hitFuncs.noteHit = (event:NoteHitEvent) -> {
			if (!event.note.isSustain && event.strumGroup.status) {
				// combo += 1;
				// popUpScore(event.note.strumTime, event.note);
			}

			if (facingPlayer == event.strumGroup.status) {
				var ah = hate(event.direction);
				camPoint.setOffset(ah[0] / FlxG.camera.zoom, ah[1] / FlxG.camera.zoom);
				camPoint.offsetLerp = () -> return camPoint.pointLerp * 1.5 / FlxG.camera.zoom;
			}
			if (coolCamReturn != null) coolCamReturn.cancel();
			coolCamReturn.start(
				(Conductor.stepCrochet / 1000) * (SaveManager.getOption('beatLoop') ? (!event.note.isSustain ? 1.6 : 0.6) : 1),
				(timer:FlxTimer) -> {
					camPoint.setOffset();
					camPoint.offsetLerp = () -> return camPoint.pointLerp * 1.5;
				}
			);

			vocals.volume = 1;
		}
		StrumGroup.hitFuncs.noteMiss = (event:NoteMissEvent) -> {
			// killCombo();

			// if (!practiceMode) songScore -= 10;

			vocals.volume = 0;

			// event.note.parentStrum.playAnim('press', true);
			if (coolCamReturn != null) coolCamReturn.cancel();
			camPoint.setOffset();
			camPoint.snapPoint();
		}
	}

	public var displacement:Float = 30;
	function hate(data:Int):Array<Float> {
		return [
			[-displacement, 0],
			[0, displacement],
			[0, -displacement],
			[displacement, 0]
		][data];
	}
	var coolCamReturn:FlxTimer = new FlxTimer();

	override public function openSubState(SubState:FlxSubState) {
		scripts.call('openingSubState', [SubState]);
		if (paused) {
			for (strumLine in strumLines) strumLine.vocals.pause();
			vocals.pause();
			inst.pause();
			if (!countdownTimer.finished) countdownTimer.active = false;
		}
		super.openSubState(SubState);
	}
	override public function closeSubState() {
		scripts.call('closingSubState', [subState]);
		if (paused) {
			for (strumLine in strumLines) strumLine.vocals.resume();
			vocals.resume();
			inst.resume();
			if (!countdownTimer.finished) countdownTimer.active = true;
		}
		super.closeSubState();
	}

	var fakeBeat:Int = 0;
	public var countdownLength:Int = 4;
	public var countdownTimer:FlxTimer = new FlxTimer();
	public var skipArrowTransition:Bool = false;
	public function startCountdown() {
		inCutscene = false;
		if (isStoryMode && !skipArrowTransition) {
			for (strumLine in strumLines) {
				for (index => strum in strumLine.members) {
					strum.y -= 10;
					strum.alpha = 0;
					FlxTween.tween(strum, {y: strum.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * index)});
				}
			}
		}

		scripts.call('onStartCountdown');

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * (countdownLength + 1);
		fakeBeat = (countdownLength + 1) * -1;

		var onCount:Int = 0;
		countdownTimer.start(Conductor.crochet / 1000, (timer:FlxTimer) -> {onCountdownTick(onCount, timer); onCount += 1;}, countdownLength + 1);
		scripts.call('onStartCountdownPost');
	}

	public function onCountdownTick(onTick:Int, ?timer:FlxTimer) {
		/* for (char in characterMap)
			if (onTick % Math.round(char.bopSpeed * char.beatInterval) == 0)
				char.tryDance(); */

		if (onTick != countdownLength + 1) {
			var introSprPaths:Array<String> = [
				'',
				'gameplay/countdown/ready',
				'gameplay/countdown/set',
				'gameplay/countdown/go'
			];
			var altSuffix:String = '';

			if (curStage.startsWith('school')) {
				altSuffix = '-pixel';
				introSprPaths = ['', 'weeb/pixelUI/ready', 'weeb/pixelUI/set', 'weeb/pixelUI/date'];
			}

			var introSndPaths:Array<String> = [
				'gameplay/countdown/intro3',
				'gameplay/countdown/intro2',
				'gameplay/countdown/intro1',
				'gameplay/countdown/introGo'
			];

			var spritePath:String = Paths.image(introSprPaths[onTick] + altSuffix);
			var soundPath:String = Paths.sound(introSndPaths[onTick] + altSuffix);
			if (FileSystem.exists(spritePath)) {
				var spr:FlxSprite = new FlxSprite(0, 0, spritePath);
				if (curStage.startsWith('school')) spr.setGraphicSize(Std.int(spr.width * daPixelZoom));
				spr.cameras = [camHUD];
				add(spr);
				spr.updateHitbox();
				spr.screenCenter();
				FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: (tween:FlxTween) -> spr.destroy()
				});
			}
			if (FileSystem.exists(soundPath)) FlxG.sound.play(soundPath, 0.6);
		}
		fakeBeat += 1;
		beatHit(fakeBeat);
	}

	override public function stepHit(curStep:Int) {
		super.stepHit(curStep);
		scripts.call('stepHit', [curStep]);
		resyncVocals();
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		scripts.call('beatHit', [curBeat]);
	}

	override public function measureHit(curMeasure:Int) {
		super.measureHit(curMeasure);
		if (generatedMusic && SONG.notes[curMeasure] != null)
			updateCamPos((facingPlayer = SONG.notes[curMeasure].mustHitSection) ? 'player' : 'enemy');
		scripts.call('measureHit', [curMeasure]);
	}

	private function generateSong():Void {
		var songData:SwagSong = SONG;
		Conductor.bpm = songData.bpm;
		curSong = songData.song;

		var instPath:String = Paths.inst(curSong);
		var vocalsPath:String = Paths.voices(curSong);

		FlxG.sound.music = inst = FileSystem.exists(instPath) ? FlxG.sound.load(instPath) : new FlxSound();
		vocals = FileSystem.exists(vocalsPath) ? FlxG.sound.load(vocalsPath) : new FlxSound();

		inst.group = vocals.group = FlxG.sound.defaultMusicGroup;
		inst.persist = vocals.persist = false;

		for (strumLine in strumLines) @:privateAccess strumLine.generateNotes(songData.notes);

		generatedMusic = true;
	}

	function startSong():Void {
		startingSong = false;
		inst.onComplete = endSong;
		if (!paused) inst.play();

		vocals.onComplete = () -> vocalsFinished = true;
		if (!paused) vocals.play();
		for (strumLine in strumLines) {
			strumLine.vocals.onComplete = () -> strumLine.vocalsFinished = true;
			if (!paused) strumLine.vocals.play();
		}
	}
	function endSong():Void {
		seenCutscene = canPause = false;
		inst.volume = vocals.volume = deathCounter = 0;
		for (strumLine in strumLines) strumLine.vocals.volume = 0;
		// if (SONG.validScore) Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (isStoryMode) {
			campaignScore += songScore;

			campaignList.remove(campaignList[0]);

			if (campaignList.length <= 0) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new fnf.states.menus.StoryMenuState());

				// if ()
				// StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				// if (SONG.validScore) Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				// FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();

				var lol:PositionMeta = spectator.getCamPos();
				camPoint.setPoint(lol.x, lol.y);
			} else {
				var difficulty:String = 'Normal';

				if (storyDifficulty == 0)
					difficulty = 'Easy';

				if (storyDifficulty == 2)
					difficulty = 'Hard';

				trace('LOADING NEXT SONG');
				trace('${campaignList[0]} $difficulty');

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				inst.stop();
				vocals.stop();
				for (strumLine in strumLines) strumLine.vocals.stop();

				// if (SONG.song.toLowerCase() == 'eggnog') {
				// 	var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				// 	blackShit.scrollFactor.set();
				// 	add(blackShit);
				// 	camHUD.visible = false;
				// 	inCutscene = true;

				// 	FlxG.sound.play(Paths.sound('Lights_Shut_off'), () -> {
				// 		// no camPoint so it centers on horror tree
				// 		SONG = Song.loadFromJson(campaignList[0], difficulty);
				// 		LoadingState.loadAndSwitchState(new PlayState());
				// 	});
				// } else {
					// prevCamPoint = camPoint;
					SONG = Song.loadFromJson(campaignList[0], difficulty);
					LoadingState.loadAndSwitchState(new PlayState());
				// }
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			// unloadAssets();
			var lol:PositionMeta = spectator.getCamPos();
				camPoint.setPoint(lol.x, lol.y);
			FlxG.switchState(new fnf.states.menus.FreeplayState());
		}
	}

	var facingPlayer:Bool = false; // temp
	public function updateCamPos(character:String) {
		var realChar:Character = null;
		for (tag => char in characterMap) if (tag == character) {realChar = char; break;}
		if (realChar != null) {
			var lol:PositionMeta = realChar.getCamPos();
			camPoint.setPoint(lol.x, lol.y);
			scripts.call('updateCamPos');
		}
	}

	var __vocalOffsetViolation:Float;
	override public function update(elapsed:Float):Void {
		Conductor.songPosition += Conductor.offset + elapsed * 1000;

		scripts.call('update', [elapsed]);

		if (inCutscene) {
			super.update(elapsed);
			scripts.call('updatePost', [elapsed]);
			return;
		}

		if (Conductor.songPosition >= 0 && startingSong) startSong(); else {
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

		scripts.call('updatePost', [elapsed]);
	}

	function resyncVocals() {
		for (strumLine in strumLines) if (!strumLine.vocalsFinished) strumLine.vocals.pause();
		if (!vocalsFinished) vocals.pause();
		Conductor.songPosition = inst.time;
		if (!vocalsFinished) vocals.time = Conductor.songPosition;
		for (strumLine in strumLines) {
			if (!strumLine.vocalsFinished) {
				strumLine.vocals.time = inst.time;
				strumLine.vocals.resume();
			}
		}
		if (!vocalsFinished) vocals.resume();
		scripts.call('resyncedVocals');
	}

	override public function onFocus():Void {
		if (!paused && FlxG.autoPause) {
			for (strumLine in strumLines) strumLine.vocals.resume();
			vocals.resume();
			inst.resume();
		}
		scripts.call('focus');
		super.onFocus();
	}
	override public function onFocusLost():Void {
		if (!paused && FlxG.autoPause) {
			for (strumLine in strumLines) strumLine.vocals.pause();
			vocals.pause();
			inst.pause();
		}
		scripts.call('lostFocus');
		super.onFocusLost();
	}

	override public function destroy():Void {
		scripts.destroy();
		super.destroy();
	}
}