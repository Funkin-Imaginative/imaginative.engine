package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxTimer;


class TitleState extends MusicBeatState {
	private var titleLogo:FlxSprite;
	private var enterText:FlxSprite;
	private var gfBop:FlxSprite;
	public var exampleTxt:FlxText;

	override public function create() {
		super.create();

		FlxG.sound.playMusic(Paths.music('freakyMenu'));

		titleLogo = new FlxSprite(-120, -70);
		titleLogo.frames = Paths.getSparrowAtlas('logoBumpin');
		titleLogo.animation.addByPrefix('bumpin', 'logo bumpin0', 24, true);
		titleLogo.animation.play('bumpin', true);
		titleLogo.angle = -10;
		add(titleLogo);
		titleLogo.antialiasing = true;

		enterText = new FlxSprite(0, 600);
		enterText.frames = Paths.getSparrowAtlas('titleEnter');
		enterText.animation.addByPrefix('idle', 'ENTER IDLE0');
		enterText.animation.addByPrefix('pressed', 'ENTER PRESSED0');
		enterText.animation.addByPrefix('freeze', 'ENTER FREEZE0');
		enterText.animation.play('idle');
		enterText.screenCenter(X);
		enterText.x += 210;
		add(enterText);
		enterText.color = 0x00FFFF;
		enterText.antialiasing = true;

		gfBop = new FlxSprite(550, -20);
		gfBop.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfBop.animation.addByPrefix('boppin', 'gfDance0', 24, true);
		gfBop.animation.play('boppin', true);
		gfBop.scale.x = 0.8;
		gfBop.scale.y = 0.8;
		add(gfBop);
		gfBop.antialiasing = true;
	
		exampleTxt = new FlxText(0, 0, FlxG.width, 'Press Enter to Start', 30);
		

	}

	override public function update(elapsed:Float) {

        if (FlxG.keys.justPressed.ENTER) {
            enterText.animation.play('pressed');
            enterText.color = 0xFFFFFF;
            new FlxTimer().start(1, function (tmr:FlxTimer) {
                MusicBeatState.switchState(new PlayState());
            });
        }

		super.update(elapsed);
	}
}
