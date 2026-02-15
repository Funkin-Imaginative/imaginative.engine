package imaginative.states.menus;

/**
 * The freeplay menu where you can pick any song!
 */
class FreeplayMenu extends BeatState {
	// Menu related vars.
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

	var songs:SelectionHandler<SongSelectionEvent>;
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
		FlxG.game.debugger.watch.add('Previous Selection',    FUNCTION(() -> return                    songs?.previousValue ?? 0));
		FlxG.game.debugger.watch.add('Current Selection',     FUNCTION(() -> return                     songs?.currentValue ?? 0));
		FlxG.game.debugger.watch.add('Visual Selection',      FUNCTION(() -> return                      songs?.currentView ?? 0));
		FlxG.game.debugger.watch.add('Current Song Info',     FUNCTION(() -> return    '$currentSongAudio ~ $currentSongVariant'));
		#end
		if (!conductor.playing)
			conductor.loadMusic('freakyMenu', (_:FlxSound) -> conductor.play(0.8));

		// Camera position.
		mainCamera.beatSetup(conductor);
		mainCamera.setFollow(camPoint = new FlxObject(0, 0, 1, 1), 0.2);
		mainCamera.setZooming(1, 0.16);
		add(camPoint);

		// Menu elements.
		var event:MenuBackgroundEvent = eventCall('uponMenuBackgroundCreation', new MenuBackgroundEvent());
		bg = new MenuSprite(event.color, event.funkinColor, event.imagePathType);
		bg.scrollFactor.set();
		bg.updateSizeUnstretched(FlxG.width, FlxG.height, false);
		bg.screenCenter();
		add(bg);

