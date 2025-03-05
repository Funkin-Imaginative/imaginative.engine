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

	// Objects in the state.
	var bg:FlxSprite;

	var songs:FlxTypedGroup<SongHolder>;
	var diffs:FlxTypedGroup<DifficultyHolder>;

	// Camera management.
	var camPoint:FlxObject;

	override public function create():Void {
		super.create();
		if (!conductor.playing)
			conductor.loadMusic('freakyMenu', 0.8, (_:FlxSound) -> conductor.play());

		// Camera position.
		camPoint = new FlxObject(0, 0, 1, 1);
		camera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		// Menu elements.
		bg = new FlxSprite().getBGSprite(FlxColor.YELLOW);
		bgColor = bg.color;
		bg.scrollFactor.set(0.1, 0.1);
		bg.scale.scale(1.2);
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
				var song:SongHolder = new SongHolder(5 * (i + 1) + 100, 150 * (i + 1), name, true);
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

		changeSelection();

		camPoint.setPosition(
			FlxG.width / 2 + songs.members[0].text.x,
			Position.getObjMidpoint(songs.members[curSelected].text).y
		);
		camera.snapToTarget();
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
					if (FlxG.mouse.overlaps(item))
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
				FunkinUtil.playMenuSFX(CancelSFX);
				BeatState.switchState(new MainMenu());
			}
			if (Controls.accept || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(songs.members[curSelected]))) {
				if (visualSelected != curSelected) {
					visualSelected = curSelected;
					FunkinUtil.playMenuSFX(ScrollSFX, 0.7);
				} else selectCurrent();
			}
		}

		camPoint.setPosition(
			FlxG.width / 2 + songs.members[0].text.x,
			Position.getObjMidpoint(songs.members[visualSelected].text).y
		);
		camera.bgColor = FlxColor.interpolate(camera.bgColor, songs.members[visualSelected].data.color, 0.1);
		bg.color = camera.bgColor - 0xFF646464;

		for (i => song in songs.members)
			song.alpha = 0.3;
		for (i in curSelected - 2...curSelected + 3) {
			var song:SongHolder = songs.members[i];
			if (song != null)
				song.alpha = FlxMath.lerp(song.alpha, Math.abs(FlxMath.remapToRange(FlxMath.remapToRange(i, curSelected - 2, curSelected + 2, -0.3, 0.3), 0, 1, 1, 0)), 0.1);
		}
	}

	function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		if (emptyList) return;
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, songs.length - 1);
		if (prevSelected != curSelected)
			FunkinUtil.playMenuSFX(ScrollSFX, 0.7);

		var song:SongHolder = songs.members[curSelected];

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
	}

	function selectCurrent():Void {}
}