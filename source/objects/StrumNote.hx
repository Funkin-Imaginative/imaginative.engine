package objects;

import shaders.ColorizeRGB;
#if sys import sys.FileSystem #end

class StrumNote extends FlxSprite {
	private var rgbColoring:ColorizeRGB;
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public var direction:Float = 90; //plan on doing scroll directions soon -bb
	public var downScroll:Bool = false; //plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	private var glowAttachment:Bool = true;
	
	public var isPixel(default, set):Bool = false;
	public var pixelScale:Float = 6;
	function set_isPixel(value:Bool):Bool {
		if (isPixel != value) {
			isPixel = value;
			reloadStrum();
		}
		return value;
	}
	
	public var style(default, set):String = 'Normal';
	private function set_style(value:String):String {
		if (!Paths.fileExists('images/notes/$texture/$style', IMAGE)) style = 'Normal';
		if (style != 'Normal' || style != 'Colorable') style = 'Normal';
		if (style != value) {
			style = value;
			reloadStrum();
		}
		glowAttachment = (style == 'Colorable');
		return value;
	}
	
	public var texture(default, set):String = 'Default';
	private function set_texture(value:String):String {
		if (!Paths.fileExists('images/notes/$texture')) texture = 'Default';
		if (texture != value) {
			texture = value;
			reloadStrum();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, pixelStuff:Array<Dynamic>) {
		rgbColoring = new ColorizeRGB();
		shader = rgbColoring.shader;
		noteData = leData;
		this.noteData = leData;
		this.isPixel = pixelStuff[0];
		this.pixelScale = pixelStuff[1];
		super(x, y);

		var skin:String = 'Default';
		if (PlayState.chartData.arrowSkin != null && PlayState.chartData.arrowSkin.length > 1) skin = PlayState.chartData.arrowSkin;
		texture = skin; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadStrum() {
		var lastAnim:String = null;
		if (animation.curAnim != null) lastAnim = animation.curAnim.name;

		if (isPixel) {
			loadGraphic(Paths.image('notes/$texture/$style-pixel'));
			width /= 4;
			height /= 5;
			loadGraphic(Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * pixelScale));

			animation.add('left', [4]);
			animation.add('down', [5]);
			animation.add('up', [6]);
			animation.add('right', [7]);
			switch (noteData % 4) {
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
					animation.add('noglow', [0]);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
					animation.add('noglow', [1]);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
					animation.add('noglow', [2]);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
					animation.add('noglow', [3]);
			}
		} else {
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('left', 'arrowLEFT');
			animation.addByPrefix('down', 'arrowDOWN');
			animation.addByPrefix('up', 'arrowUP');
			animation.addByPrefix('right', 'arrowRIGHT');

			antialiasing = ClientPrefs.data.antialiasing;
			setGraphicSize(Std.int(width * 0.7));

			switch (noteData % 4) {
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
					animation.addByPrefix('noglow', 'left strum confirm', 24, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
					animation.addByPrefix('noglow', 'down strum confirm', 24, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
					animation.addByPrefix('noglow', 'up strum confirm', 24, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
					animation.addByPrefix('noglow', 'right strum confirm', 24, false);
			}
		}
		updateHitbox();
		if (lastAnim != null) playAnim(lastAnim, true);
	}

	public function postAddedToGroup() {
		playAnim('static');
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if (resetAnim > 0) {
			resetAnim -= elapsed;
			if (resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		if ((animation.curAnim.name == 'confirm' || animation.curAnim.name == 'noglow') && !isPixel) centerOrigin();
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?startFrame:Int = 0) {
		if (anim == 'noglow') return; else if (anim == 'confirm' && glowAttachment) anim == 'noglow';
		animation.play(anim, force, reversed, startFrame);
		centerOffsets();
		centerOrigin();
		if (animation.curAnim == null || animation.curAnim.name == 'static') {
			rgbColoring.red = 0;
			rgbColoring.green = 0;
			rgbColoring.blue = 0;
		} else {
			if (noteData > -1 && noteData < ClientPrefs.data.arrowRGB.length) {
				rgbColoring.red = ClientPrefs.data.arrowRGB[noteData][0] / 360;
				rgbColoring.green = ClientPrefs.data.arrowRGB[noteData][1] / 100;
				rgbColoring.blue = ClientPrefs.data.arrowRGB[noteData][2] / 100;
			}
			if ((animation.curAnim.name == 'confirm' || animation.curAnim.name == 'noglow') && !isPixel) centerOrigin();
		}
	}
}