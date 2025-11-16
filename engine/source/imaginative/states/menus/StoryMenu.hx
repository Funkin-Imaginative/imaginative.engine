package imaginative.states.menus;

/**
 * It's the story menu, don't know what your expecting to see here.
 */
class StoryMenu extends BeatState {
	// Menu related vars.
	var canSelect:Bool = true;
	static var prevSelected:Int = 0;
	static var curSelected:Int = 0;
	inline function selectionCooldown(duration:Float = 0.1):FlxTimer {
		canSelect = false;
		return new FlxTimer().start(duration, (_:FlxTimer) -> canSelect = true);
	}
	var emptyList(default, null):Bool = false;

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

	var levels:FlxTypedGroup<LevelHolder>;
	var diffs:FlxTypedGroup<DifficultyHolder>;
	var leftArrow:BaseSprite;
	var rightArrow:BaseSprite;

	// Camera management.
	var camPoint:FlxObject;

	override public function create():Void {
		super.create();
		#if FLX_DEBUG
		FlxG.game.debugger.watch.add('Previous Selection',    FUNCTION(() -> return    prevSelected));
		FlxG.game.debugger.watch.add('Current Selection',     FUNCTION(() -> return     curSelected));
		#end
		if (!conductor.playing)
			conductor.loadMusic('freakyMenu', (_:FlxSound) -> conductor.play(0.8));

		// Camera position.
		mainCamera.setFollow(camPoint = new FlxObject(0, 0, 1, 1), 0.2);
		mainCamera.setZooming(1, 0.16);
		mainCamera.zoomEnabled = true;
		add(camPoint);

		var loadedDiffs:Array<String> = [];
		var loadedObjects:Array<Array<ObjectTyping>> = [];
		levels = new FlxTypedGroup<LevelHolder>();
		var levelList:Array<Array<ModPath>> = [
			#if MOD_SUPPORT
			Paths.readFolderOrderTxt('lead:content/levels', 'json', false),
			Paths.readFolderOrderTxt('mod:content/levels', 'json', false)
			#else
			Paths.readFolderOrderTxt('content/levels', 'json', false)
			#end
		];
		trace(levelList);
		for (list in levelList) {
			for (i => name in list) {
				var level:LevelHolder = new LevelHolder(name, true);
				levels.add(level);

				for (diff in level.data.difficulties)
					if (!loadedDiffs.contains(diff))
						loadedDiffs.push(diff);
				var temp:Array<ObjectTyping> = [];
				for (data in level.data.objects)
					temp.push(data);
				loadedObjects.push(temp);
			}
		}
		for (i => level in levels.members) {
			level.screenCenter(X);
			level.y = 150 * (i + 1);
		}
		if (levels.members.empty()) {
			emptyList = true;
			log('There are no items in the listing.', WarningMessage);
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
		var arrowDistance:Float = 200 * 0.85;
		var arrowPos:Position = Position.getObjMidpoint(diffs.members[0].sprite);
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

		weekTopBg = new BaseSprite().makeSolid(FlxG.camera.width, 56);
		weekTopBg.color = camera.bgColor;
		add(weekTopBg);

		weekBg = new BaseSprite(0, weekTopBg.height).makeSolid(FlxG.camera.width, 400);
		weekBg.color = levels.members[curSelected].data.color;
		add(weekBg);

		var cantFindList:Array<String> = [];
		weekObjects = new BeatGroup();
		for (i => loop in loadedObjects)
			for (data in loop) {
				var modPath:ModPath = data.path;
				var objectData:SpriteData = data.object;

				if (!data.path.isNullOrEmpty())
					if (!Paths.object(modPath).isFile && !cantFindList.contains(modPath.path))
						cantFindList.push(modPath.path);

				var sprite:BeatSprite = new BeatSprite(objectData == null ? modPath.toString() : objectData);
				if (data.flip) sprite.flipX = !sprite.flipX;
				sprite.extra.set('offsets', data.offsets);
				sprite.scale.scale(data.size);
				sprite.updateHitbox();
				sprite.setUnstretchedGraphicSize(Std.int(weekBg.width - 50), Std.int(weekBg.height - 50), false);
				sprite.updateHitbox();

				sprite.extra.set('willHey', data.willHey);
				sprite.extra.set('offsets', data.offsets);

				sprite.alpha = 0.0001;
				sprite.scrollFactor.set();
				levels.members[i].weekObjects.push(sprite);
				weekObjects.add(sprite);
			}
		if (!cantFindList.empty())
			log('Object(s) ${cantFindList.cleanDisplayList()} doesn\'t exist.', WarningMessage);

		for (level in levels)
			for (i => sprite in level.weekObjects) {
				sprite.setPosition(FlxG.camera.width / 2, weekBg.height / 2 + weekBg.y);
				sprite.x += 400 * i;
				sprite.x -= (400 * ((level.weekObjects.length - 1) / 2));

				var offsets:Position = sprite.extra.get('offsets');
				sprite.setPosition(sprite.x + offsets.x, sprite.y + offsets.y);
				sprite.x -= sprite.width / 2;
				sprite.y -= sprite.height / 2;
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

		changeSelection();
		changeDifficulty();

		var mid:Position = Position.getObjMidpoint(levels.members[curSelected].sprite);
		camPoint.setPosition(mid.x, mid.y - (FlxG.camera.height / 3.4));
		camera.snapToTarget();
	}

	function hoverIsCorrect(item:LevelHolder):Bool {
		return !(FlxG.mouse.overlaps(weekTopBg) || FlxG.mouse.overlaps(weekBg)) && FlxG.mouse.overlaps(item);
	}
	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (canSelect) {
			if (Controls.global.uiUp || FlxG.keys.justPressed.PAGEUP)
				changeSelection(-1);
			if (Controls.global.uiDown || FlxG.keys.justPressed.PAGEDOWN)
				changeSelection(1);

			if (FlxG.mouse.wheel != 0)
				changeSelection(-1 * FlxG.mouse.wheel);
			var stopSelect:Bool = false;
			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.overlaps(leftArrow))
					changeDifficulty(-1);
				if (FlxG.mouse.overlaps(rightArrow))
					changeDifficulty(1);
				for (i => item in levels.members)
					if (curSelected == i)
						continue;
					else if (hoverIsCorrect(item)) {
						changeSelection(i, stopSelect = true);
						break;
					}
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

			if (FlxG.keys.justPressed.HOME)
				changeSelection(0, true);
			if (FlxG.keys.justPressed.END)
				changeSelection(levels.length - 1, true);

			if (Controls.global.back) {
				var event:MenuSFXEvent = eventCall('onLeave', new MenuSFXEvent());
				if (!event.prevented) {
					event.playMenuSFX(CancelSFX);
					BeatState.switchState(() -> new MainMenu());
				}
			}
			if (Controls.global.accept || (FlxG.mouse.justPressed && hoverIsCorrect(levels.members[curSelected]) && !stopSelect))
				selectCurrent();
		}

		var item:BaseSprite = levels.members[curSelected].sprite;
		camPoint.y = Position.getObjMidpoint(item).y - (FlxG.camera.height / 3.4);
		weekBg.color = FunkinUtil.colorLerp(weekBg.color, levels.members[curSelected].data.color, 0.1);
	}

