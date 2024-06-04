package fnf.states.menus;

import flixel.addons.transition.FlxTransitionableState;
import fnf.backend.metas.*;

import fnf.objects.MenuCharacter;
import fnf.objects.MenuItem;

typedef LevelData = {
	var name:String;
	var title:String;
	var songs:Array<String>;
	var diffs:Array<String>;
	var chars:Array<String>;
	var color:FlxColor;
	@:optional @default(false) var failedLoad:Bool;
}

class StoryMenuState extends MusicBeatState {
	var scoreTxt:FlxText;

	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true, true, true];

	var levels:Array<LevelMeta> = [];

	var titleTxt:FlxText;

	var curLevel:Int = 0;

	var tracklistingTxt:FlxText;

	var weekSprites:FlxTypedGroup<MenuItem>;
	var characters:FlxTypedGroup<MenuCharacter>;

	var lockIndicators:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	function loadLevels(?pathType:FunkinPath) {
		for (file in Paths.readFolderOrderTxt('levels', 'yaml', pathType)) {
			final levelData = ParseUtil.level(file, pathType);
			trace({path: Paths.yaml('levels/$file'), level: file});
			if (levelData.failedLoad) continue;

			if (/* StoryMenuState.weekUnlocked[iterator] */ true #if debug || true #end) {
				addLevel(
					levelData.name,
					levelData.title,
					levelData.songs,
					levelData.diffs,
					levelData.chars,
					levelData.color,
					FunkinPath.getTypeAndModName(Paths.yaml('levels/$file', pathType))
				);
			}
		}
	}

	public function addLevel(name:String, title:String, songs:Array<String>, diffs:Array<String>, chars:Array<String>, color:FlxColor = FlxColor.WHITE, ?modShit:Array<Dynamic> = null) {
		var levelMeta:LevelMeta = new LevelMeta(name, title, songs, chars, color);
		if (modShit != null) levelMeta.setModType(modShit[0] == 'solo', modShit[1]);
		levelMeta.diffs = diffs;
		levels.push(levelMeta);
	}

	override function create() {
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;

		scoreTxt = new FlxText(10, 10, 0, 'SCORE: 49324858', 36);
		scoreTxt.setFormat('VCR OSD Mono', 32);

		titleTxt = new FlxText(FlxG.width * 0.7, 10, 0, '', 32);
		titleTxt.setFormat('VCR OSD Mono', 32, FlxColor.WHITE, RIGHT);
		titleTxt.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font('vcr.ttf'), 32);
		rankText.size = scoreTxt.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		weekSprites = new FlxTypedGroup<MenuItem>();
		add(weekSprites);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		characters = new FlxTypedGroup<MenuCharacter>();

		lockIndicators = new FlxTypedGroup<FlxSprite>();
		add(lockIndicators);

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence('In the Menus', null);
		#end

		loadLevels();
		// loadLevels(SOLO);
		// if (!ModUtil.isSoloOnly) loadLevels(MOD);
		for (level in levels) {
			trace(level.name);
		}

		for (i => level in levels) {
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, level.name);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			weekSprites.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			/* if (!weekUnlocked[i]) {
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				lockIndicators.add(lock);
			} */

		}

		for (i in 0...3) { // idk but jic ig
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (i + 1) - 150, levels[curLevel].chars[i]);
			weekCharacterThing.y += 70;
			weekCharacterThing.antialiasing = true;
			switch (weekCharacterThing.character) {
				case 'dad':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;
				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
				case 'pico':
					weekCharacterThing.flipX = true;
				case 'parents-christmas':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
			}
			characters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(weekSprites.members[0].x + weekSprites.members[0].width + 10, weekSprites.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.addByPrefix('press', 'arrow push left');
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', 'arrow push right', 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(characters);

		tracklistingTxt = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, 'Tracks', 32);
		tracklistingTxt.alignment = CENTER;
		tracklistingTxt.font = rankText.font;
		tracklistingTxt.color = 0xFFe55777;
		add(tracklistingTxt);
		// add(rankText);
		add(scoreTxt);
		add(titleTxt);

		updateText();

		super.create();
	}

	override function update(elapsed:Float) {
		// scoreTxt.setFormat('VCR OSD Mono', 32);
		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.5);

		scoreTxt.text = 'WEEK SCORE:' + Math.round(lerpScore);

		titleTxt.text = levels[curLevel].title/* .toUpperCase() */;
		titleTxt.x = FlxG.width - (titleTxt.width + 10);

		// FlxG.watch.addQuick('font', scoreTxt.font);

		difficultySelectors.visible = weekUnlocked[curLevel];

		lockIndicators.forEach(function(lock:FlxSprite) {
			lock.y = weekSprites.members[lock.ID].y;
		});

		if (!movedBack) {
			if (!selectedWeek) {
				if (controls.UI_UP_P) changeWeek(-1);
				if (controls.UI_DOWN_P) changeWeek(1);

				rightArrow.animation.play(controls.UI_RIGHT ? 'press' : 'idle');
				leftArrow.animation.play(controls.UI_LEFT ? 'press' : 'idle');

				if (controls.UI_RIGHT_P) changeDifficulty(1);
				if (controls.UI_LEFT_P) changeDifficulty(-1);
			}

			if (controls.ACCEPT) selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek() {
		if (weekUnlocked[curLevel]) {
			if (stopspamming == false) {
				FlxG.sound.play(Paths.sound('confirmMenu'));

				weekSprites.members[curLevel].startFlashing();
				characters.members[1].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.campaignList = levels[curLevel].songs;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = 'Normal';
			switch (curDifficulty) {
				case 0: diffic = 'Easy';
				case 2: diffic = 'Hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.campaignList[0], diffic);
			PlayState.storyWeek = curLevel;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void {
		curDifficulty += change;

		if (curDifficulty < 0) curDifficulty = 2;
		if (curDifficulty > 2) curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty) {
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curLevel, curDifficulty);

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void {
		curLevel += change;

		if (curLevel >= levels.length) curLevel = 0;
		if (curLevel < 0) curLevel = levels.length - 1;

		var bullShit:Int = 0;

		for (item in weekSprites.members) {
			item.targetY = bullShit - curLevel;
			if (item.targetY == Std.int(0) && weekUnlocked[curLevel]) item.alpha = 1;
			else item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText() {
		characters.members[0].animation.play(levels[curLevel].chars[0]);
		characters.members[1].animation.play(levels[curLevel].chars[1]);
		characters.members[2].animation.play(levels[curLevel].chars[2]);

		switch (characters.members[0].animation.name) {
			case 'parents-christmas':
				characters.members[0].offset.set(200, 200);
				characters.members[0].setGraphicSize(Std.int(characters.members[0].width * 0.99));

			case 'senpai':
				characters.members[0].offset.set(130, 0);
				characters.members[0].setGraphicSize(Std.int(characters.members[0].width * 1.4));

			case 'mom':
				characters.members[0].offset.set(100, 200);
				characters.members[0].setGraphicSize(Std.int(characters.members[0].width * 1));

			case 'dad':
				characters.members[0].offset.set(120, 200);
				characters.members[0].setGraphicSize(Std.int(characters.members[0].width * 1));

			case 'tankman':
				characters.members[0].offset.set(60, -20);
				characters.members[0].setGraphicSize(Std.int(characters.members[0].width * 1));

			default:
				characters.members[0].offset.set(100, 100);
				characters.members[0].setGraphicSize(Std.int(characters.members[0].width * 1));
				// characters.members[0].updateHitbox();
		}

		tracklistingTxt.text = 'Tracks\n\n${levels[curLevel].songs.join('\n')/* .toUpperCase() */}';

		tracklistingTxt.screenCenter(X);
		tracklistingTxt.x -= FlxG.width * 0.35;

		intendedScore = Highscore.getWeekScore(curLevel, curDifficulty);
	}
}
