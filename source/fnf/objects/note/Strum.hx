package fnf.objects.note;

import fnf.graphics.shaders.ColorSwap;

class Strum extends FlxSprite {
	public var noteData:Int = 0;
	public var colorSwap:ColorSwap;

	private var col(get, never):String;
	private function get_col():String return ['purple', 'blue', 'green', 'red'][noteData];
	private var dir(get, never):String;
	private function get_dir():String return ['left', 'down', 'up', 'right'][noteData];
	override public function new(x:Float, y:Float, data:Int, pixel:Bool = false) {
		super(x, y);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = data;

		if (pixel) {
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

			animation.add('note', [data + 4]);

			animation.add('static', [data], 24);
			animation.add('press', [data + 4, data + 8], 24, false);
			animation.add('confirm', [data + 12, data + 16], 24, false);

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();
		} else {
			frames = Paths.getSparrowAtlas('NOTE_assets');

			animation.addByPrefix('note', '${col}0');

			animation.addByPrefix('static', 'arrow${dir.toUpperCase()}', 24);
			animation.addByPrefix('press', '$dir press', 24, false);
			animation.addByPrefix('confirm', '$dir confirm', 24, false);

			antialiasing = true;
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
		}

		playAnim('static', true);

		animation.finishCallback = function(name:String) {
			switch (name) {
				case 'press': playAnim('static', true);
				case 'confirm': playAnim('press', true);
			}
		}
	}

	override public function update(elapsed:Float) {

	}

	public function playAnim(name:String, force:Bool = false) {
		animation.play(name, force);
		centerOffsets();
		centerOrigin();
	}
}