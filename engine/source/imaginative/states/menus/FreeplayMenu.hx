package imaginative.states.menus;

/**
 * The freeplay menu, where you can pick any song!
 */
class FreeplayMenu extends BeatState {
	// Menu related vars.
	var canSelect:Bool = true;
	static var prevSelected:Int = 0;
	static var curSelected:Int = 0;
	var visualSelected:Int = curSelected;
	inline function selectionCooldown(duration:Float = 0.1):FlxTimer {
		canSelect = false;
		return new FlxTimer().start(duration, (_:FlxTimer) -> canSelect = true);
	}
	var emptyList(default, null):Bool = false;

	var diffMap:Map<String, DifficultyHolder> = new Map<String, DifficultyHolder>();

	static var prevDiffList:Array<String> = [];
	static var curDiffList:Array<String> = [];

	var curDiffString(get, never):String;
	inline function get_curDiffString():String
		return curDiffList[curDiff];

	static var prevDiff:Int = 0;
	static var curDiff:Int = 0;
	var emptyDiffList(default, null):Bool = false;

	var menuTimePosition:Float = 0; // last known menu song time
	var currentSongAudio:String = ':MENU:'; // using ":" since they can't be used in file/folder names
	var currentSongVariant:String = ':MENU:'; // for variants, changes to ":MENU:"
	var winningIcon:HealthIcon; // keeps track of the icon set to the winning animation so it can be reset

	// Objects in the state.
	var bg:FlxSprite;

	var songs:FlxTypedGroup<SongHolder>;
	var diffs:FlxTypedGroup<DifficultyHolder>;

	// song selection text
	var infoTextGroup:FlxSpriteGroup;
	var songNameText:FlxText;
	var variantText:FlxText;
	var difficultyText:FlxText;
	var sideArrowsText:FlxText;

	// current music information
	var songPlayingGroup:FlxSpriteGroup;
	var musicNameText:FlxText;
	var artistText:FlxText;
	var songBpmText:FlxText;
	var songSigText:FlxText;

	// Camera management.
	var camPoint:FlxObject;

