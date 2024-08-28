package states.menus;

class LevelItem extends FlxTypedGroup<FlxSprite> {
	public var isLocked(default, set):Bool = false;
	inline function set_isLocked(value:Bool):Bool {
		level.alpha = value ? 0.5 : 1;
		return isLocked = lock.visible = value;
	}

	public var lock:FlxSprite;
	public var level:FlxSprite;

	public function new(x:Float, y:Float, weekName:String) {
		super();

		level = new FlxSprite(x, y, Paths.image('menus/story/levels/$weekName'));
		level.antialiasing = true;
		add(level);

		var mid:FlxPoint = level.getMidpoint();
		lock = new FlxSprite(mid.x + (level.width / 4), mid.y, Paths.image('ui/lock'));
		lock.antialiasing = true;
		add(lock);
		mid.put();
	}
}

class StoryMenu extends BeatState {
	// Menu related vars.
	var canSelect:Bool = true;
	var prevSelected:Int = 0;
	var curSelected:Int = 0;

	// Objects in the state.
	var scoreText:FlxText;
	var storyText:FlxText;

	var weekTopBg:FlxSprite;
	var weekBg:FlxSprite;
	var chars:FlxTypedGroup<FlxSprite>;

	var trackList:FlxText;

	var levels:FlxTypedGroup<LevelItem>;

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

		levels = new FlxTypedGroup<LevelItem>();
		// Paths.readFolderOrderTxt('content/levels', 'json');
		for (i => name in ['Tutorial', 'Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6', 'Week 7', 'Weekend 1']) {
			var item:LevelItem = new LevelItem(0, 100 * (i + 1), name);
			item.level.screenCenter(X);
			levels.add(item);
		}
		changeSelection();
		add(levels);

		weekTopBg = new FlxSprite().makeGraphic(FlxG.width, 56, camera.bgColor);
		add(weekTopBg);

		weekBg = new FlxSprite(0, weekTopBg.height).makeGraphic(FlxG.width, 400);
		weekBg.color = 0xFFF9CF51;
		weekBg.alpha = 0.5;
		add(weekBg);

		scoreText = new FlxText(10, 10, FlxG.width - 20, 'Score: #');
		scoreText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT);
		add(scoreText);

		storyText = new FlxText(10, 10, FlxG.width - 20, 'awaiting title...');
		storyText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
		storyText.alpha = 0.7;
		add(storyText);

		trackList = new FlxText(10, weekBg.y + weekBg.height + 44, Std.int(((FlxG.width - 400) / 2) - 80), 'Tracks:');
		trackList.setFormat(Paths.font('vcr.ttf'), 32, 0xFFE55778, CENTER);
		add(trackList);

		for (l in [weekTopBg, weekBg, scoreText, storyText, trackList])
			l.scrollFactor.set();

		var mid:FlxPoint = levels.members[curSelected].level.getMidpoint();
		camPoint.setPosition(mid.x, mid.y);
		camera.snapToTarget();
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

			if (FlxG.keys.justPressed.BACKSPACE)
				FlxG.switchState(new MainMenu());

			if (FlxG.keys.justPressed.ENTER)
				selectCurrent();
		}
	}

	public function changeSelection(move:Int = 0):Void {
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(curSelected + move, 0, levels.length - 1);
		if (prevSelected != curSelected)
			CoolUtil.playMenuSFX(SCROLL, 0.7);
	}

	public function selectCurrent():Void {
		canSelect = false;

		CoolUtil.playMenuSFX(CONFIRM);

		// load week here
	}
}
