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

	var prevDiffString:String = '';
	var curDiffString:String = '';

	var prevDiff:Int = 0;
	var curDiff:Int = 0;

	// Objects in the state.
	var scoreText:FlxText;
	var titleText:FlxText;

	var weekTopBg:FlxSprite;
	var weekBg:FlxSprite;
	var weekObjects:FlxTypedGroup<FlxSprite>;

	var trackText:String = 'vV Tracks Vv';
	var trackList:FlxText;

	var levels:FlxTypedGroup<LevelObject>;

	var diffs:FlxTypedGroup<DifficultyObject>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	// Camera management.
	var camPoint:FlxObject;

	override public function create():Void {
		statePathShortcut = 'menus/story/';
		super.create();
		if (Conductor.menu == null) Conductor.menu = new Conductor();
		if (conductor.audio == null || !conductor.audio.playing) {
			conductor.setAudio('freakyMenu', 0.8);
			conductor.audio.persist = true;
		}

		camPoint = new FlxObject(0, 0, 1, 1);
		FlxG.camera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		var loadedDiffs:Array<String> = [];
		levels = new FlxTypedGroup<LevelObject>();
		for (i => name in Paths.readFolderOrderTxt('content/levels', 'json')) {
			var level:LevelObject = new LevelObject(0, 150 * (i + 1), name);
			levels.add(level);

			for (diff in level.data.difficulties)
				if (!loadedDiffs.contains(diff.toLowerCase()))
					loadedDiffs.push(diff.toLowerCase());
		}
		add(levels);

		diffs = new FlxTypedGroup<DifficultyObject>();
		for (name in loadedDiffs) {
			if (diffMap.exists(name)) continue;
			var diff:DifficultyObject = new DifficultyObject(name);
			diff.sprite.screenCenter();
			diff.sprite.x += FlxG.width / 2.95;
			diff.sprite.y += FlxG.height / 3.5;
			diff.sprite.alpha = 0.0001;
			diffMap.set(name, diffs.add(diff));
		}
		add(diffs);

		var arrowDistance:Float = 200 * 0.85;
		leftArrow = new FlxSprite(diffs.members[0].sprite.x + diffs.members[0].sprite.width * 0.5, diffs.members[0].sprite.y + diffs.members[0].sprite.height * 0.5);
		rightArrow = new FlxSprite(leftArrow.x, leftArrow.y);

		for (dir in ['left', 'right']) {
			var arrow:FlxSprite = dir == 'left' ? leftArrow : rightArrow;

			arrow.frames = Paths.frames('ui/arrows');
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

		leftArrow.x -= leftArrow.width / 2; leftArrow.y -= leftArrow.height / 2;
		rightArrow.x -= rightArrow.width / 2; rightArrow.y -= rightArrow.height / 2;
		leftArrow.x -= arrowDistance; rightArrow.x += arrowDistance;

		weekTopBg = new FlxSprite().makeGraphic(FlxG.width, 56);
		weekTopBg.color = camera.bgColor;
		add(weekTopBg);

		weekBg = new FlxSprite(0, weekTopBg.height).makeGraphic(FlxG.width, 400);
		weekBg.color = levels.members[curSelected].data.color;
		add(weekBg);

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

		for (l in diffs)
			l.sprite.scrollFactor.set();
		for (l in [leftArrow, rightArrow, weekTopBg, weekBg, scoreText, titleText, trackList])
			l.scrollFactor.set();

		changeSelection();
		changeDifficulty(levels.members[curSelected].data.startingDiff, true);

		var mid:FlxPoint = levels.members[curSelected].sprite.getMidpoint();
		camPoint.setPosition(mid.x, mid.y - (FlxG.height / 3.4));
		camera.snapToTarget();
		mid.put();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (canSelect) {
			if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN)
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

			if (FlxG.keys.justPressed.LEFT)
				changeDifficulty(-1);
			if (FlxG.keys.justPressed.RIGHT)
				changeDifficulty(1);

			if (FlxG.keys.justPressed.HOME)
				changeSelection(0, true);
			if (FlxG.keys.justPressed.END)
				changeSelection(levels.length - 1, true);

			if (FlxG.keys.justPressed.BACKSPACE) {
				CoolUtil.playMenuSFX(CANCEL);
				FlxG.switchState(new MainMenu());
			}
			if (FlxG.keys.justPressed.ENTER)
				selectCurrent();
		}

		var item:FlxSprite = levels.members[curSelected].sprite;
		camPoint.y = (item.y + item.height * 0.5) - (FlxG.height / 3.4);
		weekBg.color = FlxColor.interpolate(weekBg.color, levels.members[curSelected].data.color, 0.1);
	}

	public function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, levels.length - 1);
		if (prevSelected != curSelected)
			CoolUtil.playMenuSFX(SCROLL, 0.7);

		var level:LevelObject = levels.members[curSelected];
		trackList.text = '$trackText\n\n${level.scripts.event('songNameDisplay', new LevelSongListEvent(level.data.songs)).songs.join('\n')}';
		titleText.text = level.data.title;


		prevDiffList = curDiffList;
		curDiffList = level.data.difficulties;
		if (prevDiffList[prevSelected] != curDiffList[curSelected])
			changeDifficulty(level.data.startingDiff, true);
	}

	public function changeDifficulty(move:Int = 0, pureSelect:Bool = false):Void {
		if (!pureSelect) {
			var arrow:FlxSprite = move == -1 ? leftArrow : rightArrow;
			arrow.animation.play('confirm', true);
			arrow.centerOffsets();
			arrow.centerOrigin();
		}

		prevDiffString = curDiffString; prevDiff = curDiff;
		curDiff = FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, curDiffList.length - 1); curDiffString = curDiffList[curDiff];
		if (prevDiff != curDiff)
			CoolUtil.playMenuSFX(SCROLL, 0.7);

		if (diffMap.exists(prevDiffString)) diffMap.get(prevDiffString).sprite.alpha = 0.0001;
		if (diffMap.exists(curDiffString)) diffMap.get(curDiffString).sprite.alpha = 1;
	}

	public function selectCurrent():Void {
		canSelect = false;

		var level:LevelObject = levels.members[curSelected];
		if (level.isLocked) {
			CoolUtil.playMenuSFX(CANCEL);
			canSelect = true;
		} else {
			CoolUtil.playMenuSFX(CONFIRM);
			PlayState.loadLevel(level.data, curDiffString);
		}
	}
}
