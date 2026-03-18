package imaginative.states.menus;

/**
 * It's the story menu, don't know what your expecting to see here.
 */
class StoryMenu extends BeatState {
	// Menu related vars.
	var diffMap:Map<String, DifficultyHolder> = new Map<String, DifficultyHolder>();

	var diffHolder(get, never):DifficultyHolder;
	function get_diffHolder():DifficultyHolder
		return diffMap[curDiffString];

	static var prevDiffList:Array<String> = [];
	static var curDiffList:Array<String> = [];

	var curDiffString(get, never):String;
	inline function get_curDiffString():String
		return curDiffList[curDiff];

	static var prevDiff:Int = 0;
	static var curDiff:Int = 0;
	var emptyDiffList(default, null):Bool = false;

	// Objects in the state.
	var scoreText:FlxText;
	var titleText:FlxText;

	var weekTopBg:BaseSprite;
	var weekBg:BaseSprite;
	var weekObjects:BeatGroup;

	var trackText:String = 'vV Tracks Vv';
	var trackList:FlxText;

	var levels:SelectionHandler<LevelSelectionEvent>;
	var diffs:FlxTypedGroup<DifficultyHolder>;
	var leftArrow:BaseSprite;
	var rightArrow:BaseSprite;

	// Camera management.
	var camPoint:FlxObject;

