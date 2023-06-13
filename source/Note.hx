package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import shaderslmfao.ColorSwap;
import ui.PreferencesMenu;

using StringTools;

#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

class Note extends FlxSprite {
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false;

	private static var willMiss:Bool = false;

	public var animSuffix:String = '';
	// public var invisNote:Bool = false;
	public var isPixel(default, set):Bool = false;
	public var pixelScale:Float = 6;
	function set_isPixel(value:Bool):Bool {
		if (isPixel != value) {
			isPixel = value;
			// reloadNote();
		}
		return value;
	}

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var animToPlay(default, set):String = '';
	public var animMissed(default, set):String = '';
	public var noteType(default, set):String = '';

	public var extraOffsets = {
		x: 0.0,
		y: 0.0,
		angle: 0.0
	};
	public var multAlpha:Float = 1;
	// public var multSpeed(default, set):Float = 1;
	
	public var copyFromStrum = {
		x: true,
		y: true,
		angle: true,
		alpha: true
	};

	public var hitHealth:Float = 0.02;
	public var missHealth:Float = 0.04;

	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; // plan on doing scroll directions like psych :P
	public var scrollAngle:Int = 90

	public var colorSwap:ColorSwap;
	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var nameArray:Array<String> = ['left', 'down', 'up', 'right'];

	public function new(strumTime:Float, noteData:Int, /*pixelStuff:Array<String>,*/ ?prevNote:Note, ?sustainNote:Bool = false) {
		super();
		
		if (prevNote == null) prevNote = this;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		
		/*isPixel = pixelStuff[0];
		pixelScale = pixelStuff[1];*/
		
		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		this.strumTime = strumTime;
		this.noteData = noteData;

		if (isPixel) {
			if (isSustainNote) {
				loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);
				animation.add('${nameArray[noteData]}holdend', [noteData + 4]);
				animation.add('${nameArray[noteData]}hold', [noteData]);
			} else {
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
				animation.add('${nameArray[noteData]}Scroll', [noteData + 4]);
			}
			setGraphicSize(Std.int(width * pixelScale));
			updateHitbox();
			antialiasing = false;
		} else {
			frames = Paths.getSparrowAtlas('NOTE_assets');
			if (isSustainNote) {
				animation.addByPrefix('${nameArray[noteData]}holdend', '${nameArray[noteData]} hold end');
				animation.addByPrefix('${nameArray[noteData]}hold', '${nameArray[noteData]} hold piece');
			} else animation.addByPrefix('${nameArray[noteData]}Scroll', '${nameArray[noteData]} static');
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;
		}

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		x += swagWidth * noteData;
		animation.play('${nameArray[noteData]}Scroll');

		// trace(prevNote);

		if (prevNote != null) prevNote.nextNote = this;
		if (isSustainNote && prevNote != null) {
			noteScore * 0.2;
			alpha = 0.6;

			if (PreferencesMenu.getPref('downscroll')) angle = 180;
			x += width / 2;

			animation.play('${nameArray[noteData]}holdend');
			updateHitbox();

			x -= width / 2;
			if (isPixel) x += 30;

			if (prevNote.isSustainNote) {
				prevNote.animation.play('${nameArray[noteData]}hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	private function set_animToPlay(value:String):String {
		// var singAnims:Array<String> = [mustPress ? 'singTO' : 'singAWAY', 'singDOWN', 'singUP', mustPress ? 'singAWAY' : 'singTO'];
		var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
		if (value.length < 1) value = singAnims[noteData];
		animToPlay = value;
		return value;
	}

	private function set_animMissed(value:String):String {
		if (value.length < 1) value = animToPlay + 'miss';
		animMissed = value;
		return value;
	}

	public function noAnimChecker(?isMissAnim:Bool = false) {
		return if (isMissAnim) animMissed.length < 1; else animToPlay.length < 1;
	}

	private function set_noteType(value:String):String {
		if (noteData > -1 && noteType != value) {
			switch(value) {
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					animToPlay = '';
					animMissed = '';
				case 'Opponent Sing':
					// oppoNote = true;
				case 'GF Sing':
					// gfNote = true;
			}
			noteType = value;
		}
		return value;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (mustPress) {
			// miss on the NEXT frame so lag doesnt make u miss notes
			if (willMiss && !wasGoodHit) {
				tooLate = true;
				canBeHit = false;
			} else {
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) { // The * 0.5 is so that it's easier to hit them too late, instead of too early
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5)) canBeHit = true;
				} else {
					canBeHit = true;
					willMiss = true;
				}
			}
		} else {
			canBeHit = false;
			if (strumTime <= Conductor.songPosition) wasGoodHit = true;
		}
		if (tooLate) if (alpha > 0.3) alpha = 0.3;
	}
}