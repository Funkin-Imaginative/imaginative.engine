package;

import js.html.PlaybackDirection;
import js.html.idb.Factory;
import flixel.FlxSprite;
import ColorizeRGB;

class Strum extends FlxSprite {

	var ColorizeRGB:ColorizeRGB;
	var resetAnim:Float = 0;
	var noteData:Int = 0;
	var downScroll:Bool = false;
	var sustainReduce:Bool = true;
	var isStrumPixel:Bool = false;
	var daPixelZoom:Float = 6;
	
	var texture(default, set):String = 'NOTE_assets';
	function set_texture(value:String):String {
		if (texture != value || isStrumPixel != isStrumPixel) {
			texture = value;
			reloadStrum();
		}
		return value;
	}

	public function new(x:Float, y:Float, setData:Int, isPixel:Bool = false) {
		this.noteData = setData;
		super(x, y);

		var skin:String = 'NOTE_assets';
		if (PlayState.chartData.noteSkin != null && PlayState.chartData.noteSkin.length > 1) skin = PlayState.chartData.arrowSkin;
		
		texture = skin;
		scrollFactor.set();
	}

	public function reloadStrum() {
		var lastAnim:String = null;
		if (animation.curAnim != null) lastAnim = animation.curAnim.name;

		if (isStrumPixel) {
			loadGraphic(Paths.image('pixelUI/' + texture));
			width /= 4;
			height /= 5;
			loadGraphic(Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * this.daPixelZoom));

			animation.add('purple', [4]);
			animation.add('blue', [5]);
			animation.add('green', [6]);
			animation.add('red', [7]);
			switch (noteData % 4) {
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		} else {
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.data.globalAntialiasing;
			setGraphicSize(Std.int(width * 0.7));

			switch (noteData % 4)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		}
		updateHitbox();
		if (lastAnim != null) playAnim(lastAnim, true);
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		if (animation.curAnim.name == 'confirm' && !isStrumPixel) centerOrigin();
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?startFrame:Int = 0) {
		animation.play(anim, force, reversed, startFrame);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			ColorizeRGB.red = 0;
			ColorizeRGB.green = 0;
			ColorizeRGB.blue = 0;
		} else {
			if (noteData > -1 && noteData < ClientPrefs.data.arrowRGB.length) {
				ColorizeRGB.red = ClientPrefs.data.arrowRGB[noteData][0];
				ColorizeRGB.green = ClientPrefs.data.arrowRGB[noteData][1];
				ColorizeRGB.blue = ClientPrefs.data.arrowRGB[noteData][2];
			}
			if(animation.curAnim.name == 'confirm' && !isStrumPixel) centerOrigin();
		}
	}
}