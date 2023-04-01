package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;

import flixel.tweens.FlxTween;
class MusicBeatState extends FlxUIState {

	override public function create() {
        // THIS STUFF WILL HAPPEN BEFORE SUPER CREATE ON ANY STATE



		super.create();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

    public function beatHit():Void
    {
        //trace('Beat: ' + curBeat);
        // Need to Code This
    }
}