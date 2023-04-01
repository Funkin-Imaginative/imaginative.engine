package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;


class TitleState extends FlxState {
    private var titleLogo:FlxSprite;
    public var exampleTxt:FlxText;

    override public function create() {
        super.create();

        titleLogo = new FlxSprite(100, 100);
        titleLogo.frames = Paths.getSparrowAtlas('logoBumpin');
        titleLogo.animation.addByPrefix('bumpin', 'logo bumpin0', 24, true);
        titleLogo.angle = 20;

        exampleTxt = new FlxText(0, 0, FlxG.width, 'Press Enter to Start', 30);

    }

    override public function update(elapsed:Float) {

        //trace("HELLO?!?!?!");

        super.update(elapsed);
    }
}
