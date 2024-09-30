package states.menus;

import backend.scripting.events.menus.main.*;
import flixel.effects.FlxFlicker;

class MainMenu extends BeatState {
	// Menu related vars.
	var canSelect:Bool = true;
	static var prevSelected:Int = 0;
	static var curSelected:Int = 0;
	var visualSelected:Int = curSelected;

	// Things to select.
	var itemLineUp:Array<String> = FunkinUtil.trimSplit(Paths.getFileContent(Paths.txt('images/menus/main/itemLineUp')));

	// Objects in the state.
	var bg:BaseSprite;
	var bg2:BaseSprite;
	var menuItems:FlxTypedGroup<BaseSprite>;
	var versionTxt:FlxText;

	// Camera management.
	var camPoint:FlxObject;
	var highestY:Float = 0;
	var lowestY:Float = 0;

	override public function create():Void {
		super.create();
		if (Conductor.menu == null) Conductor.menu = new Conductor();
			if (conductor.audio == null || !conductor.audio.playing)
				conductor.loadMusic('freakyMenu', 0.8, (audio:FlxSound) -> audio.play());

		camPoint = new FlxObject(0, 0, 1, 1);
		camera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		bg = new BaseSprite('menus/menuBG');
		bg.scrollFactor.set(0.1, 0.1);
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		bg2 = new BaseSprite('menus/menuDesat');
		bg2.scrollFactor.copyFrom(bg.scrollFactor);
		bg2.scale.copyFrom(bg.scale);
		bg2.updateHitbox();
		bg2.visible = false;
		bg2.antialiasing = true;
		bg2.color = 0xfffd719b;
		add(bg2);

		if (itemLineUp == null || itemLineUp.length < 1)
			itemLineUp = ['storymode', 'freeplay', 'options', 'credits'];

		menuItems = new FlxTypedGroup<BaseSprite>();
		for (i => name in itemLineUp) {
			if ( // funny null check
				Paths.fileExists('images/menus/main/$name.png') ||
				Paths.multExst('images/menus/main/$name', Paths.atlasFrameExts) != ''
			) {} else continue;

			var item:BaseSprite = new BaseSprite(0, 60 + (i * 160), 'menus/main/$name');
			item.animation.addByPrefix('idle', '$name idle', 24);
			item.animation.addByPrefix('selected', '$name selected', 24);
			item.animation.play('idle');
			item.centerOffsets();
			item.centerOrigin();
			item.screenCenter(X);
			item.antialiasing = true;
			menuItems.add(item);
		}
		changeSelection();
		add(menuItems);

		var highMid:PositionStruct = PositionStruct.getObjMidpoint(menuItems.members[0]);
		var lowMid:PositionStruct = PositionStruct.getObjMidpoint(menuItems.members[menuItems.length - 1]);

		highestY = highMid.y;
		lowestY = lowMid.y;
		camPoint.setPosition(
			FlxMath.lerp(highMid.x, lowMid.x, FlxMath.remapToRange(menuItems.length / 2, 1, menuItems.length, 0, 1)),
			FlxMath.lerp(highestY, lowestY, FlxMath.remapToRange(visualSelected, 0, menuItems.length - 1, 0, 1))
		);
		camera.snapToTarget();

		var theText:String = 'Imaginative Engine: Version ${Main.engineVersion}';
		#if debug
		theText += ' ~ Debug Build';
		#elseif !final
		theText += ' ~ Test Build';
		#end
		if (Main.engineVersion < Main.latestVersion) theText += '\nAn update is available! ${Main.latestVersion}, please stay up-to-date.';
		theText += '\nMade relatively from scratch!';

		versionTxt = new FlxText(5, 0, 0, theText);
		versionTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		versionTxt.y = FlxG.height - versionTxt.height - 5;
		versionTxt.scrollFactor.set();
		add(versionTxt);
	}

	override public function update(elapsed:Float):Void {
		if (conductor.audio.volume < 0.8)
			conductor.audio.volume += 0.5 * elapsed;

		super.update(elapsed);

		if (canSelect) {
			if (Controls.uiUp) {
				changeSelection(-1);
				visualSelected = curSelected;
			}
			if (Controls.uiDown) {
				changeSelection(1);
				visualSelected = curSelected;
			}

			if (FlxG.mouse.wheel != 0) {
				changeSelection(-1 * FlxG.mouse.wheel);
				visualSelected = curSelected;
			}
			if (PlatformUtil.mouseJustMoved())
				for (i => item in menuItems.members)
					if (FlxG.mouse.overlaps(item))
						changeSelection(i, true);

			if (FlxG.keys.justPressed.HOME) {
				changeSelection(0, true);
				visualSelected = curSelected;
			}
			if (FlxG.keys.justPressed.END) {
				changeSelection(menuItems.length - 1, true);
				visualSelected = curSelected;
			}

			if (Controls.back) {
				FunkinUtil.playMenuSFX(CANCEL);
				FlxG.switchState(new TitleScreen());
			}
			if (Controls.accept || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuItems.members[curSelected]))) {
				if (visualSelected != curSelected) {
					visualSelected = curSelected;
					FunkinUtil.playMenuSFX(SCROLL, 0.7);
				} else selectCurrent();
			}
		}

		camPoint.y = FlxMath.lerp(highestY, lowestY, FlxMath.remapToRange(visualSelected, 0, menuItems.length - 1, 0, 1));
	}

	public function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, menuItems.length - 1);
		if (prevSelected != curSelected)
			FunkinUtil.playMenuSFX(SCROLL, 0.7);

		for (i => item in menuItems.members) {
			item.animation.play(i == curSelected ? 'selected' : 'idle');
			item.centerOffsets();
			item.centerOrigin();
		}
	}

	public function selectCurrent():Void {
		canSelect = false;

		FunkinUtil.playMenuSFX(CONFIRM);

		FlxFlicker.flicker(bg2, 1.1, 0.6, false);
		FlxFlicker.flicker(menuItems.members[curSelected], 1.1, 0.6, true, false, (flicker:FlxFlicker) -> {
			switch (itemLineUp[curSelected]) {
				case 'storymode':
					FlxG.switchState(new StoryMenu());
				case 'freeplay':
					FlxG.switchState(new FreeplayMenu());
				case 'donate':
					PlatformUtil.openURL('https://ninja-muffin24.itch.io/funkin/purchase');
					canSelect = true;
				case 'merch':
					PlatformUtil.openURL('https://needlejuicerecords.com/pages/friday-night-funkin');
					canSelect = true;
				case 'options':
					FlxG.switchState(new OptionsMenu());
				case 'credits':
					FlxG.switchState(new CreditsMenu());
			}
		});
	}
}