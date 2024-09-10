package states.menus;

import backend.scripting.events.menus.story.*;

class StoryMenu extends BeatState {
	// Menu related vars.
	var canSelect:Bool = true;
	static var prevSelected:Int = 0;
	static var curSelected:Int = 0;

	var diffMap:Map<String, DifficultyObject> = new Map<String, DifficultyObject>();

	var prevDiffList:Array<String> = [];
	var curDiffList:Array<String> = [];

	var curDiffString(get, never):String;
	inline function get_curDiffString():String
		return curDiffList[curDiff];

	var prevDiff:Int = 0;
	var curDiff:Int = 0;

	// Objects in the state.
	var scoreText:FlxText;
	var titleText:FlxText;

	var weekTopBg:BaseSprite;
	var weekBg:BaseSprite;
	var weekObjects:FlxTypedGroup<BeatSprite>;

	var trackText:String = 'vV Tracks Vv';
	var trackList:FlxText;

	var levels:FlxTypedGroup<LevelObject>;
	var diffs:FlxTypedGroup<DifficultyObject>;
	var leftArrow:BaseSprite;
	var rightArrow:BaseSprite;

	// Camera management.
	var camPoint:FlxObject;

	override public function create():Void {
		super.create();
		if (Conductor.menu == null) Conductor.menu = new Conductor();
			if (conductor.audio == null || !conductor.audio.playing)
				conductor.loadMusic('freakyMenu', 0.8, (audio:FlxSound) -> audio.play());

		camPoint = new FlxObject(0, 0, 1, 1);
		camera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		var loadedDiffs:Array<String> = [];
		var loadedObjects:Array<objects.LevelObject.ObjectTyping> = [];
		levels = new FlxTypedGroup<LevelObject>();
		for (list in [
			// Paths.readFolderOrderTxt('content/levels', 'json', FunkinPath.getSolo()),
			Paths.readFolderOrderTxt('content/levels', 'json')
		]) {
			for (i => name in list) {
				var level:LevelObject = new LevelObject(0, 150 * (i + 1), name, true);
				levels.add(level);

				for (diff in level.data.difficulties)
					if (!loadedDiffs.contains(diff))
						loadedDiffs.push(diff);
				for (data in level.data.objects)
					if (!loadedObjects.contains(data))
						loadedObjects.push(data);
			}
		}
		add(levels);

		diffs = new FlxTypedGroup<DifficultyObject>();
		for (name in loadedDiffs) {
			if (diffMap.exists(name)) continue;
			var diff:DifficultyObject = new DifficultyObject(name, true);
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

		var arrowDistance:Float = 200 * 0.85;
		leftArrow = new BaseSprite(PositionStruct.getObjMidpoint(diffs.members[0].sprite).x, PositionStruct.getObjMidpoint(diffs.members[0].sprite).y, 'ui/arrows');
		rightArrow = new BaseSprite(leftArrow.x, leftArrow.y, 'ui/arrows');

		for (dir in ['left', 'right']) {
			var arrow:BaseSprite = dir == 'left' ? leftArrow : rightArrow;
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

			arrow.antialiasing = true;
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

		weekTopBg = new BaseSprite().loadSolid(FlxG.width, 56);
		weekTopBg.color = camera.bgColor;
		add(weekTopBg);

		weekBg = new BaseSprite(0, weekTopBg.height).loadSolid(FlxG.width, 400);
		weekBg.color = levels.members[curSelected].data.color;
		add(weekBg);

		/* weekObjects = new FlxTypedGroup<BeatSprite>();
		for (data in loadedObjects) {
			var sprite:BeatSprite;
			if (data.object is String)
				sprite;
			else
				sprite;
			weekObjects.add(sprite);
		}
		add(weekObjects); */

		scoreText = new FlxText(10, 10, FlxG.width - 20, 'Score: 0');
		scoreText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT);
		add(scoreText);

		titleText = new FlxText(10, 10, FlxG.width - 20, 'awaiting title...');
		titleText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
		titleText.alpha = 0.7;
		add(titleText);

		trackList = new FlxText(20, weekBg.y + weekBg.height + 20, Std.int(((FlxG.width - 400) / 2) - 80), '$trackText\n\nWoah!\ncrAzy\nWhy am I a banana??');
		trackList.setFormat(Paths.font('vcr.ttf'), 32, 0xFFE55778, CENTER);
		add(trackList);

		for (l in diffs) {
			l.sprite.scrollFactor.set();
			l.lock.scrollFactor.set();
		}
		for (l in [leftArrow, rightArrow, weekTopBg, weekBg, scoreText, titleText, trackList])
			l.scrollFactor.set();

		changeSelection();
		changeDifficulty(levels.members[curSelected].data.startingDiff, true);

		var mid:PositionStruct = PositionStruct.getObjMidpoint(levels.members[curSelected].sprite);
		camPoint.setPosition(mid.x, mid.y - (FlxG.height / 3.4));
		camera.snapToTarget();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (canSelect) {
			if (Controls.uiUp)
				changeSelection(-1);
			if (Controls.uiDown)
				changeSelection(1);

			if (FlxG.mouse.wheel != 0)
				changeSelection(-1 * FlxG.mouse.wheel);
			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.overlaps(leftArrow))
					changeDifficulty(-1);
				if (FlxG.mouse.overlaps(rightArrow))
					changeDifficulty(1);
				for (i => item in levels.members)
					if (!(FlxG.mouse.overlaps(weekTopBg) || FlxG.mouse.overlaps(weekBg)) && (FlxG.mouse.overlaps(item.sprite) || (item.isLocked && FlxG.mouse.overlaps(item.lock))))
						changeSelection(i, true);
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
				FunkinUtil.playMenuSFX(CANCEL);
				FlxG.switchState(new MainMenu());
			}
			if (Controls.accept)
				selectCurrent();
		}