	override public function create():Void {
		super.create();
		#if FLX_DEBUG
		FlxG.game.debugger.watch.add('Previous Selection',    FUNCTION(() -> return    levels?.previousValue ?? 0));
		FlxG.game.debugger.watch.add('Current Selection',     FUNCTION(() -> return     levels?.currentValue ?? 0));
		#end
		if (!conductor.playing)
			conductor.loadMusic('freakyMenu', (_:FlxSound) -> conductor.play(0.8));

		// Camera position.
		mainCamera.setFollow(camPoint = new FlxObject(0, 0, 1, 1), 0.2);
		mainCamera.setZooming(1, 0.16);
		mainCamera.zoomEnabled = true;
		add(camPoint);

		final loadedDiffs:Array<String> = [];
		final loadedObjects:Array<Array<BasicSpriteTyping>> = [];
		final levelNoExistList:Array<String> = [];
		levels = new SelectionHandler<LevelSelectionEvent>(scriptName, false, item -> {
			final level:LevelHolder = item.extra.get('level');
			return eventCall('uponLevelSelection', new LevelSelectionEvent(level, diffHolder, level.data.id, curDiffString, level.data.variants[curDiff]));
		}, eventCall);
		final levelList:Array<Array<ModPath>> = [
			#if MOD_SUPPORT
			Paths.readFolderOrderTxt('lead:content/levels', 'json', false),
			Paths.readFolderOrderTxt('mod:content/levels', 'json', false)
			#else
			Paths.readFolderOrderTxt('content/levels', 'json', false)
			#end
		];
		trace(levelList);
		levels.overlapsCheck = (item:SelectionItem<LevelSelectionEvent>) ->
			return !(FlxG.mouse.overlaps(weekTopBg) || FlxG.mouse.overlaps(weekBg)) && FlxG.mouse.overlaps(item);
		levels.initialize(
			[for (list in levelList) for (item in list) item], true,
			(index:Int, group:SelectionItem<LevelSelectionEvent>) -> {
				final name:ModPath = group.itemId;
				if (!Paths.level(name).isFile) {
					levelNoExistList.push(name);
					return false;
				}

				// TODO: Rethink the holder classes.
				final level:LevelHolder = new LevelHolder(name, true);
				group.extra.set('level', level);
				for (diff in level.data.difficulties)
					if (!loadedDiffs.contains(diff))
						loadedDiffs.push(diff);
				var temp:Array<BasicSpriteTyping> = [];
				for (data in level.data.sprites)
					temp.push(data);
				loadedObjects.push(temp);

				group.add(level);
				group.screenCenter(X);
				return true;
			},
			(index:Int, event:SelectionChangeEvent, group:SelectionItem<LevelSelectionEvent>) -> {
				final level:LevelHolder = group.extra.get('level');
				final songList:SongDisplayListEvent = eventCall('songNameDisplay', level.scripts.event('songNameDisplay', new SongDisplayListEvent(level.data.songs)));
				trackList.text = '$trackText\n\n${songList.songs.join('\n')}';
				titleText.text = level.data.title;
				for (sprite in level.weekObjects)
					sprite.alpha = 1;

				prevDiffList = curDiffList;
				curDiffList = level.data.difficulties;
				var newIndex:Int = level.data.startingDiff;
				if (prevDiffList[curDiff] == prevDiffList[curDiff])
					for (i => diff in curDiffList)
						if (diff == prevDiffList[curDiff]) {
							newIndex = i;
							break;
						}
				changeDifficulty(newIndex, true);
			},
			(index:Int, event:LevelSelectionEvent, group:SelectionItem<LevelSelectionEvent>) -> {
				/* switch (group.itemId) {
					case pattern:
					default:

				} */
			},
			(index:Int, event:SelectionChangeEvent, group:SelectionItem<LevelSelectionEvent>) -> {
				final level:LevelHolder = group.extra.get('level');
				for (sprite in level.weekObjects)
						sprite.alpha = 0.0001;
			}
		);
		if (!levelNoExistList.empty())
			_log('[StoryMenu] Level(s) ${levelNoExistList.cleanDisplayList()} doesn\'t exist.');
		var _i:Int = 1;
		for (group in levels) {
			final level:LevelHolder = group.extra.get('level');
			group.isLocked = level.isLocked;
			if (level.isHidden) { group.canSelect = false; _i++; }
			group.y = 150 * _i;
			_i++;
		}
		@:privateAccess levels.selectCurrent = () -> {
			if (levels.currentValue == -1) {
				_log('${levels.traceTag} Nothing selected.', DebugMessage);
				return; // unselected
			}
			levels.setCooldown();

			final curItem = levels.members[levels.currentValue];
			_log('${levels.traceTag} Selecting item "${curItem.itemId}". (index:${levels.currentValue})', DebugMessage);
			final event:LevelSelectionEvent = levels.eventCreator(curItem);
			if (event.prevented) return;

			final level:LevelHolder = curItem.extra.get('level');
			level.scripts.event('onLevelSelect', event);
			if (event.prevented) return;
			var levelLocked:Bool = level.isLocked;
			var diffLocked:Bool = diffHolder.isLocked;

			if (levelLocked || diffLocked) {
				/* if (levelShake == null || diffShake == null) {
					var time:Float = {
						var sound = event.playMenuSFX(CancelSFX, true);
						if (sound == null) 3;
						else sound.time / 1000;
					}
					if (levelLocked) {
						var ogX:Float = level.x;
						levelShake = FlxTween.shake(level, 0.02, time, X, {
							onComplete: (_:FlxTween) -> {
								level.x = ogX;
								levelShake = null;
							}
						});
					}
					if (diffLocked) {
						var ogY:Float = diffHolder.y;
						diffShake = FlxTween.shake(diffHolder, 0.1, time, Y, {
							onComplete: (_:FlxTween) -> {
								diffHolder.y = ogY;
								diffShake = null;
							}
						});
					}
					levels.setCooldown(time);
				} */
			} else {
				for (sprite in level.weekObjects)
					if (sprite.extra.get('cheerOnSelect'))
						sprite.playAnim('hey', NoDancing);

				var time:Float = {
					var sound = event.playMenuSFX(ConfirmSFX, true);
					if (sound == null) 3;
					else sound.time / 1000;
				}
				new FlxTimer().start(time, (_:FlxTimer) -> {
					PlayState.renderLevel(level.data, event.difficultyKey, event.variantKey);
					BeatState.switchState(() -> new PlayState());
				});
			}
		}
		add(levels);

		diffs = new FlxTypedGroup<DifficultyHolder>();
		for (name in loadedDiffs) {
			if (diffMap.exists(name)) continue;
			var diff:DifficultyHolder = new DifficultyHolder(name, true);
			diff.scale.scale(0.85);
			diff.refreshAnim();
			diff.screenCenter();
			diff.x += FlxG.width / 2.95;
			diff.y += FlxG.height / 3.5;
			diff.alpha = 0.0001;
			diffMap.set(name, diffs.add(diff));
		}
		if (diffs.members.empty()) {
			emptyDiffList = true;
			log('There are no difficulties in the listing.', WarningMessage);
		}
		add(diffs);

		// Menu elements.
		final arrowDistance:Float = 200 * 0.85;
		final arrowPos:Position = Position.getObjMidpoint(diffs.members[0].sprite);
		leftArrow = new BaseSprite(arrowPos.x, arrowPos.y, 'ui/arrows');
		rightArrow = new BaseSprite(leftArrow.x, leftArrow.y, 'ui/arrows');

		for (dir in ['left', 'right']) {
			var arrow:BaseSprite = dir == 'left' ? leftArrow : rightArrow;
			arrow.animation.addByPrefix('idle', '${dir}Idle', 24, false);
			arrow.animation.addByPrefix('confirm', '${dir}Confirm', 24, false);

			arrow.animation.onFinish.add((name:String) -> {
				switch (name) {
					case 'confirm':
						arrow.playAnim('idle');
						arrow.centerOffsets();
						arrow.centerOrigin();
				}
			});

			arrow.scale.scale(0.85);
			arrow.updateHitbox();

			arrow.playAnim('idle');
			arrow.centerOffsets();
			arrow.centerOrigin();

			add(arrow);
		}

		leftArrow.x -= leftArrow.width / 2;
		leftArrow.y -= leftArrow.height / 2;
		rightArrow.x -= rightArrow.width / 2;
		rightArrow.y -= rightArrow.height / 2;
		leftArrow.x -= arrowDistance;
		rightArrow.x += arrowDistance;

		weekTopBg = new BaseSprite().makeSolid(mainCamera.width, 56);
		weekTopBg.color = mainCamera.bgColor;
		add(weekTopBg);

		weekBg = new BaseSprite(0, weekTopBg.height).makeSolid(mainCamera.width, 400);
		weekBg.color = levels.members[levels.currentValue].extra.get('level').data.color;
		add(weekBg);

		var cantFindCount:Int = 0;
		var cantFindList:Array<String> = [];
		weekObjects = new BeatGroup();
		for (i => loop in loadedObjects)
			for (data in loop) {
				final objectPath:Null<ModPath> = data.path;
				final objectData:SpriteData = data.data;

				if (objectPath != null && !objectPath.path.isNullOrEmpty())
					if (!Paths.object(objectPath).isFile && !cantFindList.contains(objectPath))
						cantFindList.push(objectPath);
				else if ((objectPath == null || objectPath.path.isNullOrEmpty()) && objectData == null)
					cantFindCount++;

				var sprite:BeatSprite = new BeatSprite(objectData == null ? objectPath : objectData);
				if (data.flipped) sprite.flipX = !sprite.flipX;
				sprite.setUnstretchedGraphicSize(Std.int(weekBg.width - 50), Std.int(weekBg.height - 50), false);
				sprite.scale.scale(data.sizeMult);
				sprite.updateHitbox();

				sprite.extra.set('cheerOnSelect', data.cheerOnSelect);
				sprite.extra.set('offsets', data.offset);

				sprite.alpha = 0.0001;
				sprite.scrollFactor.set();
				levels.members[i].extra.get('level').weekObjects.push(sprite);
				weekObjects.add(sprite);
			}
		if (!cantFindList.empty())
			log('Object(s) ${cantFindList.cleanDisplayList()}${cantFindCount == 0 ? '' : ', and $cantFindCount others'} do not exist.', WarningMessage);

		for (item in levels) {
			var objects:Array<BeatSprite> = item.extra.get('level').weekObjects;
			for (i => sprite in objects) {
				sprite.setPosition(mainCamera.width / 2, weekBg.height / 2 + weekBg.y);
				sprite.x += 400 * i;
				sprite.x -= (400 * ((objects.length - 1) / 2));
				var offsets:Position = sprite.extra.get('offsets');
				sprite.setPosition(sprite.x + offsets.x, sprite.y + offsets.y);
				sprite.x -= sprite.width / 2;
				sprite.y -= sprite.height / 2;
			}
		}

		add(weekObjects);

		scoreText = new FlxText(10, 10, FlxG.width - 20, 'Score: 0');
		scoreText.setFormat(Paths.font('vcr').format(), 32, LEFT);
		add(scoreText);

		titleText = new FlxText(10, 10, FlxG.width - 20, 'awaiting title...');
		titleText.setFormat(Paths.font('vcr').format(), 32, RIGHT);
		titleText.alpha = 0.7;
		add(titleText);

		trackList = new FlxText(20, weekBg.y + weekBg.height + 20, Std.int(((FlxG.width - 400) / 2) - 80), '$trackText\n\nWoah!\ncrAzy\nWhy am I a banana??');
		trackList.setFormat(Paths.font('vcr').format(), 32, 0xFFE55778, CENTER);
		add(trackList);

		for (diff in diffs)
			diff.scrollFactor.set();
		for (l in [leftArrow, rightArrow, weekTopBg, weekBg, scoreText, titleText, trackList])
			l.scrollFactor.set();

		@:privateAccess levels.initSelection();

		var mid:Position = Position.getObjMidpoint(levels.members[levels.currentValue].extra.get('level').sprite);
		camPoint.setPosition(mid.x, mid.y - (mainCamera.height / 3.4));
		mainCamera.snapToTarget();
	}
	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (levels.allowSelect) {
			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.overlaps(leftArrow))
					changeDifficulty(-1);
				if (FlxG.mouse.overlaps(rightArrow))
					changeDifficulty(1);
			} else if (FlxG.mouse.pressed) {
				if (FlxG.mouse.overlaps(leftArrow))
					playArrowAnim(true);
				if (FlxG.mouse.overlaps(rightArrow))
					playArrowAnim();
			}

			if (Controls.global.uiLeft)
				changeDifficulty(-1);
			else if (Controls.global.uiLeftPress)
				playArrowAnim(true);
			if (Controls.global.uiRight)
				changeDifficulty(1);
			else if (Controls.global.uiRightPress)
				playArrowAnim();

			if (Controls.global.back) {
				var event:MenuSFXEvent = eventCall('uponExitingMenu', new MenuSFXEvent());
				if (!event.prevented) {
					event.playMenuSFX(CancelSFX);
					BeatState.switchState(() -> new MainMenu());
				}
			}
		}

		final level:LevelHolder = levels.members[levels.currentValue].extra.get('level');
		camPoint.y = Position.getObjMidpoint(level.sprite).y - (mainCamera.height / 3.4);
		weekBg.color = FunkinUtil.colorLerp(weekBg.color, level.data.color, 0.1);
	}

	function playArrowAnim(isLeft:Bool = false):Void {
		var arrow:BaseSprite = isLeft ? leftArrow : rightArrow;
		arrow.playAnim('confirm');
		arrow.centerOffsets();
		arrow.centerOrigin();
	}
	function changeDifficulty(move:Int = 0, pureSelect:Bool = false):Void {
		if (emptyDiffList) return;
		var event:SelectionChangeEvent = eventCall('uponSwitchingDifficulty', new SelectionChangeEvent(curDiff, FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, curDiffList.length - 1)));
		if (event.prevented) return;
		prevDiff = event.previousValue;
		curDiff = event.currentValue;
		event.playMenuSFX(ScrollSFX);

		for (diff in diffMap)
			diff.alpha = 0.0001;
		diffHolder.alpha = 1;
	}
}