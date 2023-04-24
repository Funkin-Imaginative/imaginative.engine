package objects;

import shaders.ColorizeRGB;

class NoteSplash extends FlxSprite {
	public var rgbColoring:ColorizeRGB = null;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'noteSplashes';
		if (PlayState.chartData.splashSkin != null && PlayState.chartData.splashSkin.length > 0) skin = PlayState.chartData.splashSkin;

		loadAnims(skin);
		
		rgbColoring = new ColorizeRGB();
		shader = rgbColoring.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, redColor:Float = 0, greenColor:Float = 0, blueColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if (texture == null) {
			texture = 'noteSplashes';
			if (PlayState.chartData.splashSkin != null && PlayState.chartData.splashSkin.length > 0) texture = PlayState.chartData.splashSkin;
		}

		if (textureLoaded != texture) loadAnims(texture);
		rgbColoring.red = redColor;
		rgbColoring.green = greenColor;
		rgbColoring.blue = blueColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if (animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3) {
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	override function update(elapsed:Float) {
		if (animation.curAnim != null) if (animation.curAnim.finished) kill();
		super.update(elapsed);
	}
}