package states.menus;

import backend.scripting.events.menus.story.SongListEvent;

/**
 * It's the story menu... still don't know what your expecting to see here.
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
		if (!conductor.audio.playing)
			conductor.loadMusic('freakyMenu', 0.8, (_:FlxSound) -> conductor.play());

		camPoint = new FlxObject(0, 0, 1, 1);
		camera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		var loadedDiffs:Array<String> = [];
		var loadedObjects:Array<Array<ObjectTyping>> = [];
		levels = new FlxTypedGroup<LevelHolder>();
		for (list in [
			// Paths.readFolderOrderTxt('lead:content/levels', 'json', false),
			// Paths.readFolderOrderTxt('mod:content/levels', 'json', false)
			Paths.readFolderOrderTxt('content/levels', 'json', false)
		]) {
			for (i => name in list) {
				final level:LevelHolder = new LevelHolder(0, 150 * (i + 1), name, true);
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
		add(levels);

		diffs = new FlxTypedGroup<DifficultyHolder>();
		for (name in loadedDiffs) {
			if (diffMap.exists(name)) continue;
			final diff:DifficultyHolder = new DifficultyHolder(name, true);
			diff.sprite.scale.set(0.85, 0.85);
			diff.sprite.updateHitbox();
			diff.refreshAnim();
			diff.sprite.screenCenter();
			diff.sprite.x += FlxG.width / 2.95;
			diff.sprite.y += FlxG.height / 3.5;
			diff.sprite.alpha = 0.0001;
			diff.updateLock();
			diffMap.set(name, diffs.add(diff));
		}
		add(diffs);

		final arrowDistance:Float = 200 * 0.85;
		final arrowPos:Position = Position.getObjMidpoint(diffs.members[0].sprite);
		leftArrow = new BaseSprite(arrowPos.x, arrowPos.y, 'ui/arrows');
		rightArrow = new BaseSprite(leftArrow.x, leftArrow.y, 'ui/arrows');

		for (dir in ['left', 'right']) {
			final arrow:BaseSprite = dir == 'left' ? leftArrow : rightArrow;
			arrow.animation.addByPrefix('idle', '${dir}Idle', 24, false);
			arrow.animation.addByPrefix('confirm', '${dir}Confirm', 24, false);

			arrow.animation.finishCallback = (name:String) -> {
				switch (name) {
					case 'confirm':
						arrow.animation.play('idle', true);
						arrow.centerOffsets();
						arrow.centerOrigin();
				}
			}

			arrow.scale.set(0.85, 0.85);
			arrow.updateHitbox();

			arrow.animation.play('idle', true);
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

		weekTopBg = new BaseSprite().makeBox(FlxG.width, 56);
		weekTopBg.color = camera.bgColor;
		add(weekTopBg);

		weekBg = new BaseSprite(0, weekTopBg.height).makeBox(FlxG.width, 400);
		weekBg.color = levels.members[curSelected].data.color;
		add(weekBg);

		var cantFindList:Array<String> = [];
		weekObjects = new BeatGroup();
		for (i => loop in loadedObjects)
			for (data in loop) {
				var modPath:ModPath = data.path;
				var objectData:SpriteData = data.object;

				if (data.path.trim() != '' || data.path != null) {
					if (!Paths.fileExists(Paths.object(modPath)) && !cantFindList.contains(modPath.path)) {
						log('"${Paths.object(modPath).format()}" doesn\'t exist.', WarningMessage);
						cantFindList.push(modPath.path);
					}
				}

				var sprite:BeatSprite = new BeatSprite(objectData == null ? modPath.toString() : objectData);
				if (data.flip) sprite.flipX = !sprite.flipX;
				sprite.extra.set('offsets', data.offsets);
				sprite.scale.scale(data.size);
				sprite.updateHitbox();


				sprite.extra.set('willHey', data.willHey);
				sprite.extra.set('offsets', data.offsets);

				sprite.alpha = 0.0001;
				sprite.scrollFactor.set();
				levels.members[i].weekObjects.push(sprite);
				weekObjects.add(sprite);
			}

		for (level in levels)
			for (i => sprite in level.weekObjects) {
				sprite.setPosition(FlxG.width / 2, weekBg.height / 2 + weekBg.y);
				sprite.x += 400 * i;
				sprite.x -= (400 * ((level.weekObjects.length - 1) / 2));

				var offsets:Position = sprite.extra.get('offsets');
				sprite.setPosition(sprite.x + offsets.x, sprite.y + offsets.y);
				sprite.x -= sprite.width / 2;
				sprite.y -= sprite.height / 2;
			}

		add(weekObjects);

		scoreText = new FlxText(10, 10, FlxG.width - 20, 'Score: 0')
		.setFormat(Paths.font('vcr').format(), 32, LEFT);
		add(scoreText);

		titleText = new FlxText(10, 10, FlxG.width - 20, 'awaiting title...')
		.setFormat(Paths.font('vcr').format(), 32, RIGHT);
		titleText.alpha = 0.7;
		add(titleText);

		trackList = new FlxText(20, weekBg.y + weekBg.height + 20, Std.int(((FlxG.width - 400) / 2) - 80), '$trackText\n\nWoah!\ncrAzy\nWhy am I a banana??')
		.setFormat(Paths.font('vcr').format(), 32, 0xFFE55778, CENTER);
		add(trackList);

		for (l in diffs) {
			l.sprite.scrollFactor.set();
			l.lock.scrollFactor.set();
		}
		for (l in [leftArrow, rightArrow, weekTopBg, weekBg, scoreText, titleText, trackList])
			l.scrollFactor.set();

		changeSelection();
		changeDifficulty();

		final mid:Position = Position.getObjMidpoint(levels.members[curSelected].sprite);
		camPoint.setPosition(mid.x, mid.y - (FlxG.height / 3.4));
		camera.snapToTarget();
	}

	function hoverIsCorrect(item:LevelHolder):Bool return !(FlxG.mouse.overlaps(weekTopBg) || FlxG.mouse.overlaps(weekBg)) && (FlxG.mouse.overlaps(item.sprite) || (item.isLocked && FlxG.mouse.overlaps(item.lock)));
	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (canSelect) {

			if (Controls.uiUp || FlxG.keys.justPressed.PAGEUP)
				changeSelection(-1);
			if (Controls.uiDown || FlxG.keys.justPressed.PAGEDOWN)
				changeSelection(1);

			if (FlxG.mouse.wheel != 0)
				changeSelection(-1 * FlxG.mouse.wheel);
			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.overlaps(leftArrow))
					changeDifficulty(-1);
				if (FlxG.mouse.overlaps(rightArrow))
					changeDifficulty(1);
				for (i => item in levels.members)
					if (hoverIsCorrect(item))
						return changeSelection(i, true);
			}

			if (Controls.uiLeft)
				changeDifficulty(-1);
			if (Controls.uiRight)
				changeDifficulty(1);

			if (FlxG.keys.justPressed.HOME)
				changeSelection(0, true);
			if (FlxG.keys.justPressed.END)
				changeSelection(levels.length - 1, true);

			if (Controls.back) {
				FunkinUtil.playMenuSFX(CancelSFX);
				BeatState.switchState(new MainMenu());
			}
			if (Controls.accept || (FlxG.mouse.justPressed && hoverIsCorrect(levels.members[curSelected])))
				selectCurrent();
		}

		final item:BaseSprite = levels.members[curSelected].sprite;
		camPoint.y = Position.getObjMidpoint(item).y - (FlxG.height / 3.4);
		weekBg.color = FlxColor.interpolate(weekBg.color, levels.members[curSelected].data.color, 0.1);
	}

	function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, levels.length - 1);
		if (prevSelected != curSelected)
			FunkinUtil.playMenuSFX(ScrollSFX, 0.7);

		final level:LevelHolder = levels.members[curSelected];
		trackList.text = '$trackText\n\n${level.scripts.event('songNameDisplay', new SongListEvent(level.data.songs)).songs.join('\n')}';
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

	function changeDifficulty(move:Int = 0, pureSelect:Bool = false):Void {
		if (move != 0 || !pureSelect) {
			final arrow:BaseSprite = move == -1 ? leftArrow : rightArrow;
			arrow.animation.play('confirm', true);
			arrow.centerOffsets();
			arrow.centerOrigin();
		}

		prevDiff = curDiff;
		curDiff = FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, curDiffList.length - 1);
		if (prevDiff != curDiff)
			FunkinUtil.playMenuSFX(ScrollSFX, 0.7);

		for (diff in diffMap)
			diff.sprite.alpha = 0.0001;
		diffHolder.sprite.alpha = 1;
		for (diff in diffMap)
			diff.updateLock();
	}

	var levelShake:FlxTween;
	var diffShake:FlxTween;
	function selectCurrent():Void {
		canSelect = false;

		final level:LevelHolder = levels.members[curSelected];
		final levelLocked:Bool = level.isLocked;
		final diffLocked:Bool = diffHolder.isLocked;

		if (levelLocked || diffLocked) {
			if (levelShake == null || diffShake == null) {
				final time:Float = FunkinUtil.playMenuSFX(CancelSFX).time / 1000;
				if (levelLocked) {
					final ogX:Float = level.sprite.x;
					levelShake = FlxTween.shake(level.sprite, 0.02, time, X, {
						onUpdate: (_:FlxTween) -> level.updateLock(),
						onComplete: (_:FlxTween) -> {
							level.sprite.x = ogX;
							levelShake = null;
						}
					});
				}
				if (diffLocked) {
					final ogY:Float = diffHolder.sprite.y;
					diffShake = FlxTween.shake(diffHolder.sprite, 0.1, time, Y, {
						onUpdate: (_:FlxTween) -> diffHolder.updateLock(),
						onComplete: (_:FlxTween) -> {
							diffHolder.sprite.y = ogY;
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

			new FlxTimer().start(FunkinUtil.playMenuSFX(ConfirmSFX).time / 1000, (_:FlxTimer) -> {
				PlayState.renderLevel(level.data, curDiffString, level.data.variants[curDiff]);
				BeatState.switchState(new PlayState());
			});
		}
	}
}