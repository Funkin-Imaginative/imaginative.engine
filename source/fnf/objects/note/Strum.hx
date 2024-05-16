package fnf.objects.note;

import fnf.graphics.shaders.ColorSwap;

class Strum extends FlxSprite {
	public var extra:Map<String, Dynamic> = [];

	public var colorSwap:ColorSwap;
	public var noteData(get, set):Int;
	private function set_noteData(value:Int):Int return ID = value;
	private function get_noteData():Int return ID;
	public var lastHit:Float = Math.NEGATIVE_INFINITY;

	private var col(get, never):String;
	private function get_col():String return ['purple', 'blue', 'green', 'red'][ID];
	private var dir(get, never):String;
	private function get_dir():String return ['left', 'down', 'up', 'right'][ID];
	public function new(x:Float, y:Float, data:Int, pixel:Bool = false) {
		super(x, y);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		ID = data;

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
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		/* if (animation.finished) {
			switch (animation.name) {
				case 'press': playAnim('static', true);
				case 'confirm': playAnim('press', true);
			}
		} */
		// if cpu shit will be added later
		if (lastHit + (Conductor.crochet / 2) < Conductor.songPosition && animation.name == 'confirm') playAnim('static', true);
	}

	public function playAnim(name:String, force:Bool = false) {
		animation.play(name, force);
		centerOffsets();
		centerOrigin();
	}
}