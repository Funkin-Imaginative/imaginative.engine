package imaginative.states.menus;

import flixel.effects.FlxFlicker;

/**
 * This is the main menu... what else were you expecting this to say?
 */
class MainMenu extends BeatState {
	// Things to select.
	var itemLineUp:Array<String> = [
		for (item in Paths.readFolderOrderTxt('images/menus/main', 'xml', false, false))
			item.path
	];

	// Objects in the state.
	var bg:MenuSprite;
	var menuItems:SelectionHandler<ChoiceEvent>;

	var mainTextsGroup:FlxTypedSpriteGroup<FlxText>;
	var buildTxt:FlxText;
	var versionTxt:FlxText;

	var definedTextsGroup:FlxTypedSpriteGroup<FlxText>;
	var compilerTxt:FlxText;
	var definedTagsTxt:FlxText;
	var tagResultsTxt:FlxText;

	// Camera management.
	var camPoint:FlxObject;
	var highestY:Float = 0;
	var lowestY:Float = 0;

	override public function create():Void {
		super.create();
		#if FLX_DEBUG
		FlxG.game.debugger.watch.add('Previous Selection',    FUNCTION(() -> return    menuItems?.previousValue ?? 0));
		FlxG.game.debugger.watch.add('Current Selection',     FUNCTION(() -> return     menuItems?.currentValue ?? 0));
		FlxG.game.debugger.watch.add('Visual Selection',      FUNCTION(() -> return      menuItems?.currentView ?? 0));
		#end
		if (!conductor.playing)
			conductor.loadMusic('freakyMenu', (_:FlxSound) -> conductor.play(0.8));

		// Camera position.
		mainCamera.setFollow(camPoint = new FlxObject(0, 0, 1, 1), 0.2);
		mainCamera.setZooming(1, 0.16);
		mainCamera.zoomEnabled = true;
		add(camPoint);

		// Menu elements.
		var event:MenuBackgroundEvent = eventCall('uponMenuBackgroundCreation', new MenuBackgroundEvent());
		bg = new MenuSprite(event.color, event.funkinColor, event.imagePathType);
		bgColor = bg.blankBg.color;
		bg.scrollFactor.set();
		bg.updateScale(1.2);
		bg.screenCenter();
		add(bg);

		if (itemLineUp == null || itemLineUp.empty())
			itemLineUp = ['storymode', 'freeplay', 'options', 'credits'];

		menuItems = new SelectionHandler<ChoiceEvent>(scriptName, false, item -> return eventCall('uponSelection', new ChoiceEvent(item.itemId)), eventCall);
		menuItems.initialize(
			itemLineUp,
			(index:Int, group:SelectionItem<ChoiceEvent>) -> {
				final id = group.itemId;
				if (!Paths.spriteSheetExists('menus/main/$id')) {
					_log('[MainMenu] Item $id doesn\'t have a spritesheet.');
					return false; // funny null check
				}

				final item:BaseSprite = new BaseSprite('menus/main/$id');
				item.animation.addByPrefix('idle', '$id idle', 24);
				item.animation.addByPrefix('selected', '$id selected', 24);
				item.playAnim('idle');
				item.centerOffsets();
				item.centerOrigin();
				group.extra.set('item', item);

				group._isLocked = (value:Bool) -> {
					item.color = FlxColor.WHITE;
					if (value) item.color -= 0xFF646464;
				}
				group._canSelect = (value:Bool) ->
					item.alpha = value ? 1 : 0.5;
				switch (id) {
					case 'donate' | 'kickstarter' | 'merch':
						group.canSelect = false;
					case 'credits':
						group.isLocked = true;
				}

				group.add(item);
				group.screenCenter(X);
				group.y = 60 + (index * 160);
				return true;
			},
			(index:Int, event:SelectionChangeEvent, group:SelectionItem<ChoiceEvent>) -> {
				final item:BaseSprite = group.extra.get('item');
				item.playAnim('selected');
				item.centerOffsets();
				item.centerOrigin();
			},
			(index:Int, event:ChoiceEvent, group:SelectionItem<ChoiceEvent>) -> {
				// using "group.itemId" instead of "event.choice" to make sure each item does what it's supposed to on select.
				switch (group.itemId) {
					case 'storymode':
						BeatState.switchState(() -> new StoryMenu());
					case 'freeplay':
						BeatState.switchState(() -> new FreeplayMenu());
					case 'donate':
						PlatformUtil.openURL('https://ninja-muffin24.itch.io/funkin/purchase');
					case 'kickstarter':
						PlatformUtil.openURL('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
					case 'merch':
						PlatformUtil.openURL('https://needlejuicerecords.com/pages/friday-night-funkin');
					case 'options':
						menuItems.setCooldown(0.4); // extend cooldown
						conductor.fadeOut(0.4, (_:FlxTween) -> BeatState.switchState(() -> new OptionsMenu()));
					case 'credits':
						BeatState.switchState(() -> new CreditsMenu());
				}
			},
			(index:Int, event:SelectionChangeEvent, group:SelectionItem<ChoiceEvent>) -> {
				final item:BaseSprite = group.extra.get('item');
				item.playAnim('idle');
				item.centerOffsets();
				item.centerOrigin();
			}
		);
		menuItems.lockedEffect = (item:SelectionItem<ChoiceEvent>, ?event:ChoiceEvent) -> {
			item.extra.get('shakeTween')?.cancel();
			final time:Float = {
				final sound = event?.playMenuSFX(CancelSFX, true);
				if (sound == null) menuItems.defaultCooldown;
				else sound.time / 1000;
			}
			final sprite = item.extra.get('item');
			final ogX:Float = sprite.x;
			// TODO: Figure out why the shake tween isn't working.
			item.extra.set('shakeTween', FlxTween.shake(sprite, 1, time, X, {
				onStart: tween -> menuItems.setCooldown(time),
				onComplete: tween -> sprite.x = ogX
			}));
		}
		@:privateAccess menuItems.selectCurrent = () -> {
			if (menuItems.currentValue == -1) {
				_log('${menuItems.traceTag} Nothing selected.', DebugMessage);
				return; // unselected
			}
			menuItems.setCooldown();

			final curItem = menuItems.members[menuItems.currentValue];
			_log('${menuItems.traceTag} Selecting item "${curItem.itemId}". (index:${menuItems.currentValue})', DebugMessage);
			final event:ChoiceEvent = menuItems.eventCreator(curItem);
			if (event.prevented) return;

			if (curItem.isLocked)
				menuItems.lockedEffect(curItem, event);
			else {
				event.playMenuSFX(ConfirmSFX);
				FlxFlicker.flicker(curItem, 1.1, 0.6, true, false, (flicker:FlxFlicker) -> {
					curItem.selectFunc(event);
					bgColor = bg.changeColor();
				}, (flicker:FlxFlicker) -> bgColor = bg.changeColor(flicker.object.visible ? FlxColor.YELLOW : FlxColor.MAGENTA));
			}
		}
		add(menuItems);

		// wierd camera posing vars
		var highMid:Position = Position.getObjMidpoint(menuItems.members[0]);
		var lowMid:Position = Position.getObjMidpoint(menuItems.members.last());

		bg.y = FlxMath.lerp(0, FlxG.height - bg.height, FlxMath.remapToRange(menuItems.currentView, 0, menuItems.length - 1, 0, 1));
		camPoint.setPosition(
			FlxMath.lerp(highMid.x, lowMid.x, FlxMath.remapToRange(menuItems.length / 2, 1, menuItems.length, 0, 1)),
			FlxMath.lerp(highestY = highMid.y, lowestY = lowMid.y, FlxMath.remapToRange(menuItems.currentView, 0, menuItems.length - 1, 0, 1))
		);
		mainCamera.snapToTarget();

		// version text setup
		mainTextsGroup = new FlxTypedSpriteGroup<FlxText>(5);
		var stability:String = #if debug 'Debug' #elseif !release 'Stable' #elseif (debug && release) 'Debugging Release' #else 'Release' #end;
		buildTxt = new FlxText(' ~ $stability Build ~ ');
		buildTxt.setFormat(Paths.font('vcr').format(), 16, CENTER, OUTLINE, FlxColor.BLACK);
		mainTextsGroup.add(buildTxt);

		var theText:String = 'Imaginative Engine';
		#if KNOWS_VERSION_ID
		theText += ' v${Main.engineVersion}';
		#if CHECK_FOR_UPDATES
		if (Main.updateAvailable)
			theText += '\nAn update is available! ${Main.latestVersion} is out, please stay up-to-date.';
		#end
		#end
		theText += '\nMade relatively from scratch!';

		versionTxt = new FlxText(0, buildTxt.height + 5, theText);
		versionTxt.setFormat(Paths.font('vcr').format(), 16, LEFT, OUTLINE, FlxColor.BLACK);
		mainTextsGroup.add(versionTxt);

		buildTxt.fieldWidth = versionTxt.width;

		mainTextsGroup.scrollFactor.set();
		mainTextsGroup.y = mainCamera.height - mainTextsGroup.height - 5;
		add(mainTextsGroup);

		// defined text setup
		definedTextsGroup = new FlxTypedSpriteGroup<FlxText>();

		compilerTxt = new FlxText(' ~ Defined Compiler Tags ~ ');
		compilerTxt.setFormat(Paths.font('vcr').format(), 16, CENTER, OUTLINE, FlxColor.BLACK);
		definedTextsGroup.add(compilerTxt);

		var theText:Array<Array<String>> = [];
		theText.push(['Platform', Sys.systemName()]); // I hate when code is a bitch.
		theText.push(['Know\'s Version', #if KNOWS_VERSION_ID 'true' #else 'false' #end]);
		theText.push(['Know\'s When To Update', #if CHECK_FOR_UPDATES 'true' #else 'false' #end]);
		theText.push(['Has Mod Support', #if MOD_SUPPORT 'true' #else 'false' #end]);
		theText.push(['Has Script Support', #if SCRIPT_SUPPORT 'true' #else 'false' #end]);
		theText.push(['Has Discord Connectivity', #if DISCORD_RICH_PRESENCE 'true' #else 'false' #end]);
		theText.push(['Can Play Videos', #if ALLOW_VIDEOS 'true' #else 'false' #end]);

		definedTagsTxt = new FlxText(0, compilerTxt.height + 5, [for (text in theText) text[0]].join(':\n'));
		definedTagsTxt.setFormat(Paths.font('vcr').format(), 16, LEFT, OUTLINE, FlxColor.BLACK);
		definedTagsTxt.fieldWidth = definedTagsTxt.width;
		definedTextsGroup.add(definedTagsTxt);

		tagResultsTxt = new FlxText(definedTagsTxt.width + 10, compilerTxt.height + 5, [for (text in theText) text[1]].join('\n'));
		tagResultsTxt.setFormat(Paths.font('vcr').format(), 16, LEFT, OUTLINE, FlxColor.BLACK);
		definedTextsGroup.add(definedTagsTxt);

		compilerTxt.fieldWidth = definedTagsTxt.width + 10 + (tagResultsTxt.fieldWidth = tagResultsTxt.width);

		definedTextsGroup.scrollFactor.set();
		definedTextsGroup.x = mainCamera.width - definedTextsGroup.width - 5;
		definedTextsGroup.y = mainCamera.height - definedTextsGroup.height - 5;
		add(definedTextsGroup);
	}

	override public function update(elapsed:Float):Void {
		if (conductor.volume < 0.8)
			conductor.volume += 0.5 * elapsed;
		super.update(elapsed);

		if (menuItems.allowSelect && Controls.global.back) {
			var event:MenuSFXEvent = eventCall('uponExitingMenu', new MenuSFXEvent());
			if (!event.prevented) {
				event.playMenuSFX(CancelSFX);
				BeatState.switchState(() -> new TitleScreen());
			}
		}

		var range:Float = FlxMath.remapToRange(menuItems.currentView, 0, menuItems.length - 1, 0, 1);
		camPoint.y = FlxMath.lerp(highestY, lowestY, range);
		bg.y = FunkinUtil.lerp(bg.y, FlxMath.lerp(0, FlxG.height - bg.height, range), 0.16);
	}
}