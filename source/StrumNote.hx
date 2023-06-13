package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxSprite {
	public var noteData:Int = 0;
	public var scrollAngle:Float = 90; // plan on doing scroll directions like psych :P
	
	public var texture(default, set):String = 'Default';
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			loadStrum();
		}
		return value;
	}

	/* Pixel */
	public var isPixel(default, set):Bool = false;
	public var pixelScale:Float = 6;
	private function set_isPixel(value:Bool):Bool {
		if (isPixel != value) {
			isPixel = value;
			loadStrum();
		}
		return value;
	}

	/* Note Grouping */
	public var noteFamily:Array<Note> = []; // returns notes of noteData as strum

	/* Cool Stuff */
	public var multScaleX:Float = 1;
	public var extraOffsets = {
		angle: 0.0,
		scrlAng: 0.0
	};

	/* Misc */
	public static var nameArray:Array<String> = ['left', 'down', 'up', 'right'];

	public function new(x:Float, y:Float, leData:Int) {
		noteData = leData;
		this.noteData = leData;
		super(x, y);
		loadStrum();
		scrollFactor.set();
	}

	public function loadStrum() {
		var lastAnim:String = null;
		if (animation.curAnim != null) lastAnim = animation.curAnim.name;

		if (isPixel) {
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'));
			width /= 4;
			height /= 5;
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, Math.floor(width), Math.floor(height));
			setGraphicSize(Std.int(width * pixelScale));

			animation.add('Note', [noteData + 4]);
			animation.add('static', [noteData]);
			animation.add('pressed', [noteData + 4, noteData + 8], 12, false);
			animation.add('confirm', [noteData + 12, noteData + 16], 24, false);
		} else {
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('Note', 'arrow${nameArray[noteData].toUpperCase()}');
			setGraphicSize(Std.int(width * 0.7));
			animation.addByPrefix('static', 'arrow${nameArray[noteData].toUpperCase()}');
			animation.addByPrefix('pressed', '${nameArray[noteData]} press', 24, false);
			animation.addByPrefix('confirm', '${nameArray[noteData]} confirm', 24, false);
		}
		antialiasing = !isPixel;
		updateHitbox();

		if(lastAnim != null) playAnim(lastAnim, true);
	}

	public function postAddedToGroup(player:Int) {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(animation.curAnim.name == 'confirm' && !isPixel) centerOrigin();
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?forced:Bool = false) {
		animation.play(anim, forced);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim.name == 'confirm' && !isPixel) centerOrigin();
	}
}