		var item:BaseSprite = levels.members[curSelected].sprite;
		camPoint.y = PositionStruct.getObjMidpoint(item).y - (FlxG.height / 3.4);
		weekBg.color = FlxColor.interpolate(weekBg.color, levels.members[curSelected].data.color, 0.1);
	}

	public function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, levels.length - 1);
		if (prevSelected != curSelected)
			FunkinUtil.playMenuSFX(SCROLL, 0.7);

		var level:LevelObject = levels.members[curSelected];
		trackList.text = '$trackText\n\n${level.scripts.event('songNameDisplay', new LevelSongListEvent(level.data.songs)).songs.join('\n')}';
		titleText.text = level.data.title;

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

	public function changeDifficulty(move:Int = 0, pureSelect:Bool = false):Void {
		if (!pureSelect) {
			var arrow:BaseSprite = move == -1 ? leftArrow : rightArrow;
			arrow.animation.play('confirm', true);
			arrow.centerOffsets();
			arrow.centerOrigin();
		}

		prevDiff = curDiff;
		curDiff = FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, curDiffList.length - 1);
		if (prevDiff != curDiff)
			FunkinUtil.playMenuSFX(SCROLL, 0.7);

		for (diff in diffMap) diff.sprite.alpha = 0.0001;
		if (diffMap.exists(curDiffString)) diffMap.get(curDiffString).sprite.alpha = 1;
		for (diff in diffMap) diff.updateLock();
	}

	var levelShake:FlxTween;
	var diffShake:FlxTween;
	public function selectCurrent():Void {
		canSelect = false;

		var level:LevelObject = levels.members[curSelected];
		var levelLocked:Bool = level.isLocked;
		var diffLocked:Bool = diffMap.exists(curDiffString) && diffMap.get(curDiffString).isLocked;

		if (levelLocked || diffLocked) {
			if (levelShake == null || diffShake == null) {
				if (levelLocked) {
					var ogX:Float = level.sprite.x;
					levelShake = FlxTween.shake(level.sprite, 0.02, 0.2, X, {
						onUpdate: (tween:FlxTween) -> level.updateLock(),
						onComplete: (tween:FlxTween) -> {
							level.sprite.x = ogX;
							levelShake = null;
						}
					});
				}
				if (diffLocked) {
					var diff:DifficultyObject = diffMap.get(curDiffString);
					var ogY:Float = diff.sprite.y;
					diffShake = FlxTween.shake(diff.sprite, 0.1, 0.2, Y, {
						onUpdate: (tween:FlxTween) -> diff.updateLock(),
						onComplete: (tween:FlxTween) -> {
							diff.sprite.y = ogY;
							diffShake = null;
						}
					});
				}
				FunkinUtil.playMenuSFX(CANCEL);
				new FlxTimer().start(0.2, (timer:FlxTimer) -> canSelect = true);
			}
		} else {
			FunkinUtil.playMenuSFX(CONFIRM);
			PlayState.loadLevel(level.data, curDiffString);
		}
	}
}