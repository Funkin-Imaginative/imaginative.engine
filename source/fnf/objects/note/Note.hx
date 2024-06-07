package fnf.objects.note;

import fnf.graphics.shaders.ColorSwap;

enum abstract NoteState(String) from String to String {
	var NOTE = 'note';
	var HOLD = 'hold';
	var END = 'end';
}

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
	public var parentStrum(get, never):Strum; inline function get_parentStrum():Strum return strumGroup.members[ID];

	public var strumTime:Float = 0;

	public var canHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasHit:Bool = false;
	public var wasMissed:Bool = false;

	public var prevNote(get, default):Note; function get_prevNote():Note return prevNote == null ? this : prevNote;
	public var nextNote(get, default):Note; function get_nextNote():Note return nextNote == null ? this : nextNote;

	public var scrollAngle(get, default):Null<Float>;
	function get_scrollAngle():Float return scrollAngle == null ? scrollAngle = (isSustain ? 0 : (SaveManager.getOption('gameplay.downscroll') ? 90 : 0)) : scrollAngle;

	private var willMiss:Bool = false;
	public var hitCausesMiss:Bool = false; // psych be like
	public var forceMiss:Bool = false; // opponent specific

	public var altNote:Bool = false;
	public var invisNote:Bool = false;

	public var parent:Note;
	public var lowPriority:Bool = false;

	public var tail:Array<Note> = [];
	public var hasTail(get, never):Bool; inline function get_hasTail():Bool return tail.length > 0;
	public var isSustain(get, never):Bool; inline function get_isSustain():Bool return noteState != NOTE;
	public var sustainLength:Float = 0;

	// public var colorSwap:ColorSwap;
	public var noteScore:Float = 1;
	public var kind(default, set):String = 'Normal';
	function set_kind(value:String) {
		switch (value) {
			default:
				// script call?
		}
		return kind = value;
	}

	public static var swagWidth:Float = 160 * 0.7;

	public var healthAmount:{gain:Float, drain:Float} = {
		gain: 0.03,
		drain: 0.05
	};

	var __applyScaleFrfr:Bool = false; // ofc this didn't fucking work
	var baseScale:PositionMeta = new PositionMeta(0.7, 0.7);
	public function setBaseScale(func:Void->Void) {
		__applyScaleFrfr = false;
		if (func != null) func();
		baseScale.set(scale.x, scale.y);
		updateHitbox();
		__applyScaleFrfr = true;
	}
	public var __scrollSpeed(get, never):Float; inline function get___scrollSpeed():Float return PlayState.SONG.speed * mods.speed;

	public var mods:{alpha:Float, scale:PositionMeta, speed:Float} = {
		alpha: 1,
		scale: new PositionMeta(1, 1),
		speed: 1
	}
	public var applyMods:{alpha:Bool, scale:Bool, angle:Bool} = {
		alpha: true,
		scale: false,
		angle: true,
	}

	@:unreflective var __state(default, set):NoteState;
	function set___state(value:NoteState):NoteState {
		if (__state != value) {
			if (value == NOTE) {
				centerOffsets();
				centerOrigin();
			}
			return __state = value;
		}
		return __state;
	}
	public var noteState(get, never):NoteState;
	function get_noteState():NoteState return __state;

	public var noteData(get, set):Int;
	inline function get_noteData():Int return ID;
	inline function set_noteData(value:Int):Int return ID = value;

	var col(get, never):String; function get_col():String return ['purple', 'blue', 'green', 'red'][ID];
	var dir(get, never):String; function get_dir():String return ['left', 'down', 'up', 'right'][ID];
	public function new(time:Float, data:Int, prev:Note, state:NoteState) {
		super(-10000, -10000);

		strumTime = time;
		ID = data;
		prevNote = prev; prevNote.nextNote = this;
		__state = state;

		var pixel:Bool = PlayState.curStage == 'school' || PlayState.curStage == 'schoolEvil';
		if (pixel) {
			switch (noteState) { // this is wierd
				case NOTE:
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					animation.add('lol', [data + 4], 24);
				default:
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);
					switch (noteState) {
						case HOLD: animation.add('lol', [data], 24);
						case END: animation.add('lol', [data + 4], 24);
						default:
					}
			}
		} else {
			frames = Paths.getSparrowAtlas('notes/NOTE_assets');

			switch (noteState) {
				case NOTE: animation.addByPrefix('lol', '${col}0', 24);
				case HOLD: animation.addByPrefix('lol', '$col hold piece', 24);
				case END: animation.addByPrefix('lol', '$col hold end', 24);
			}
		}
		antialiasing = !pixel;
		animation.play('lol');

		// colorSwap = new ColorSwap();
		// shader = colorSwap.shader;

		setBaseScale(function() {
			setGraphicSize(Std.int(width * (pixel ? PlayState.daPixelZoom : 0.7)));
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (applyMods.alpha) alpha = parentStrum.alpha * mods.alpha;
		if (__applyScaleFrfr) {
			if (applyMods.scale) {
				var sy:Float = mods.scale.y;
				if (isSustain) sy *= Conductor.stepCrochet / 100 * 1.5 * __scrollSpeed; else {
					sy *= parentStrum.scaleMult.y;
					sy *= mods.scale.y;
				}
				scale.set(baseScale.x * mods.scale.x * parentStrum.scaleMult.x * mods.scale.x, baseScale.y * sy);
			} else {if (isSustain) scale.y = baseScale.y * (Conductor.stepCrochet / 100 * 1.5 * __scrollSpeed);}
		}

		if (!parentStrum.cpu) {
			// miss on the NEXT frame so lag doesnt make u miss notes
			if (willMiss && !wasHit) {
				tooLate = true;
				canHit = false;
			} else {
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) {
					if (strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
						canHit = true;
				} else {
					canHit = true;
					willMiss = true;
				}
			}
		} else canHit = false;

		if (tooLate)
			if (alpha > 0.3)
				alpha = 0.3;
	}

	// thats it lol
	public var forceDraw:Bool = false;
	public var willDraw(get, never):Bool; function get_willDraw():Bool return forceDraw || !wasHit || isSustain;
	override function draw()
		if (willDraw) // made var for if statement shit lol
			super.draw();
}