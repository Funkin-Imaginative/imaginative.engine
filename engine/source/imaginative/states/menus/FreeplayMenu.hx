package imaginative.states.menus;

import imaginative.backend.scripting.events.menus.*;

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

	static var menuTimePosition:Float = 0; // last known menu song time
	static var currentSongAudio:String = ':MENU:'; // using ":" since they can't be used in file/folder names
	static var currentSongVariant:String = ':MENU:'; // for variants, changes to ":MENU:"
	var winningIcon:HealthIcon; // keeps track of the icon set to the winning animation so it can be reset

	// Objects in the state.
	var bg:MenuSprite;

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
		#if FLX_DEBUG
		FlxG.game.debugger.watch.add('Previous Selection',    FUNCTION(() -> return                                 prevSelected));
		FlxG.game.debugger.watch.add('Current Selection',     FUNCTION(() -> return                                  curSelected));
		FlxG.game.debugger.watch.add('Visual Selection',      FUNCTION(() -> return                               visualSelected));
		FlxG.game.debugger.watch.add('Current Song Info',     FUNCTION(() -> return    '$currentSongAudio ~ $currentSongVariant'));
		#end
		if (!conductor.playing)
			conductor.loadMusic('freakyMenu', (_:FlxSound) -> conductor.play(0.8));

		// Camera position.
		camPoint = new FlxObject(0, 0, 1, 1);
		camera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		// Menu elements.
		var event:MenuBackgroundEvent = eventCall('onMenuBackgroundCreate', new MenuBackgroundEvent());
		bg = new MenuSprite(event.color, event.funkinColor, event.imagePathType);
		bg.scrollFactor.set();
		bg.updateSizeUnstretched(FlxG.width, FlxG.height, false);
		bg.screenCenter();
		add(bg);

		var loadedDiffs:Array<String> = [];
		songs = new FlxTypedGroup<SongHolder>();
		var songList:Array<Array<ModPath>> = [
			FunkinUtil.getSongFolderNames(LEAD),
			FunkinUtil.getSongFolderNames(MOD),
		];
		if (Settings.setup.debugMode)
			songList.insert(0, [Paths.file('main:Test')]);
		trace(songList);
		for (list in songList) {
			for (i => name in list) {
				var song:SongHolder = new SongHolder(name, true);
				var theCall:Dynamic = song.scripts.call('shouldHide');
				if (theCall is Bool ? theCall : false)
					song.destroy();
				else {
					songs.add(song);
					for (diff in song.data.difficulties)
						if (!loadedDiffs.contains(diff))
							loadedDiffs.push(diff);
				}
			}
		}
		for (i => song in songs.members)
			song.setPosition(10 * (i + 1) - 10 - (FlxG.width / 2), 150 * (i + 1));
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
		difficultyText = new FlxText(10, variantText.y + variantText.height + 20, boxWidth - 20, 'Normal');
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

		musicNameText = new FlxText(10, 10, boxWidth - 20, '... ~ ##:##');
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
		bgColor = bg.blankBg.color = songs.members[visualSelected].data.color;
		bg.lineArt.color = bg.blankBg.color - 0xFF646464;
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

	override public function onReset():Void {
		super.onReset();
		currentSongAudio = currentSongVariant = ':MENU:';
	}

	override public function update(elapsed:Float):Void {
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
				var event:ExitFreeplayEvent = eventCall('onLeave', new ExitFreeplayEvent(currentSongAudio != ':MENU:'));
				if (!event.prevented) {
					if (event.stopSongAudio) {
						if (winningIcon != null) {
							winningIcon.playAnim('normal');
							winningIcon.preventScaleBop = true;
						}
						currentSongAudio = currentSongVariant = ':MENU:';
						conductor.loadMusic('freakyMenu', (_:FlxSound) -> {
							conductor.playFromTime(menuTimePosition, 0);
							conductor.fadeOut(stepTime * 2.5 / 1000, 0.8);
						});
						FlxTween.cancelTweensOf(songPlayingGroup, ['x']);
						FlxTween.tween(songPlayingGroup, {x: FlxG.width + 10}, stepTime * 2.5 / 1000, {ease: FlxEase.quadIn});
						scriptCall('onStopSongPreview');
					} else {
						event.playMenuSFX(CancelSFX);
						BeatState.switchState(new MainMenu());
					}
				}
			}
			if (Controls.accept || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(songs.members[curSelected].text))) {
				if (visualSelected != curSelected) {
					visualSelected = curSelected;
					FunkinUtil.playMenuSFX(ScrollSFX, 0.7);
				} else {
					var event:PreviewSongEvent = eventCall('onPlaySongPreview', new PreviewSongEvent(currentSongAudio != songs.members[curSelected].data.folder || currentSongVariant != songs.members[curSelected].data.variants[curDiff]));
					if (!event.prevented) {
						if (event.playPreview) {
							var song:SongHolder = songs.members[curSelected];
							menuTimePosition = conductor.time;
							if (winningIcon != null) {
								winningIcon.playAnim('normal');
								winningIcon.preventScaleBop = true;
							}
							(winningIcon = song.icon).playAnim('winning');
							winningIcon.preventScaleBop = false;

							event.chartData = conductor.loadFullSong(currentSongAudio = song.data.folder, curDiffString, currentSongVariant = song.data.variants[curDiff], (_:FlxSound) -> conductor.play());
							musicNameText.text = '${conductor.data.name} ~ ${(conductor.audio.length / 1000).formatTime()}';
							artistText.text = 'By: ${conductor.data.artist}';
							songBpmText.text = '${conductor.data.bpm} BPM';
							songSigText.text = conductor.data.signature.join(' / ');
							updateMusicInfoBoxWidth();
							FlxTween.cancelTweensOf(songPlayingGroup, ['x']);
							FlxTween.tween(songPlayingGroup, {x: FlxG.width - songPlayingGroup.width - 10}, stepTime * 2.5 / 1000, {ease: FlxEase.circOut});
							eventCall('onSongPreview', event);
						} else selectCurrent();
					}
				}
			}
		}

		camPoint.setPosition(
			10 * (visualSelected + 1) - 50,
			Position.getObjMidpoint(songs.members[visualSelected].text).y
		);
		camera.zoom = FunkinUtil.lerp(camera.zoom, 1, 0.16);
		bgColor = bg.changeColor(FlxColor.interpolate(bg.blankBg.color, songs.members[visualSelected].data.color, 0.1), false);

		for (i => song in songs.members)
			song.alpha = FunkinUtil.lerp(song.alpha, curSelected == i ? 1 : Math.max(0.3, 1 - 0.3 * Math.abs(curSelected - i)), 0.34);

		if (FlxG.mouse.pressed)
			for (i => item in songs.members)
				if (FlxG.mouse.overlaps(item.icon))
					item.icon.scale.set(item.icon.spriteOffsets.scale.x * item.icon.bopScaleMult.x, item.icon.spriteOffsets.scale.y * item.icon.bopScaleMult.x);
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		if (curBeat % beatsPerMeasure == 0 && currentSongAudio != ':MENU:')
			camera.zoom += 0.020;
	}

	function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		if (emptyList) return;
		var event:SelectionChangeEvent = eventCall('onChangeSelection', new SelectionChangeEvent(curSelected, FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, songs.length - 1), pureSelect ? 0 : move));
		if (event.prevented) return;
		prevSelected = event.previousValue;
		curSelected = event.currentValue;
		event.playMenuSFX(ScrollSFX);

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
		var event:SelectionChangeEvent = eventCall('onChangeDifficulty', new SelectionChangeEvent(curDiff, FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, curDiffList.length - 1), pureSelect ? 0 : move));
		if (event.prevented) return;
		prevDiff = event.previousValue;
		curDiff = event.currentValue;
		event.playMenuSFX(ScrollSFX);

		variantText.text = 'Variant: ${FunkinUtil.getDifficultyDisplay(songs.members[curSelected].data.variants[curDiff])}';
		difficultyText.text = FunkinUtil.getDifficultyDisplay(curDiffString);
		sideArrowsText.text = '${curDiff == 0 ? '|' : '<'}                       ${curDiff == curDiffList.length - 1 ? '|' : '>'}';
		sideArrowsText.visible = curDiffList.length > 1;
	}

	var songShake:FlxTween;
	function selectCurrent():Void {
		canSelect = false;
		var event:SongSelectionEvent = eventCall('onSongSelect', new SongSelectionEvent(songs.members[curSelected], diffMap[curDiffString], songs.members[curSelected].data.name, curDiffString, songs.members[curSelected].data.variants[curDiff]));
		if (event.prevented) return;

		var song:SongHolder = event.holder;
		song.scripts.event('onSongSelect', event);
		if (event.prevented) return;
		var songLocked:Bool = song.isLocked;
		var diffLocked:Bool = event.diffHolder.isLocked;

		if (songLocked || diffLocked) {
			if (songShake == null) {
				var time:Float = event.playMenuSFX(CancelSFX, true).time / 1000;
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
			new FlxTimer().start(event.playMenuSFX(ConfirmSFX, true).time / 1000, (_:FlxTimer) -> {
				PlayState.renderSong(song.data.folder, event.difficultyKey, event.variantKey/* , playAsEnemy, p2AsEnemy */);
				BeatState.switchState(new PlayState());
			});
		}
	}
}