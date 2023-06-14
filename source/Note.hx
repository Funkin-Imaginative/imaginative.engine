package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.PreferencesMenu;
// import sys.io.File;
// import sys.FileSystem;

using StringTools;

#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

class Note extends FlxSprite {
	/* Important Stuff */
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var isSustainNote:Bool = false;
	public var sustainLength:Float = 0;
	public var hitHealth:Float = 0.02;
	public var missHealth:Float = 0.04;
	public var scrollAngle:Float = 90;
	public var noteType(default, set):String = '';
	public var attachedChar(default, set):Character;
	private function set_attachedChar(value:Character):Character {
		if (attachedChar != value) {
			if (value == null) value = mustPress ? PlayState.boyfriend : PlayState.dad;
			attachedChar = value;
		}
		return value;
	}

	/* Hit Detection */
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	
	/* Note Grouping */
	public var prevNote:Note;
	public var nextNote:Note;
	public var parent:Note;
	public var tail:Array<Note> = []; // for sustains

	/* Extras */
	public var blockHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distanceFromStrum:Float = 2000; // plan on doing scroll directions like psych :P
	public var spawned:Bool = false;

	/* Animation */
	public var animToPlay(default, set):String = 'loadDefaults';
	public var animMissed(default, set):String = 'loadDefaults';
	public var animSuffix:String = '';
	public var texture(default, set):String = 'Default';
	private function set_texture(value:String):String {
		if (texture != value) {
			texture = value;
			loadNotePart('asset');
		}
		return value;
	}

	/* Pixel */
	public var isPixel(default, set):Bool = false;
	public var pixelScale:Float = 6;
	private function set_isPixel(value:Bool):Bool {
		if (isPixel != value) {
			isPixel = value;
			loadNotePart('asset');
		}
		return value;
	}

	/* Cool Stuff */
	public var extraOffsets = {
		x: 0.0,
		y: 0.0,
		angle: 0.0,
		scrlAng: 0.0
	};
	public var multipliers = {
		alpha: 1.0,
		scrlSpeed: 1.0,
		//score: 1.0,
		scaleX: 1.0 // no Y on purpose
	};
	public var copyFromStrum = {
		x: true,
		y: true,
		angle: true,
		alpha: true
	};

	/* Misc */
	public static var swagWidth:Float = 160 * 0.7;
	public static var nameArray:Array<String> = ['left', 'down', 'up', 'right'];

	public function new(strumTime:Float, noteData:Int, pixelStuff:Array<Dynamic>, ?prevNote:Note, ?sustainNote:Bool = false) {
		super();

		attachedChar = mustPress ? PlayState.boyfriend : PlayState.dad;
		
		if (prevNote == null) prevNote = this;
		this.prevNote = prevNote;

		isSustainNote = sustainNote;
		isPixel = pixelStuff[0];
		pixelScale = pixelStuff[1];
		
		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		this.strumTime = strumTime;
		this.noteData = noteData;

		loadNotePart('asset');

		x += swagWidth * noteData;
		if (!isSustainNote) animation.play('Note');

		// trace(prevNote);

		if (prevNote != null) prevNote.nextNote = this;
		if (isSustainNote && prevNote != null) {
			// multScore * 0.2;

			if (PreferencesMenu.getPref('downscroll')) angle = 180;//scrollAngle = -90;
			x += width / 2;

			loadNotePart('scale');
		}
	}

	public function loadNotePart(part:String) { // Can also reload.
		if (part == 'asset') {
			if (isPixel) {
				if (isSustainNote) {
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'));
					width /= 4;
					height /= 2;
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, Math.floor(width), Math.floor(height));
					animation.add('Hold End', [noteData + 4]);
					animation.add('Hold Piece', [noteData]);
				} else {
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'));
					width /= 4;
					height /= 5;
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, Math.floor(width), Math.floor(height));
					animation.add('Note', [noteData + 4]);
				}
			} else {
				frames = Paths.getSparrowAtlas('NOTE_assets');
				if (isSustainNote) {
					animation.addByPrefix('Hold End', '${nameArray[noteData]} hold end');
					animation.addByPrefix('Hold Piece', '${nameArray[noteData]} hold piece');
				} else animation.addByPrefix('Note', '${nameArray[noteData]} static');
			}
			setGraphicSize(Std.int(width * (isPixel ? pixelScale : 0.7) * multipliers.scaleX));
			updateHitbox();
			antialiasing = !isPixel;
		} else if (part == 'scale') {
			x += swagWidth * noteData;
			if (!isSustainNote) animation.play('Note');
			if (isSustainNote && prevNote != null) {
				animation.play('Hold End');
				updateHitbox();

				x -= width / 2;
				if (isPixel) x += 30;

				if (prevNote.isSustainNote) {
					prevNote.animation.play('Hold Piece');
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.chartData.speed * multipliers.scrlSpeed;
					prevNote.updateHitbox();
					// prevNote.setGraphicSize();
				}
			}
		}
	}

	private function set_animToPlay(value:String):String {
		// var singAnims:Array<String> = [attachedChar.isPlayer ? 'singTO' : 'singAWAY', 'singDOWN', 'singUP', attachedChar.isPlayer ? 'singAWAY' : 'singTO'];
		var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
		if (value.length < 1 || value == 'loadDefaults') value = singAnims[noteData];
		animToPlay = value;
		return value;
	}

	private function set_animMissed(value:String):String {
		if (value.length < 1 || value == 'loadDefaults') value = animToPlay + 'miss';
		animMissed = value;
		return value;
	}

	public function noAnimChecker(?isMissAnim:Bool = false):Bool {
		return if (isMissAnim) animMissed.length < 1; else animToPlay.length < 1;
	}
	
	public function checkAnimExists(?isMissAnim:Bool = false):Array<Dynamic> {
		var anim:String = isMissAnim ? animMissed : animToPlay;
		if (attachedChar.animOffsets.exists(anim + animSuffix)) return [true, anim + animSuffix];
		else { if (attachedChar.animOffsets.exists(anim))return [true, anim]; }
		return [false, ''];
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
					attachedChar = mustPress ? PlayState.dad : PlayState.boyfriend;
				case 'GF Sing':
					attachedChar = PlayState.gf;
			}
			noteType = value;
		}
		return value;
	}

	private static var willMiss:Bool = false;
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