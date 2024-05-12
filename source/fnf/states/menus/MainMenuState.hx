package fnf.states.menus;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.ui.FlxButton;
import flixel.graphics.frames.FlxAtlasFrames;

import lime.app.Application;

import fnf.ui.AtlasMenuList;
import fnf.ui.MenuList;
import fnf.ui.Prompt;

import fnf.graphics.FunkinCamera;

class MainMenuState extends MusicBeatState {
	var menuItems:MainMenuList;

	var magenta:FlxSprite;
	var camPoint:BareCameraPoint;

	override function create() {
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing) FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0.17);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camPoint = new BareCameraPoint();
		add(camPoint);

		magenta = new FlxSprite(Paths.image('menuDesat'));
		magenta.scrollFactor.x = bg.scrollFactor.x;
		magenta.scrollFactor.y = bg.scrollFactor.y;
		magenta.setGraphicSize(Std.int(bg.width));
		magenta.updateHitbox();
		magenta.x = bg.x;
		magenta.y = bg.y;
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		if (SaveManager.getOption('sensitivity.lights')) add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new MainMenuList();
		add(menuItems);
		menuItems.onChange.add(onMenuItemChange);
		menuItems.onAcceptPress.add(function(_)
		{
			FlxFlicker.flicker(magenta, 1.1, 0.15, false, true);
		});

		menuItems.enabled = false; // disable for intro
		menuItems.createItem('story mode', function() startExitState(new StoryMenuState()));
		menuItems.createItem('freeplay', function() startExitState(new FreeplayState()));
		// addMenuItem('options', function () startExitState(new OptionMenu()));

		//menuItems.createItem('credits', function () startExitState(new OptionsState()));

		menuItems.createItem('options', function() startExitState(new OptionsState()));

		// center vertically
		var spacing = 160;
		var top = (FlxG.height - (spacing * (menuItems.length - 1))) / 2;
		for (i in 0...menuItems.length) {
			var menuItem = menuItems.members[i];
			menuItem.x = FlxG.width / 2;
			menuItem.y = top + spacing * i;
		}

		FlxG.cameras.reset(new FunkinCamera());
		FlxG.camera.follow(camPoint.realPos, null, 0.06);
		// FlxG.camera.setScrollBounds(bg.x, bg.x + bg.width, bg.y, bg.y + bg.height * 1.2);

		var versionShit:FlxText = new FlxText(5, 0, 0, 'Imaginative Engine v${Main.engineVersion} (EARLY ALPHA)\nInsert Version Warning Here\nBuilt off Friday Night Funkin\' v0.2.8', 12);
		versionShit.y = FlxG.height - versionShit.height - 5;
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();
	}

	override function finishTransIn() {
		super.finishTransIn();

		menuItems.enabled = true;
	}

	function onMenuItemChange(selected:MenuItem) {
		camPoint.setPoint(selected.getGraphicMidpoint().x, selected.getGraphicMidpoint().y);
	}

	public function openPrompt(prompt:Prompt, onClose:Void->Void)
	{
		menuItems.enabled = false;
		prompt.closeCallback = function()
		{
			menuItems.enabled = true;
			if (onClose != null)
				onClose();
		}

		openSubState(prompt);
	}

	function startExitState(state:FlxState)
	{
		menuItems.enabled = false; // disable for exit
		var duration = 0.4;
		menuItems.forEach(function(item)
		{
			if (menuItems.selectedIndex != item.ID)
			{
				FlxTween.tween(item, {alpha: 0}, duration, {ease: FlxEase.quadOut});
			}
			else
			{
				item.visible = false;
			}
		});

		new FlxTimer().start(duration, function(_) FlxG.switchState(state));
	}

	override function update(elapsed:Float)
	{
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (_exiting)
			menuItems.enabled = false;

		if (controls.BACK && menuItems.enabled && !menuItems.busy)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new TitleState());
		}

		super.update(elapsed);
	}
}

private class MainMenuList extends MenuTypedList<MainMenuItem>
{
	public var atlas:FlxAtlasFrames;

	public function new()
	{
		atlas = Paths.getSparrowAtlas('main_menu');
		super(Vertical);
	}

	public function createItem(x = 0.0, y = 0.0, name:String, callback, fireInstantly = false)
	{
		var item = new MainMenuItem(x, y, name, atlas, callback);
		item.fireInstantly = fireInstantly;
		item.ID = length;

		return addItem(name, item);
	}

	override function destroy()
	{
		super.destroy();
		atlas = null;
	}
}

private class MainMenuItem extends AtlasMenuItem
{
	public function new(x = 0.0, y = 0.0, name, atlas, callback)
	{
		super(x, y, name, atlas, callback);
		scrollFactor.set();
	}

	override function changeAnim(anim:String)
	{
		super.changeAnim(anim);
		// position by center
		centerOrigin();
		offset.copyFrom(origin);
	}
}
