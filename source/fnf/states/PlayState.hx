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

class PlayState extends MusicBeatState implements IMusicBeat {
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
	public static var songScore:Int = 0;
	public var inCutscene:Bool = false;

	public var defaultCamZoom:Float = 0.9;

	public var characterMap:FunkinMap<Character> = new FunkinMap<Character>();
	public var dad(get, never):Character; inline function get_dad():Character return characterMap.getTopSlot('dad');
	public var gf(get, never):Character; inline function get_gf():Character return characterMap.getTopSlot('gf');
	public var boyfriend(get, never):Character; inline function get_boyfriend():Character return characterMap.getTopSlot('boyfriend');
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
	public var gameScripts:ScriptGroup;

	/**
	 * for convenience sake
	 * and my sanity
	 * @Zyflx
	 */
	public var playField(default, null):PlayField;
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
			case 'gf-tankman': ['gf', 'tankman'];
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
		direct = this;
		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		persistentUpdate = persistentDraw = true;

		gameScripts = new ScriptGroup(this);
		if (SONG == null) SONG = Song.loadFromJson('Tutorial', 'Normal');
		for (ext in Script.exts) {
			for (file in Paths.readFolder('songs', ext)) gameScripts.add(Script.create('songs/$file'));
			for (file in Paths.readFolder('songs/$curSong', ext)) gameScripts.add(Script.create(file, 'song'));
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		FlxG.cameras.reset(camGame = new FunkinCamera());
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor = FlxColor.TRANSPARENT;

		gameScripts.load();

		var dadNaming:Array<String> = convertNames(SONG.player2);
		var boyfriendNaming:Array<String> = convertNames(SONG.player1);
		add(addCharToMap('gf', new Character(400, 130, false, 'gf', 'normal')));
		add(addCharToMap('dad', new Character(100, 100, false, dadNaming[0], dadNaming[1])));
		add(addCharToMap('boyfriend', new Character(770, 100, true, boyfriendNaming[0], boyfriendNaming[1])));

		var event:PlayFieldSetupEvent = gameScripts.event('playFieldSetup', new PlayFieldSetupEvent(dad.iconColor, dad.icon, boyfriend.iconColor, boyfriend.icon, [camHUD]));
		playField = new PlayField(this, {
			scriptGroup: gameScripts,
			barStuff: {
				enemy: {color: event.oppoIconColor, icon: event.oppoIcon},
				player: {color: event.playIconColor, icon: event.playIcon}
			}
		});
		playField.cameras = event.cameras;
		add(playField);
		enemyStrumLine.character = dad;
		playerStrumLine.character = boyfriend;
		gameScripts.call('playFieldSetupPost', [event]);

		generateSong();

		var lol:PositionMeta = gf.getCamPos();
		camPoint = new CameraPoint(lol.x, lol.y, 0.04);
		camPoint.offsetLerp = () -> return camPoint.pointLerp * 1.5;
		camPoint.setPoint(lol.x, lol.y);
		add(camPoint);

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

		StrumGroup.hitFuncs.noteHit = (event:NoteHitEvent) -> {
			if (!event.note.isSustain && event.strumGroup.status) {
				// combo += 1;
				// popUpScore(event.note.strumTime, event.note);
			}

			health += event.strumGroup.helperConvert(event.note.healthAmount.gain);

			if (!event.note.preventAnims.sing) {
				if (SaveManager.getOption('beatLoop')) event.strumGroup.character.playSingAnim(event.direction, ''); else {
					if (!event.note.isSustain) event.strumGroup.character.playSingAnim(event.direction, '');
					else event.strumGroup.character.lastHit = Conductor.songPosition;
				}
			}
			if (SaveManager.getOption('beatLoop')) event.note.parentStrum.playAnim('confirm', true); else {
				if (!event.note.isSustain) event.note.parentStrum.playAnim('confirm', true);
				else event.note.parentStrum.lastHit = Conductor.songPosition;
			}
			if (facingPlayer == event.strumGroup.status) {
				var ah = hate(event.direction);
				camPoint.setOffset(ah[0] / FlxG.camera.zoom, ah[1] / FlxG.camera.zoom);
			}
			if (coolCamReturn != null) coolCamReturn.cancel();
			coolCamReturn.start((Conductor.stepCrochet / 1000) * (SaveManager.getOption('beatLoop') ? (!event.note.isSustain ? 1.6 : 0.6) : 1), (timer:FlxTimer) -> camPoint.setOffset());

			vocals.volume = 1;
			event.strumGroup.vocals.volume = 1;
		};
		StrumGroup.hitFuncs.noteMiss = (event:NoteMissEvent) -> {
			health -= event.strumGroup.helperConvert(event.note.healthAmount.drain);
			// killCombo();

			// if (!practiceMode) songScore -= 10;

			vocals.volume = 0;
			event.strumGroup.vocals.volume = 0;
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if (!event.note.preventAnims.miss) {
				if (!event.note.isSustain) event.strumGroup.character.playSingAnim(event.direction, '', MISS);
				else event.strumGroup.character.lastHit = Conductor.songPosition;

				if (SaveManager.getOption('beatLoop')) event.strumGroup.character.playSingAnim(event.direction, '', MISS); else {
					if (!event.note.isSustain) event.strumGroup.character.playSingAnim(event.direction, '', MISS);
					else event.strumGroup.character.lastHit = Conductor.songPosition;
				}
			}
			// event.note.parentStrum.playAnim('press', true);
			if (coolCamReturn != null) coolCamReturn.cancel();
			camPoint.setOffset();
			camPoint.snapPoint();
		};
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

		gameScripts.call('onStartCountdown');

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * (countdownLength + 1);
		fakeBeat = (countdownLength + 1) * -1;

		var onCount:Int = 0;
		countdownTimer.start(Conductor.crochet / 1000, (timer:FlxTimer) -> {onCountdownTick(onCount, timer); onCount += 1;}, countdownLength + 1);
		gameScripts.call('onStartCountdownPost');
	}

	public function onCountdownTick(onTick:Int, ?timer:FlxTimer) {
		for (char in characterMap)
			if (!char.preventIdleBopping && onTick % Math.round(char.bopSpeed * char.beatInterval) == 0)
				char.tryDance();

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
		gameScripts.call('stepHit', [curStep]);
		resyncVocals();
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		gameScripts.call('beatHit', [curBeat]);
	}

	override public function measureHit(curMeasure:Int) {
		super.measureHit(curMeasure);
		if (generatedMusic && SONG.notes[curMeasure] != null)
			updateCamPos((facingPlayer = SONG.notes[curMeasure].mustHitSection) ? 'boyfriend' : 'dad');
		gameScripts.call('measureHit', [curMeasure]);
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

				var lol:PositionMeta = gf.getCamPos();
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
			var lol:PositionMeta = gf.getCamPos();
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
			gameScripts.call('updateCamPos');
		}
	}

	var __vocalOffsetViolation:Float;
	override public function update(elapsed:Float):Void {
		Conductor.songPosition += Conductor.offset + elapsed * 1000;

		gameScripts.call('update', [elapsed]);

		if (inCutscene) {
			super.update(elapsed);
			gameScripts.call('updatePost', [elapsed]);
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

		gameScripts.call('updatePost', [elapsed]);
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
		gameScripts.call('lostFocus');
		super.onFocusLost();
	}

	override public function destroy():Void {
		gameScripts.destroy();
		direct = null;
		super.destroy();
	}
}