		final loadedDiffs:Array<String> = [];
		final songNoExistList:Array<String> = [];
		songs = new SelectionHandler<SongSelectionEvent>(scriptName, item -> {
			final song:SongHolder = item.extra.get('song');
			eventCall('uponSongSelection', new SongSelectionEvent(song, diffMap[curDiffString], song.data.name, curDiffString, song.data.variants[curDiff]));
		}, eventCall);
		var songList:Array<Array<ModPath>> = [
			#if MOD_SUPPORT
			FunkinUtil.getSongFolderNames(LEAD),
			FunkinUtil.getSongFolderNames(MOD),
			#else
			FunkinUtil.getSongFolderNames()
			#end
		];
		trace(songList);
		songs.overlapsCheck = (item:SelectionItem<SongSelectionEvent>) ->
			return FlxG.mouse.overlaps(item.extra.get('song').text);
		songs.initialize(
			[for (list in songList) for (item in list) item], true,
			(index:Int, group:SelectionItem<SongSelectionEvent>) -> {
				final name:ModPath = group.itemId;
				if (!Paths.json('${name.type}:content/songs/${name.path}/meta').isFile) {
					// _log('[FreeplayMenu] Song ${name.path} doesn\'t exist.');
					songNoExistList.push(name);
					return false;
				}

				final song:SongHolder = new SongHolder(name, true);
				group.extra.set('song', song);
				for (diff in song.data.difficulties)
					if (!loadedDiffs.contains(diff))
						loadedDiffs.push(diff);

				group._canSelect = (value:Bool) ->
					group.visible = value;

				group.add(song);
				return true;
			},
			(index:Int, event:SelectionChangeEvent, group:SelectionItem<SongSelectionEvent>) -> {
				final song:SongHolder = group.extra.get('song');
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
		);
		if (!songNoExistList.empty())
			_log('[FreeplayMenu] Songs(s) ${songNoExistList.cleanDisplayList()} doesn\'t exist.');
		var _i:Int = 1;
		for (group in songs) {
			final song:SongHolder = group.extra.get('song');
			group.isLocked = song.isLocked;
			if (song.isHidden) { group.canSelect = false; _i++; }
			group.setPosition(10 * _i - 10 - (FlxG.width / 2), 150 * _i);
			_i++;
		}
		@:privateAccess songs.selectCurrent = () -> {
			final curItem = songs.members[songs.currentValue];
			final song:SongHolder = curItem.extra.get('song');

			var event:PreviewSongEvent = eventCall('uponSongPreview', new PreviewSongEvent(!FlxG.keys.pressed.SHIFT && (currentSongAudio != song.data.folder || currentSongVariant != song.data.variants[curDiff])));
			if (!event.prevented) {
				if (event.playPreview) {
					menuTimePosition = conductor.time;
					if (winningIcon != null) {
						winningIcon.playAnim('normal');
						winningIcon.preventScaleBop = true;
					}
					(winningIcon = song.icon).playAnim('winning');
					winningIcon.preventScaleBop = false;

					mainCamera.zoomEnabled = true;
					event.chartData = conductor.loadFullSong(currentSongAudio = song.data.folder, curDiffString, currentSongVariant = song.data.variants[curDiff], (_:FlxSound) -> conductor.play());
					musicNameText.text = '${conductor.data.name} ~ ${(conductor.audio.length / 1000).formatTime()}';
					artistText.text = 'By: ${conductor.data.artist}';
					songBpmText.text = '${conductor.data.bpm} BPM';
					songSigText.text = conductor.data.signature.join(' / ');
					updateMusicInfoBoxWidth();
					FlxTween.cancelTweensOf(songPlayingGroup, ['x']);
					FlxTween.tween(songPlayingGroup, {x: FlxG.width - songPlayingGroup.width - 10}, stepTime * 2.5 / 1000, {ease: FlxEase.circOut});
					eventCall('onStartSongPreview', event);
				} else {
					if (songs.currentValue == -1) {
						_log('${songs.traceTag} Nothing selected.', DebugMessage);
						return; // unselected
					}
					songs.setCooldown();

					_log('${songs.traceTag} Selecting item "${curItem.itemId}". (index:${songs.currentValue})', DebugMessage);
					final event:SongSelectionEvent = songs.eventCreator(curItem);
					if (event.prevented) return;

					song.scripts.event('onSongSelect', event);
					if (event.prevented) return;
					var songLocked:Bool = song.isLocked;
					var diffLocked:Bool = event.diffHolder.isLocked;

					if (songLocked || diffLocked) {
						/* if (songShake == null) {
							var time:Float = {
								var sound = event.playMenuSFX(CancelSFX, true);
								if (sound == null) 3;
								else sound.time / 1000;
							}
							var ogX:Float = song.text.x;
							song.icon.playAnim('losing');
							songShake = FlxTween.shake(song.text, 0.02, time, X, {
								onComplete: (_:FlxTween) -> {
									song.text.x = ogX;
									songShake = null;
									song.icon.playAnim('normal');
								}
							});
							levels.setCooldown(time);
						} */
					} else {
						var time:Float = {
							var sound = event.playMenuSFX(ConfirmSFX, true);
							if (sound == null) 3;
							else sound.time / 1000;
						}
						new FlxTimer().start(time, (_:FlxTimer) -> {
							currentSongAudio = currentSongVariant = ':MENU:';
							PlayState.renderSong(song.data.folder, event.difficultyKey, event.variantKey/* , playAsEnemy, p2AsEnemy */);
							BeatState.switchState(() -> new PlayState());
						});
					}
				}
			}
		}
		add(songs);

		diffs = new FlxTypedGroup<DifficultyHolder>();
		for (name in loadedDiffs) {
			if (diffMap.exists(name)) continue;
			var diff:DifficultyHolder = new DifficultyHolder(name);
			diffMap.set(name, diffs.add(diff));
		}
		if (diffs.members.empty()) {
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

		@:privateAccess songs.initSelection();

		camPoint.setPosition(
			10 * (songs.currentValue + 1) + 50,
			Position.getObjMidpoint(songs.members[songs.currentValue].extra.get('song').text).y
		);
		mainCamera.snapToTarget();
		bgColor = bg.blankBg.color = songs.members[songs.currentValue].extra.get('song').data.color;
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

		if (songs.allowSelect) {
			if (Controls.global.uiLeft)
				changeDifficulty(-1);
			if (Controls.global.uiRight)
				changeDifficulty(1);

			if (Controls.global.back) {
				var event:ExitFreeplayEvent = eventCall('uponExitingMenu', new ExitFreeplayEvent(currentSongAudio != ':MENU:'));
				if (!event.prevented) {
					if (event.stopSongAudio) {
						if (winningIcon != null) {
							winningIcon.playAnim('normal');
							winningIcon.preventScaleBop = true;
						}
						currentSongAudio = currentSongVariant = ':MENU:';
						mainCamera.zoomEnabled = false;
						conductor.loadMusic('freakyMenu', (_:FlxSound) -> {
							conductor.playFromTime(menuTimePosition, 0);
							conductor.fadeOut(stepTime * 2.5 / 1000, 0.8);
						});
						FlxTween.cancelTweensOf(songPlayingGroup, ['x']);
						FlxTween.tween(songPlayingGroup, {x: FlxG.width + 10}, stepTime * 2.5 / 1000, {ease: FlxEase.quadIn});
						scriptCall('onStopSongPreview');
					} else {
						event.playMenuSFX(CancelSFX);
						BeatState.switchState(() -> new MainMenu());
					}
				}
			}
		}

		camPoint.setPosition(
			10 * (songs.currentView + 1) - 50,
			Position.getObjMidpoint(songs.members[Std.int(songs.currentView)].extra.get('song').text).y
		);
		bgColor = bg.changeColor(FunkinUtil.colorLerp(bg.blankBg.color, songs.members[Std.int(songs.currentView)].extra.get('song').data.color, 0.1), false);

		for (i => song in songs.members)
			song.alpha = FunkinUtil.lerp(song.alpha, songs.currentValue == i ? 1 : Math.max(0.3, 1 - 0.3 * Math.abs(songs.currentValue - i)), 0.34);

		if (FlxG.mouse.pressed)
			for (item in songs.members) {
				final song:SongHolder = item.extra.get('song');
				if (FlxG.mouse.overlaps(song.icon))
					song.icon.scale.set(song.icon.spriteOffsets.scale.x * song.icon.bopScaleMult.x, song.icon.spriteOffsets.scale.y * song.icon.bopScaleMult.x);
			}
	}

	function changeDifficulty(move:Int = 0, pureSelect:Bool = false):Void {
		if (emptyDiffList) return;
		var event:SelectionChangeEvent = eventCall('uponSwitchingDifficulty', new SelectionChangeEvent(curDiff, FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, curDiffList.length - 1)));
		if (event.prevented) return;
		prevDiff = event.previousValue;
		curDiff = event.currentValue;
		event.playMenuSFX(ScrollSFX);

		variantText.text = 'Variant: ${FunkinUtil.getDifficultyDisplay(songs.members[songs.currentValue].extra.get('song').data.variants[curDiff])}';
		difficultyText.text = FunkinUtil.getDifficultyDisplay(curDiffString);
		sideArrowsText.text = '${curDiff == 0 ? '|' : '<'}                       ${curDiff == curDiffList.length - 1 ? '|' : '>'}';
		sideArrowsText.visible = !curDiffList.empty();
	}
}