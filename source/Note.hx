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

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	private static var willMiss:Bool = false;

	public var altNote:Bool = false;
	// public var invisNote:Bool = false;
	public var isPixel:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var colorSwap:ColorSwap;
	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	public static var nameArray:Array<String> = ['left', 'down', 'up', 'right'];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false) {
		super();

		if (prevNote == null) prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		this.strumTime = strumTime;
		this.noteData = noteData;

		if (isPixel) {
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

			animation.add('leftScroll', [4]);
			animation.add('downScroll', [5]);
			animation.add('upScroll', [6]);
			animation.add('rightScroll', [7]);

			if (isSustainNote) {
				loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

				animation.add('leftholdend', [4]);
				animation.add('upholdend', [6]);
				animation.add('rightholdend', [7]);
				animation.add('downholdend', [5]);

				animation.add('lefthold', [0]);
				animation.add('uphold', [2]);
				animation.add('righthold', [3]);
				animation.add('downhold', [1]);
			}

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();
			antialiasing = false;
		} else {
			frames = Paths.getSparrowAtlas('NOTE_assets');
			animation.addByPrefix('${nameArray[noteData]}Scroll', '${nameArray[noteData]} static');
			animation.addByPrefix('${nameArray[noteData]}holdend', '${nameArray[noteData]} hold end');
			animation.addByPrefix('${nameArray[noteData]}hold', '${nameArray[noteData]} hold piece');

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;
		}

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		// switch (noteData) {
		// 	case 0:
		// 		x += swagWidth * 0;
		// 		animation.play('leftScroll');
		// 	case 1:
		// 		x += swagWidth * 1;
		// 		animation.play('downScroll');
		// 	case 2:
		// 		x += swagWidth * 2;
		// 		animation.play('upScroll');
		// 	case 3:
		// 		x += swagWidth * 3;
		// 		animation.play('rightScroll');
		// }
		x += swagWidth * noteData;
		animation.play('${nameArray[noteData]}Scroll');

		// trace(prevNote);

		if (isSustainNote && prevNote != null) {
			noteScore * 0.2;
			alpha = 0.6;

			if (PreferencesMenu.getPref('downscroll'))
				angle = 180;

			x += width / 2;

			// switch (noteData) {
			// 	case 2:
			// 		animation.play('upholdend');
			// 	case 3:
			// 		animation.play('rightholdend');
			// 	case 1:
			// 		animation.play('downholdend');
			// 	case 0:
			// 		animation.play('leftholdend');
			// }
			animation.play('${nameArray[noteData]}holdend');

			updateHitbox();

			x -= width / 2;

			if (isPixel) x += 30;

			if (prevNote.isSustainNote) {
				// switch (prevNote.noteData) {
				// 	case 0:
				// 		prevNote.animation.play('lefthold');
				// 	case 1:
				// 		prevNote.animation.play('downhold');
				// 	case 2:
				// 		prevNote.animation.play('uphold');
				// 	case 3:
				// 		prevNote.animation.play('righthold');
				// }
				prevNote.animation.play('${nameArray[noteData]}hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
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
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
				} else {
					canBeHit = true;
					willMiss = true;
				}
			}
		} else {
			canBeHit = false;

			if (strumTime <= Conductor.songPosition) wasGoodHit = true;
		}

		if (tooLate) {
			if (alpha > 0.3) alpha = 0.3;
		}
	}
}
