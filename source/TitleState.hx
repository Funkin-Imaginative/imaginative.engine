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

        

        exampleTxt = new FlxText(0, 0, FlxG.width, 'Press Enter to Start', 30);

    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}
