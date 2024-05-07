package fnf.objects.note;

import fnf.graphics.shaders.ColorSwap;

class Strum extends FlxSprite {
	var isPixel:Bool = false;
	var pixelZoom:Float = 6;

	override public function new(x:Float, y:Float, data:Int, pixel:Bool = false) {
		super(x, y);
		var colorswap:ColorSwap = new ColorSwap();
		shader = colorswap.shader;
		isPixel = pixel;

		if (isPixel) {
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
			animation.add('purple', [4]);
			animation.add('blue', [5]);
			animation.add('green', [6]);
			animation.add('red', [7]);

			antialiasing = false;
			setGraphicSize(Std.int(width * pixelZoom));
			updateHitbox();

			switch (data) {
				case 0:
					animation.add('static', [0]);
					animation.add('press', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('press', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('press', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('press', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		} else {
			frames = Paths.getSparrowAtlas('NOTE_assets');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = true;
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();

			switch (data) {
				case 0:
					animation.addByPrefix('static', 'arrow static instance 1');
					animation.addByPrefix('press', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					animation.addByPrefix('static', 'arrow static instance 2');
					animation.addByPrefix('press', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('static', 'arrow static instance 4');
					animation.addByPrefix('press', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					animation.addByPrefix('static', 'arrow static instance 3');
					animation.addByPrefix('press', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		}

		animation.finishCallback = function(name:String) {
			if (name == 'confirm') {
				playAnim('press', true);
			}
		}
	}

	override public function update(elapsed:Float) {

	}

	public function playAnim(name:String, force:Bool = false, reverse:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reverse, frame);
		centerOffsets();
		centerOrigin();
	}
}