	override public function create():Void {
		super.create();
		if (!conductor.playing)
			conductor.loadMusic('freakyMenu', (_:FlxSound) -> conductor.play(0.8));

		// Camera position.
		camPoint = new FlxObject(0, 0, 1, 1);
		camera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		// Menu elements.
		bg = new FlxSprite().getBGSprite(FlxColor.YELLOW);
		bg.scrollFactor.set();
		bg.setUnstretchedGraphicSize(FlxG.width, FlxG.height, false);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var loadedDiffs:Array<String> = [];
		songs = new FlxTypedGroup<SongHolder>();
		for (list in [
			// FunkinUtil.getSongFolderNames(LEAD),
			// FunkinUtil.getSongFolderNames(MOD),
			FunkinUtil.getSongFolderNames()
		]) {
			for (i => name in list) {
				var song:SongHolder = new SongHolder(10 * (i + 1) - 10 - (FlxG.width / 2), 150 * (i + 1), name, true);
				songs.add(song);

				for (diff in song.data.difficulties)
					if (!loadedDiffs.contains(diff))
						loadedDiffs.push(diff);
			}
		}
		if (songs.length < 1) {
			emptyList = true;
			log('There are no items in the listing.', WarningMessage);
		}
		add(songs);

		diffs = new FlxTypedGroup<DifficultyHolder>();
		for (name in loadedDiffs) {
			if (diffMap.exists(name)) continue;
			var diff:DifficultyHolder = new DifficultyHolder(name);
			diffMap.set(name, diffs.add(diff));
		}
		if (diffs.length < 1) {
			emptyDiffList = true;
			log('There are no difficulties in the listing.', WarningMessage);
		}
		add(diffs);

		// informational text
		infoTextGroup = new FlxSpriteGroup(FlxG.width, 10);

		var boxWidth:Int = 400;
		var infoTextBox:FlxSprite = new FlxSprite();
		infoTextBox.alpha = 0.45;
		infoTextGroup.add(infoTextBox);

		songNameText = new FlxText(10, 10, boxWidth - 20, 'Song: crAzy');
		variantText = new FlxText(10, songNameText.y + songNameText.height + 17, boxWidth - 20, 'Variant: Normal');
		difficultyText = new FlxText(10, variantText.y + variantText.height + 30, boxWidth - 20, '< Normal >');
		sideArrowsText = new FlxText(10, difficultyText.y, difficultyText.width, '<                       >');
		for (text in [songNameText, variantText, difficultyText, sideArrowsText]) {
			text.setFormat(Paths.font('vcr').format(), 25, LEFT, OUTLINE, FlxColor.BLACK);
			text.borderSize = 2;
			infoTextGroup.add(text);
		}
		sideArrowsText.alignment = difficultyText.alignment = CENTER;

		infoTextBox.makeSolid(boxWidth, Std.int(infoTextGroup.height + 10), FlxColor.BLACK);
		infoTextGroup.x -= infoTextGroup.width + 10;
		infoTextGroup.scrollFactor.set();
		add(infoTextGroup);

		songPlayingGroup = new FlxSpriteGroup(FlxG.width + 10, FlxG.height);

		var boxWidth:Int = 800;
		var infoTextBox:FlxSprite = new FlxSprite();
		infoTextBox.alpha = 0.45;
		songPlayingGroup.add(infoTextBox);

		musicNameText = new FlxText(10, 10, boxWidth - 20, '...');
		artistText = new FlxText(10, musicNameText.y + musicNameText.height + 17, 0, 'By: Your Mom');
		songBpmText = new FlxText(10, 10, boxWidth - 20, '### BPM');
		songSigText = new FlxText(10, songBpmText.y + songBpmText.height + 17, boxWidth - 20, '# / #');
		for (text in [musicNameText, artistText, songBpmText, songSigText]) {
			text.setFormat(Paths.font('vcr').format(), 25, LEFT, OUTLINE, FlxColor.BLACK);
			text.borderSize = 2;
			songPlayingGroup.add(text);
		}
		songBpmText.alignment = songSigText.alignment = RIGHT;

		infoTextBox.makeSolid(boxWidth, Std.int(songPlayingGroup.height + 10), FlxColor.BLACK);
		songPlayingGroup.y -= songPlayingGroup.height + 10;
		songPlayingGroup.scrollFactor.set();
		add(songPlayingGroup);

		// regular menu shiz
		changeSelection();
		changeDifficulty();

		camPoint.setPosition(
			10 * (curSelected + 1) + 50,
			Position.getObjMidpoint(songs.members[curSelected].text).y
		);
		camera.snapToTarget();
		camera.bgColor = songs.members[visualSelected].data.color;
		bg.color = camera.bgColor - 0xFF646464;
	}
	function updateMusicInfoBoxWidth():Void { // is being stupid
		// var minWidth:Int = 500;
		// var bg:FlxSprite = songPlayingGroup.members[0];
		// var newWidth:Float = FlxMath.bound(bg.scale.x, minWidth, artistText.width + 100);
		// for (text in [musicNameText, songBpmText, songSigText])
		// 	text.fieldWidth = newWidth - 20;
		// bg.scale.x = newWidth;
		// bg.updateHitbox();
		// songPlayingGroup.x = FlxG.width - songPlayingGroup.width + 10;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (canSelect) {
			if (Controls.uiUp || FlxG.keys.justPressed.PAGEUP) {
				changeSelection(-1);
				visualSelected = curSelected;
			}
			if (Controls.uiDown || FlxG.keys.justPressed.PAGEDOWN) {
				changeSelection(1);
				visualSelected = curSelected;
			}

			if (FlxG.mouse.wheel != 0) {
				changeSelection(-1 * FlxG.mouse.wheel);
				visualSelected = curSelected;
			}
			if (PlatformUtil.mouseJustMoved())
				for (i => item in songs.members)
					if (FlxG.mouse.overlaps(item.text))
						changeSelection(i, true);

			if (Controls.uiLeft)
				changeDifficulty(-1);
			if (Controls.uiRight)
				changeDifficulty(1);

			if (FlxG.keys.justPressed.HOME) {
				changeSelection(0, true);
				visualSelected = curSelected;
			}
			if (FlxG.keys.justPressed.END) {
				changeSelection(songs.length - 1, true);
				visualSelected = curSelected;
			}

			if (Controls.back) {
				if (currentSongAudio == ':MENU:') {
					FunkinUtil.playMenuSFX(CancelSFX);
					BeatState.switchState(new MainMenu());
				} else {
					winningIcon.playAnim('normal');
					currentSongAudio = currentSongVariant = ':MENU:';
					conductor.loadMusic('freakyMenu', (_:FlxSound) -> {
						conductor.volume = 0;
						conductor.playFromTime(menuTimePosition, 0.8);
						conductor.fadeOut(stepTime * 2.5 / 1000, 0.8);
					});
					FlxTween.cancelTweensOf(songPlayingGroup, ['x']);
					FlxTween.tween(songPlayingGroup, {x: FlxG.width + 10}, stepTime * 2.5 / 1000, {ease: FlxEase.quadIn});
				}
			}
			if (Controls.accept || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(songs.members[curSelected].text))) {
				if (visualSelected != curSelected) {
					visualSelected = curSelected;
					FunkinUtil.playMenuSFX(ScrollSFX, 0.7);
				} else if (currentSongAudio != songs.members[curSelected].data.folder || currentSongVariant != songs.members[curSelected].data.variants[curDiff]) {
					var song:SongHolder = songs.members[curSelected];
					menuTimePosition = conductor.time;
					if (winningIcon != null) winningIcon.playAnim('normal');
					(winningIcon = song.icon).playAnim('winning');

					conductor.loadFullSong(currentSongAudio = song.data.folder, curDiffString, currentSongVariant = song.data.variants[curDiff], (_:FlxSound) -> conductor.play());
					musicNameText.text = conductor.data.name;
					artistText.text = 'By: ${conductor.data.artist}';
					songBpmText.text = '${conductor.data.bpm} BPM';
					songSigText.text = conductor.data.signature.join(' / ');
					updateMusicInfoBoxWidth();
					FlxTween.cancelTweensOf(songPlayingGroup, ['x']);
					FlxTween.tween(songPlayingGroup, {x: FlxG.width - songPlayingGroup.width - 10}, stepTime * 2.5 / 1000, {ease: FlxEase.circOut});
				} else selectCurrent();
			}
		}

		camPoint.setPosition(
			10 * (visualSelected + 1) - 50,
			Position.getObjMidpoint(songs.members[visualSelected].text).y
		);
		camera.zoom = FlxMath.lerp(1, camera.zoom, 0.7);
		camera.bgColor = FlxColor.interpolate(camera.bgColor, songs.members[visualSelected].data.color, 0.1);
		bg.color = camera.bgColor - 0xFF646464;

		for (i => song in songs.members)
			song.alpha = FlxMath.lerp(song.alpha, curSelected == i ? 1 : Math.max(0.3, 1 - 0.3 * Math.abs(curSelected - i)), 0.34);
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		if (curBeat % 1 == 0 && currentSongAudio != ':MENU:')
			camera.zoom += 0.020;
	}

	function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		if (emptyList) return;
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, songs.length - 1);
		if (prevSelected != curSelected)
			FunkinUtil.playMenuSFX(ScrollSFX, 0.7);

		var song:SongHolder = songs.members[curSelected];
		songNameText.text = 'Song: ${song.data.name}';

		prevDiffList = curDiffList;
		curDiffList = song.data.difficulties;
		var newIndex:Int = song.data.startingDiff;
		if (prevDiffList[curDiff] == prevDiffList[curDiff])
			for (i => diff in curDiffList)
				if (diff == prevDiffList[curDiff]) {
					newIndex = i;
					break;
				}
		changeDifficulty(newIndex, true);
	}

	function changeDifficulty(move:Int = 0, pureSelect:Bool = false):Void {
		if (emptyDiffList) return;
		prevDiff = curDiff;
		curDiff = FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, curDiffList.length - 1);
		if (prevDiff != curDiff)
			FunkinUtil.playMenuSFX(ScrollSFX, 0.7);

		variantText.text = 'Variant: ${FunkinUtil.getDifficultyDisplay(songs.members[curSelected].data.variants[curDiff])}';
		difficultyText.text = FunkinUtil.getDifficultyDisplay(curDiffString);
		sideArrowsText.text = '${curDiff == 0 ? '|' : '<'}                       ${curDiff == curDiffList.length - 1 ? '|' : '>'}';
		sideArrowsText.visible = curDiffList.length > 1;
	}

	var songShake:FlxTween;
	function selectCurrent():Void {
		canSelect = false;

		var song:SongHolder = songs.members[curSelected];
		var songLocked:Bool = song.isLocked;
		var diffLocked:Bool = diffMap[curDiffString].isLocked;

		if (songLocked || diffLocked) {
			if (songShake == null) {
				var time:Float = FunkinUtil.playMenuSFX(CancelSFX).time / 1000;
				var ogX:Float = song.text.x;
				song.icon.playAnim('losing');
				songShake = FlxTween.shake(song.text, 0.02, time, X, {
					onComplete: (_:FlxTween) -> {
						song.text.x = ogX;
						songShake = null;
						song.icon.playAnim('normal');
					}
				});
				selectionCooldown(time);
			}
		} else {
			new FlxTimer().start(FunkinUtil.playMenuSFX(ConfirmSFX).time / 1000, (_:FlxTimer) -> {
				PlayState.renderSong(song.data.folder, curDiffString, song.data.variants[curDiff]/* , playAsEnemy, p2AsEnemy */);
				BeatState.switchState(new PlayState());
			});
		}
	}
}