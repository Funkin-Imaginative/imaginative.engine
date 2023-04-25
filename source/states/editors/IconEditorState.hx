package states.editors;

import flixel.FlxObject;
import flixel.graphics.FlxGraphic;

import flixel.animation.FlxAnimation;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITabMenu;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import lime.system.Clipboard;
import haxe.Json;

import objects.HealthIcon;

#if MODS_ALLOWED import sys.FileSystem; #end

class IconEditorState extends MusicBeatState {
	var icon:HealthIcon;
	var camFollow:FlxObject;
	
    public function new() {
		super.create();
    }
	
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;

	override function create() {
		camHUD = new FlxCamera();
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.reset(camHUD);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camMenu, false);
		FlxG.cameras.setDefaultDrawTarget(camHUD, true);

		icon = new HealthIcon();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = FlxColor.fromHSB(FlxG.random.int(0, 359), FlxG.random.float(0, 0.8), FlxG.random.float(0.3, 1));
		add(bg);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE) {
			MusicBeatState.switchState(new states.editors.MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.mouse.visible = false;
			return;
		}
	}
}