package fnf.states.menus;

import fnf.ui.Alphabet;
import fnf.ui.HealthIcon;

typedef SongData = {
	var name:String;
	var icon:String;
	var color:FlxColor;
	var diffs:Array<String>;
	var measure:Array<Int>;
	@:optional @default(false) var failedLoad:Bool;
}

class FreeplayState extends MusicBeatState {
	var songs:Array<SongMeta> = [];

	// var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var bg:FlxSprite;
	var scoreBG:FlxSprite;

	function loadSongs(?pathType:FunkinPath) {
		for (file in Paths.readFolderOrderTxt('levels', 'yaml', pathType)) {
			final levelData = ParseUtil.level(file, pathType);
			trace('');
			trace({path: Paths.yaml('levels/$file'), level: file});
			if (levelData.failedLoad) continue;

			if (/* StoryMenuState.weekUnlocked[iterator] */ true #if debug || true #end) {
				for (name in levelData.songs) {
					final songData = ParseUtil.song(name, pathType);
					trace({path: Paths.yaml('songs/$name/SongMetaData'), song: name});
					if (songData.failedLoad) continue;

					final mergedData:fnf.utils.FailsafeUtil.MergedLevelSongData = FailsafeUtil.mergeLevelAndSongData(levelData, songData);
					if (mergedData.failedLoad) continue; // jic

					addSong(
						songData.name,
						mergedData.diffs,
						file,
						mergedData.icon,
						mergedData.color,
						FunkinPath.getTypeAndModName(Paths.yaml('songs/${songData.name}/SongMetaData', pathType))
					);
				}
			}
		}
	}

	public function addSong(song:String, diffs:Array<String>, week:String, icon:String, color:FlxColor = FlxColor.WHITE, ?modShit:Array<Dynamic> = null) {
		var songMeta:SongMeta = new SongMeta(song, week, icon, color);
		if (modShit != null) songMeta.setModType(modShit[0] == 'solo', modShit[1]);
		songMeta.diffs = diffs;
		songs.push(songMeta);
	}

	override function create() {
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.sound.music != null)
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

		#if debug addSong('Test', ['Normal'], 'Testing', 'bf-pixel', FlxColor.WHITE, [ROOT, 'funkin']); #end
		loadSongs();
		// loadSongs(SOLO);
		// if (!ModUtil.isSoloOnly) loadSongs(MOD);

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].song, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].icon);
			icon.setupTracking(songText, (spr:FlxSprite) -> return {x: spr.x + spr.width + 10, y: spr.y - 30});

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0x99000000);
		scoreBG.antialiasing = false;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.sound.music != null)
			if (FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		bg.color = FlxColor.interpolate(bg.color, songs[curSelected].color, CoolUtil.camLerpShit(0.045));

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);

		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP) changeSelection(-1);
		if (downP) changeSelection(1);

		if (FlxG.mouse.wheel != 0) changeSelection(-Math.round(FlxG.mouse.wheel / 4));

		if (controls.UI_LEFT_P) changeDiff(-1);
		if (controls.UI_RIGHT_P) changeDiff(1);

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted) {
			var poop:String = Highscore.formatSong(songs[curSelected].song, curDifficulty);
			PlayState.SONG = Song.loadFromJson(songs[curSelected].song, poop);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			// PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0) {
		curDifficulty += change;

		if (curDifficulty < 0) curDifficulty = 2;
		if (curDifficulty > 2) curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].song, curDifficulty);

		PlayState.storyDifficulty = curDifficulty;

		diffText.text = "< " + CoolUtil.difficultyString() + " >";
		positionHighscore();
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0) curSelected = songs.length - 1;
		if (curSelected >= songs.length) curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected].song, curDifficulty);
		// lerpScore = 0;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length) iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0) item.alpha = 1;
		}
	}

	function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;

		diffText.x = Std.int(scoreBG.x + scoreBG.width / 2);
		diffText.x -= (diffText.width / 2);
	}
}