	function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		if (emptyList) return;
		var event:SelectionChangeEvent = eventCall('onChangeSelection', new SelectionChangeEvent(curSelected, FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, levels.length - 1), pureSelect ? 0 : move));
		if (event.prevented) return;
		prevSelected = event.previousValue;
		curSelected = event.currentValue;
		event.playMenuSFX(ScrollSFX);

		var level:LevelHolder = levels.members[curSelected];
		trackList.text = '$trackText\n\n${level.scripts.event('songNameDisplay', new SongDisplayListEvent(level.data.songs)).songs.join('\n')}';
		titleText.text = level.data.title;

		for (level in levels)
			for (sprite in level.weekObjects)
				sprite.alpha = 0.0001;
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
	}

	function playArrowAnim(isLeft:Bool = false):Void {
		var arrow:BaseSprite = isLeft ? leftArrow : rightArrow;
		arrow.playAnim('confirm');
		arrow.centerOffsets();
		arrow.centerOrigin();
	}
	function changeDifficulty(move:Int = 0, pureSelect:Bool = false):Void {
		if (emptyDiffList) return;
		var event:SelectionChangeEvent = eventCall('onChangeDifficulty', new SelectionChangeEvent(curDiff, FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, curDiffList.length - 1), pureSelect ? 0 : move));
		if (event.prevented) return;
		prevDiff = event.previousValue;
		curDiff = event.currentValue;
		event.playMenuSFX(ScrollSFX);

		for (diff in diffMap)
			diff.alpha = 0.0001;
		diffHolder.alpha = 1;
	}

	var levelShake:FlxTween;
	var diffShake:FlxTween;
	function selectCurrent():Void {
		canSelect = false;
		var event:LevelSelectionEvent = eventCall('onLevelSelect', new LevelSelectionEvent(levels.members[curSelected], diffHolder, levels.members[curSelected].data.name, curDiffString, levels.members[curSelected].data.variants[curDiff]));
		if (event.prevented) return;

		var level:LevelHolder = event.holder;
		level.scripts.event('onLevelSelect', event);
		if (event.prevented) return;
		var levelLocked:Bool = level.isLocked;
		var diffLocked:Bool = diffHolder.isLocked;

		if (levelLocked || diffLocked) {
			if (levelShake == null || diffShake == null) {
				var time:Float = event.playMenuSFX(CancelSFX, true).time / 1000;
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
				selectionCooldown(time);
			}
		} else {
			for (sprite in levels.members[curSelected].weekObjects)
				if (sprite.extra.get('willHey'))
					sprite.playAnim('hey', NoDancing);

			new FlxTimer().start(event.playMenuSFX(ConfirmSFX, true).time / 1000, (_:FlxTimer) -> {
				PlayState.renderLevel(level.data, event.difficultyKey, event.variantKey);
				BeatState.switchState(() -> new PlayState());
			});
		}
	}
}