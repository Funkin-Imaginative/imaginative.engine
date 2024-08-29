package states.menus;

class DifficultySprite extends FlxSprite {
	public var name:String;

	public function new(x:Float = 0, y:Float = 0, diff:String) {
		super();

		name = diff.toLowerCase();
		if (FileSystem.exists(Paths.xml('images/ui/difficulties/$name'))) {
			frames = Paths.frames('ui/difficulties/$name');
			animation.addByPrefix('idle', 'idle', 24);
		} else {
			loadGraphic(Paths.image('ui/difficulties/$name'));
			loadGraphic(Paths.image('ui/difficulties/$name'), true, Math.floor(width), Math.floor(height));
			animation.add('idle', [0], 24, false);
		}

		scale.set(0.85, 0.85);
		updateHitbox();

		playAnim('idle');
		x -= width / 2;
		y -= height / 2;
	}

	public function playAnim(name:String):Void {
		if (animation.exists(name)) {
			animation.play(name, true);
			centerOffsets();
			centerOrigin();
		}
	}
}

class StoryMenu extends BeatState {
	// Menu related vars.
	var canSelect:Bool = true;
	static var prevSelected:Int = 0;
	static var curSelected:Int = 0;

	var diffMap:Map<String, DifficultySprite> = new Map<String, DifficultySprite>();
	var loadedDiffs:Array<String> = ['easy', 'normal', 'hard', 'erect', 'nightmare'];

	var prevDiffList:Array<String> = [];
	var diffList:Array<String> = [];

	var prevDiffString:String = '';
	var curDiffString:String = '';

	var prevDiff:Int = 0;
	var curDiff:Int = 0;

	// Objects in the state.
	var scoreText:FlxText;
	var storyText:FlxText;

	var weekTopBg:FlxSprite;
	var weekBg:FlxSprite;
	var chars:FlxTypedGroup<FlxSprite>;

	var trackList:FlxText;

	var levels:FlxTypedGroup<FlxSprite>;
	var locks:FlxTypedGroup<FlxSprite>;

	var diffSprites:FlxTypedGroup<DifficultySprite>;
	var leftArrow:FlxSprite; var leftTimer:FlxTimer = new FlxTimer();
	var rightArrow:FlxSprite; var rightTimer:FlxTimer = new FlxTimer();

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

		levels = new FlxTypedGroup<FlxSprite>();
		locks = new FlxTypedGroup<FlxSprite>();
		// Paths.readFolderOrderTxt('content/levels', 'json');
		for (i => name in ['Tutorial', 'Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6', 'Week 7', 'Weekend 1']) {
			var level:FlxSprite = new FlxSprite(0, 150 * (i + 1), getAsset('levels/$name'));
			level.screenCenter(X);
			level.antialiasing = true;
			levels.add(level);

			var mid:FlxPoint = level.getMidpoint();
			var lock:FlxSprite = new FlxSprite(mid.x, mid.y, Paths.image('ui/lock'));
			lock.x -= lock.width / 2;
			lock.y -= lock.height / 2;
			lock.antialiasing = true;
			level.color = FlxColor.subtract(0xFFF9CF51, FlxColor.GRAY);
			locks.add(lock);
			mid.put();
		}
		changeSelection();
		add(levels);
		add(locks);

		diffSprites = new FlxTypedGroup<DifficultySprite>();
		for (name in loadedDiffs) {
			if (diffMap.exists(name)) continue;
			var diff:DifficultySprite = new DifficultySprite(name);
			diff.screenCenter();
			diff.x += FlxG.width / 2.95;
			diff.y += FlxG.height / 3.5;
			diff.antialiasing = true;
			diff.alpha = 0.0001;
			diffMap.set(name, diffSprites.add(diff));
		}
		changeDifficulty(1, true);
		add(diffSprites);

		var arrowDistance:Float = 200 * 0.85;
		leftArrow = new FlxSprite(diffSprites.members[0].x + diffSprites.members[0].width * 0.5, diffSprites.members[0].y + diffSprites.members[0].height * 0.5);
		rightArrow = new FlxSprite(diffSprites.members[0].x + diffSprites.members[0].width * 0.5, diffSprites.members[0].y + diffSprites.members[0].height * 0.5);

		for (dir in ['left', 'right']) {
			var arrow:FlxSprite = dir == 'left' ? leftArrow : rightArrow;

			arrow.frames = Paths.frames('ui/arrows');
			arrow.animation.addByPrefix('idle', '${dir}Idle', 24, false);
			arrow.animation.addByPrefix('confirm', '${dir}Confirm', 24, false);
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

		weekTopBg = new FlxSprite().makeGraphic(FlxG.width, 56, camera.bgColor);
		add(weekTopBg);

		weekBg = new FlxSprite(0, weekTopBg.height).makeGraphic(FlxG.width, 400);
		weekBg.color = 0xFFF9CF51;
		add(weekBg);

		scoreText = new FlxText(10, 10, FlxG.width - 20, 'Score: 0');
		scoreText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT);
		add(scoreText);

		storyText = new FlxText(10, 10, FlxG.width - 20, 'awaiting title...');
		storyText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
		storyText.alpha = 0.7;
		add(storyText);

		trackList = new FlxText(20, weekBg.y + weekBg.height + 20, Std.int(((FlxG.width - 400) / 2) - 80), 'vV Tracks Vv\n\nWoah!\ncrAzy\nWhy am I a banana??');
		trackList.setFormat(Paths.font('vcr.ttf'), 32, 0xFFE55778, CENTER);
		add(trackList);

		for (l in diffSprites)
			l.scrollFactor.set();
		for (l in [leftArrow, rightArrow, weekTopBg, weekBg, scoreText, storyText, trackList])
			l.scrollFactor.set();

		var mid:FlxPoint = levels.members[curSelected].getMidpoint();
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

			if (FlxG.keys.justPressed.LEFT)
				changeDifficulty(-1);
			if (FlxG.keys.justPressed.RIGHT)
				changeDifficulty(1);

			if (FlxG.keys.justPressed.HOME)
				changeSelection(0, true);
			if (FlxG.keys.justPressed.END)
				changeSelection(levels.length - 1, true);

			if (FlxG.keys.justPressed.BACKSPACE)
				FlxG.switchState(new MainMenu());
			if (FlxG.keys.justPressed.ENTER)
				selectCurrent();
		}

		var item:FlxSprite = levels.members[curSelected];
		camPoint.y = (item.y + item.height * 0.5) - (FlxG.height / 3.4);
	}

	public function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, levels.length - 1);
		if (prevSelected != curSelected)
			CoolUtil.playMenuSFX(SCROLL, 0.7);

		diffList = ['easy', 'normal', 'hard', 'erect', 'nightmare'];

		// change shiz
	}

	public function changeDifficulty(move:Int = 0, pureSelect:Bool = false):Void {
		prevDiffString = curDiffString; prevDiff = curDiff;
		curDiff = FlxMath.wrap(pureSelect ? move : (curDiff + move), 0, diffList.length - 1); curDiffString = diffList[curDiff];
		if (prevDiff != curDiff)
			CoolUtil.playMenuSFX(SCROLL, 0.7);

		if (diffMap.exists(prevDiffString)) diffMap.get(prevDiffString).alpha = 0.0001;
		if (diffMap.exists(curDiffString)) diffMap.get(curDiffString).alpha = 1;
	}

	public function selectCurrent():Void {
		canSelect = false;

		CoolUtil.playMenuSFX(CONFIRM);

		// load week here
	}
}
