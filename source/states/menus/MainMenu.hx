package states.menus;

import haxe.macro.Compiler;
import flixel.effects.FlxFlicker;

/**
 * This is the main menu... what else were you expecting this to say?
 */
class MainMenu extends BeatState {
	// Menu related vars.
	var canSelect:Bool = true;
	static var prevSelected:Int = 0;
	static var curSelected:Int = 0;
	var visualSelected:Int = curSelected;
	inline function selectionCooldown(duration:Float = 0.1):FlxTimer {
		canSelect = false;
		return new FlxTimer().start(duration, (_:FlxTimer) -> canSelect = true);
	}

	// Things to select.
	var itemLineUp:Array<String> = Paths.getFileContent(Paths.txt('images/menus/main/itemLineUp')).trimSplit('\n');

	// Objects in the state.
	var bg:FlxSprite;
	var flashBg:FlxSprite;
	var menuItems:FlxTypedGroup<BaseSprite>;
	var versionTxt:FlxText;
	var definedTagsText:FlxText;

	// Camera management.
	var camPoint:FlxObject;
	var highestY:Float = 0;
	var lowestY:Float = 0;

	override public function create():Void {
		super.create();
		// Might try to simplify this.
		if (!conductor.audio.playing)
			conductor.loadMusic('freakyMenu', 0.8, (_:FlxSound) -> conductor.play());

		// Camera position.
		camPoint = new FlxObject(0, 0, 1, 1);
		camera.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		// Menu elements.
		bg = new FlxSprite().getBGSprite(FlxColor.YELLOW);
		bgColor = bg.color;
		bg.scrollFactor.set(0.1, 0.1);
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		flashBg = new FlxSprite().getBGSprite(FlxColor.MAGENTA); // flashing bg
		flashBg.scrollFactor.copyFrom(bg.scrollFactor);
		flashBg.scale.copyFrom(bg.scale);
		flashBg.updateHitbox();
		flashBg.visible = false;
		add(flashBg);

		if (itemLineUp == null || itemLineUp.length < 1)
			itemLineUp = ['storymode', 'freeplay', 'options', 'credits'];

		menuItems = new FlxTypedGroup<BaseSprite>(); // menu items
		for (i => name in itemLineUp) {
			if (!Paths.spriteSheetExists('menus/main/$name')) continue; // funny null check

			var item:BaseSprite = new BaseSprite(0, 60 + (i * 160), 'menus/main/$name');
			item.animation.addByPrefix('idle', '$name idle', 24);
			item.animation.addByPrefix('selected', '$name selected', 24);
			item.animation.play('idle');
			item.centerOffsets();
			item.centerOrigin();
			item.screenCenter(X);
			menuItems.add(item);
		}
		changeSelection();
		add(menuItems);

		// wierd camera posing vars
		var highMid:Position = Position.getObjMidpoint(menuItems.members[0]);
		var lowMid:Position = Position.getObjMidpoint(menuItems.members[menuItems.length - 1]);

		camPoint.setPosition(
			FlxMath.lerp(highMid.x, lowMid.x, FlxMath.remapToRange(menuItems.length / 2, 1, menuItems.length, 0, 1)),
			FlxMath.lerp(highestY = highMid.y, lowestY = lowMid.y, FlxMath.remapToRange(visualSelected, 0, menuItems.length - 1, 0, 1))
		);
		camera.snapToTarget();

		// version text setup
		var theText:String = '';
		final buildTag:Null<String> = #if debug 'Debug' #elseif !release 'Test' #elseif (debug && release) 'Debugging Release' #else null #end;
		if (buildTag != null) theText += ' ~ $buildTag Build ~ \n';
		theText += 'Imaginative Engine';
		#if KNOWS_VERSION_ID
		theText += ' v${Main.engineVersion}';
		if (Main.engineVersion < Main.latestVersion) theText += '\nAn update is available! ${Main.latestVersion} is out, please stay up-to-date.';
		#end
		theText += '\nMade relatively from scratch!';

		versionTxt = new FlxText(5, theText);
		versionTxt.setFormat(Paths.font('vcr'), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		versionTxt.y = FlxG.height - versionTxt.height - 5;
		versionTxt.scrollFactor.set();
		add(versionTxt);

		// defined text setup
		var theText:String = ' ~ Defined Compiler Tags ~ ';
		theText += '\n${Sys.systemName()} :Platform';
		theText += '\n${Compiler.getDefine('KNOWS_VERSION_ID') != null} :Know\'s Verison';
		theText += '\n${Compiler.getDefine('CHECK_FOR_UPDATES') != null} :Know\'s When To Update';
		theText += '\n${Compiler.getDefine('MOD_SUPPORT') != null} :Has Mod Support';
		theText += '\n${Compiler.getDefine('SCRIPT_SUPPORT') != null} :Has Script Support';
		theText += '\n${Compiler.getDefine('DISCORD_RICH_PRESENCE') != null} :Has Discord Connectivity';
		theText += '\n${Compiler.getDefine('ALLOW_VIDEOS') != null} :Can Play Videos';

		definedTagsText = new FlxText(theText);
		definedTagsText.setFormat(Paths.font('vcr'), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		definedTagsText.x = FlxG.width - definedTagsText.width - 5;
		definedTagsText.y = FlxG.height - definedTagsText.height - 5;
		definedTagsText.scrollFactor.set();
		add(definedTagsText);
	}

	override public function update(elapsed:Float):Void {
		if (conductor.audio.volume < 0.8)
			conductor.audio.volume += 0.5 * elapsed;

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
				FunkinUtil.playMenuSFX(CancelSFX);
				BeatState.switchState(new TitleScreen());
			}
			if (Controls.accept || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuItems.members[curSelected]))) {
				if (visualSelected != curSelected) {
					visualSelected = curSelected;
					FunkinUtil.playMenuSFX(ScrollSFX, 0.7);
				} else selectCurrent();
			}
		}

		camPoint.y = FlxMath.lerp(highestY, lowestY, FlxMath.remapToRange(visualSelected, 0, menuItems.length - 1, 0, 1));
	}

	function changeSelection(move:Int = 0, pureSelect:Bool = false):Void {
		prevSelected = curSelected;
		curSelected = FlxMath.wrap(pureSelect ? move : (curSelected + move), 0, menuItems.length - 1);
		if (prevSelected != curSelected)
			FunkinUtil.playMenuSFX(ScrollSFX, 0.7);

		for (i => item in menuItems.members) {
			item.animation.play(i == curSelected ? 'selected' : 'idle');
			item.centerOffsets();
			item.centerOrigin();
		}
	}

	function selectCurrent():Void {
		selectionCooldown();

		FunkinUtil.playMenuSFX(ConfirmSFX);

		FlxFlicker.flicker(flashBg, 1.1, 0.6, false);
		FlxFlicker.flicker(menuItems.members[curSelected], 1.1, 0.6, true, false, (flicker:FlxFlicker) -> {
			switch (itemLineUp[curSelected]) {
				case 'storymode':
					BeatState.switchState(new StoryMenu());
				case 'freeplay':
					BeatState.switchState(new FreeplayMenu());
				case 'donate':
					PlatformUtil.openURL('https://ninja-muffin24.itch.io/funkin/purchase');
				case 'kickstarter':
					PlatformUtil.openURL('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
				case 'merch':
					PlatformUtil.openURL('https://needlejuicerecords.com/pages/friday-night-funkin');
				case 'options':
					BeatState.switchState(new OptionsMenu());
				case 'credits':
					BeatState.switchState(new CreditsMenu());
			}
		});
	}
}