package fnf.objects.note;

import fnf.graphics.shaders.ColorSwap;

class Note extends FlxSprite {
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	private var willMiss:Bool = false;

	public var altNote:Bool = false;
	public var invisNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var colorSwap:ColorSwap;
	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	private var col(get, never):String;
	private function get_col():String return ['purple', 'blue', 'green', 'red'][noteData];
	private var dir(get, never):String;
	private function get_dir():String return ['left', 'down', 'up', 'right'][noteData];

	var __state:String = '';
	public var noteState(get, never):String;
	private function get_noteState():String return __state == '' ? (isSustainNote ? 'hold' : 'note') : __state; // did some jic stuff
	public function refreshAnim() animation.play(noteState);

	public function new(time:Float, data:Int, ?prev:Note, ?isSustain:Bool = false) {
		super();

		if (prev == null) prev = this;

		prevNote = prev;
		isSustainNote = isSustain;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		strumTime = time;

		noteData = data;

		switch (PlayState.curStage) {
			case 'school' | 'schoolEvil':

				if (isSustain) {
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);
					animation.add('end', [data + 4], 24);
					animation.add('hold', [data], 24);
				} else {
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					animation.add('note', [data + 4], 24);
				}

				antialiasing = false;
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				if (isSustain) {
					animation.addByPrefix('end', '$col hold end', 24);
					animation.addByPrefix('hold', '$col hold piece', 24);
				} else animation.addByPrefix('note', '${col}0', 24);

				antialiasing = true;
				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
		}

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		x += swagWidth * data;
		if (!isSustain) {
			animation.play('note');
			__state = 'note';
		}

		if (isSustain && prev != null) {
			noteScore * 0.2;
			alpha = 0.6;

			if (SaveManager.getOption('gameplay.downscroll')) angle = 180;

			x += width / 2;

			animation.play('end');
			__state = 'end';

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school')) x += 30;

			if (prev.isSustainNote) {
				prev.animation.play('hold');
				prev.__state = 'hold';
				prev.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prev.updateHitbox();
			}
		}

		if (prev != null) prev.refreshAnim();
		refreshAnim();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (mustPress) {
			// miss on the NEXT frame so lag doesnt make u miss notes
			if (willMiss && !wasGoodHit) {
				tooLate = true;
				canBeHit = false;
			} else {
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) {
					// The * 0.5 is so that it's easier to hit them too late, instead of too early
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
				} else {
					canBeHit = true;
					willMiss = true;
				}
			}
		} else {
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
