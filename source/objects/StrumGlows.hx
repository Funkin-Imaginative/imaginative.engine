package objects;

import shaders.ColorizeRGB;
#if sys import sys.FileSystem; #end

class StrumGlows extends AttachedSprite {
	private var rgbColoring:ColorizeRGB;
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public var noteType(default, set):String = '';
	
	public var texture(default, set):String = 'Default';
	private function set_texture(value:String):String {
		if (!sys.FileSystem.exists('images/notes/$texture/Colorable')) texture = 'Default';
		if (texture != value) {
			texture = value;
			reloadGlow();
		}
		return value;
	}

	public function new(leData:Int) {
		rgbColoring = new ColorizeRGB();
		shader = rgbColoring.shader;
		noteData = leData;
		this.noteData = leData;
		super('notes/$texture/Colorable', null, 'shared', false);


		var skin:String = 'Default';
		if (PlayState.chartData.arrowSkin != null && PlayState.chartData.arrowSkin.length > 1) skin = PlayState.chartData.arrowSkin;
		texture = skin; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadGlow() {
		frames = Paths.getSparrowAtlas('notes/$texture/Colorable');
		antialiasing = ClientPrefs.data.antialiasing;
		setGraphicSize(Std.int(width * 0.7));

		var colArray:Array<String> = ['left', 'down', 'up', 'right'];
		animation.addByPrefix('glow', '${colArray[noteData % 4]} glow confirm', 24, false);
		updateHitbox();
		playAnim('glow', true);
	}

	public function postAddedToGroup() {
		playAnim('glow');
		copyVisible = false;
		visible = false;
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if (resetAnim > 0) {
			resetAnim -= elapsed;
			if (resetAnim <= 0) {
				copyVisible = false;
				visible = false;
				resetAnim = 0;
			}
		} else copyVisible = true;
		centerOrigin();
		super.update(elapsed);
	}

	private function set_noteType(value:String):String {
		if (noteData > -1 && noteData < 4) {
			rgbColoring.red = ClientPrefs.data.arrowRGB[noteData][0] / 255;
			rgbColoring.green = ClientPrefs.data.arrowRGB[noteData][1] / 255;
			rgbColoring.blue = ClientPrefs.data.arrowRGB[noteData][2] / 255;
		}

		if (noteData > -1 && noteType != value) {
			switch(value) { // Since this is just for glow checks these are kinda just blank.
				case 'Hurt Note':
				case 'Alt Animation':
				case 'No Animation':
				case 'Opponent Sing':
				case 'GF Sing':
			}
			noteType = value;
		}
		return value;
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?startFrame:Int = 0) {
		animation.play(anim, force, reversed, startFrame);
		centerOffsets();
		centerOrigin();
		if (noteData > -1 && noteData < 4) {
			rgbColoring.red = ClientPrefs.data.arrowRGB[noteData][0] / 255;
			rgbColoring.green = ClientPrefs.data.arrowRGB[noteData][1] / 255;
			rgbColoring.blue = ClientPrefs.data.arrowRGB[noteData][2] / 255;
		}
		centerOrigin();
	}
}