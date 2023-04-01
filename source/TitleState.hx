package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;


class TitleState extends FlxState {
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

        exampleTxt = new FlxText(0, 0, FlxG.width, 'Press Enter to Start', 30);
        

    }

    override public function update(elapsed:Float) {

        //trace("HELLO?!?!?!");

        super.update(elapsed);
    }
}
