package fnf.objects.note;

import fnf.graphics.shaders.ColorSwap;

class Note extends FlxSprite {
	public var extra:Map<String, Dynamic> = [];

	public var strumGroup(default, set):StrumGroup;
	private function set_strumGroup(strumGroup:StrumGroup) {
		if (strumGroup != null) {
			if (this.strumGroup.notes != null)
				this.strumGroup.notes.remove(this, true);
			strumGroup.notes.add(this);
			strumGroup.notes.sortSelf();
		}
		return this.strumGroup = strumGroup;
	}
	public var parentStrum(get, never):Strum;
	private function get_parentStrum():Strum return strumGroup.members[ID];

	// temporary
	public var downscrollMult(get, never):Float;
	private function get_downscrollMult():Float return SaveManager.getOption('gameplay.downscroll') ? -1 : 1;

	public var strumTime:Float = 0;

	public var canHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasHit:Bool = false;
	public var prevNote(get, default):Note; private function get_prevNote():Note return prevNote == null ? this : prevNote;
	public var scrollAngle:Float = 90;

	private var willMiss:Bool = false;
	public var hitCausesMiss:Bool = false; // psych be like

	public var altNote:Bool = false;
	public var invisNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var lowPriority:Bool = false;

	public var parent:Note;
	public var tail:Array<Note> = [];

	public var colorSwap:ColorSwap;
	public var noteScore:Float = 1;
	public var kind(default, set):String = 'Normal';
	private function set_kind(value:String) {
		switch (value) {
			default:
				// script call?
		}
		return kind = value;
	}

	public static var swagWidth:Float = 160 * 0.7;

	var __state(default, set):String = '';
	private function set___state(value:String):String {
		__state = value;
		animation.play(__state);
		return value;
	}
	public var noteState(get, never):String;
	private function get_noteState():String return __state.trim() == '' ? (isSustainNote ? 'hold' : 'note') : __state; // did some jic stuff

	public var noteData(get, set):Int;
	private function get_noteData():Int return ID;
	private function set_noteData(value:Int):Int return ID = value;

	private var col(get, never):String;
	private function get_col():String return ['purple', 'blue', 'green', 'red'][ID];
	private var dir(get, never):String;
	private function get_dir():String return ['left', 'down', 'up', 'right'][ID];
	public function new(time:Float, data:Int, ?prevNote:Note, ?isSustain:Bool = false) {
		super();

		strumTime = time;
		ID = data;
		this.prevNote = prevNote;
		isSustainNote = isSustain;

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

		if (!isSustain) __state = 'note';

		if (isSustain && prevNote != null) {
			noteScore * 0.2;
			alpha = 0.6;

			if (SaveManager.getOption('gameplay.downscroll')) angle = 180;

			__state = 'end';

			updateHitbox();

			if (prevNote.isSustainNote) {
				prevNote.__state = 'hold';
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
			}
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!parentStrum.cpu) {
			// miss on the NEXT frame so lag doesnt make u miss notes
			if (willMiss && !wasHit) {
				tooLate = true;
				canHit = false;
			} else {
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) {
					// The * 0.5 is so that it's easier to hit them too late, instead of too early
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canHit = true;
				} else {
					canHit = true;
					willMiss = true;
				}
			}
		} else canHit = false;

		if (tooLate) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	// thats it lol
	public var forceDraw:Bool = false;
	public var willDraw(get, never):Bool; private function get_willDraw():Bool return forceDraw || !wasHit || isSustainNote;
	override function draw()
		if (willDraw)
			super.draw();
}
