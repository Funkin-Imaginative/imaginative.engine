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
	function set_strumGroup(strumGroup:StrumGroup) {
		if (strumGroup != null) {
			if (this.strumGroup.notes != null)
				this.strumGroup.notes.remove(this, true);
			strumGroup.notes.add(this);
			strumGroup.notes.sortSelf();
		}
		return this.strumGroup = strumGroup;
	}
	public var parentStrum(get, never):Strum; inline function get_parentStrum():Strum return strumGroup.members[data];
	public var holdCover:HoldCover;
	inline public function getHoldCover(?func:HoldCover->Void):HoldCover {
		var cover:HoldCover = parent.holdCover;
		if (cover != null && func != null)
			func(cover);
		return cover;
	}

	public var strumTime:Float = 0;

	public var canHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasHit:Bool = false;
	public var wasMissed:Bool = false;

	public var prevNote(get, default):Note; function get_prevNote():Note return prevNote == null ? this : prevNote;
	public var nextNote(get, default):Note; function get_nextNote():Note return nextNote == null ? this : nextNote;

	public var scrollAngle(get, default):Null<Float>;
	function get_scrollAngle():Float return scrollAngle == null ? scrollAngle = (isSustain ? 0 : (SaveManager.getOption('downscroll') ? 90 : 270)) : scrollAngle;

	private var willMiss:Bool = false;
	public var hitCausesMiss:Bool = false; // psych be like
	public var forceMiss:Bool = false; // enemy specific
	public var forceHit:Bool = false; // player specific

	public var altNote:Bool = false;
	public var invisNote:Bool = false;

	public var shouldIgnore:Bool = false;
	public var preventHit:Bool = false;
	public var animSuffix:String = '';
	public var earlyHitMult:Float = 1;
	public var lateHitMult:Float = 1;

	public var parent:Note;
	public var lowPriority:Bool = false;

	public var tail:Array<Note> = [];
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
	public var ratingData:{name:String, mod:Float, prevent:Bool} = {
		name: null,
		mod: 0,
		prevent: false
	}
	public var preventAnims:{sing:Bool, miss:Bool} = {
		sing: false,
		miss: false
	}

	private var __applyScaleFrfr:Bool = false; // ofc this didn't fucking work
	private var baseScale:PositionMeta = new PositionMeta(0.7, 0.7);
	public function setBaseScale(func:Void->Void) {
		__applyScaleFrfr = false;
		if (func != null) func();
		updateHitbox();
		baseScale.set(scale.x, scale.y);
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
	inline function get_noteState():NoteState return __state;

	public var data:Int;
	public var safedata(get, set):Int; // mod safety precaction
	inline function get_safedata():Int return strumGroup == null ? data : data % strumGroup.length - 1;
	inline function set_safedata(value:Int):Int return data = value; // ¯\_(ツ)_/¯

	override public function new(time:Float, data:Int, prev:Note, state:NoteState) {
		super(-10000, -10000);

		strumTime = time;
		this.data = data;
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
			frames = Paths.getSparrowAtlas('gameplay/notes/NOTE_assets');
			var col:String = ['purple', 'blue', 'green', 'red'][data];

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

		// setBaseScale(() -> setGraphicSize(Std.int(width * (pixel ? PlayState.daPixelZoom : 0.7))));
		setGraphicSize(Std.int(width * (pixel ? PlayState.daPixelZoom : 0.7)));
		updateHitbox();
		if (noteState == HOLD) {
			scale.y *= Conductor.stepCrochet / 100 * 1.5 * __scrollSpeed;
			updateHitbox();
		}
		baseScale.set(scale.x, scale.y);
	}

	public var distance:{position:Float, time:Float} = {position: 0, time: 0}
	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (applyMods.alpha) alpha = parentStrum.alpha * mods.alpha;
		/* if (__applyScaleFrfr) {
			if (applyMods.scale && !isSustain) {
				var sy:Float = mods.scale.y;
				if (noteState == HOLD) {sy *= Conductor.stepCrochet / 100 * 1.5 * __scrollSpeed;} else {
					sy *= parentStrum.scaleMult.y;
					sy *= mods.scale.y;
				}
				scale.set(baseScale.x * mods.scale.x * parentStrum.scaleMult.x * mods.scale.x, baseScale.y * sy);
			} //else {if (noteState == HOLD) scale.y = baseScale.y * (Conductor.stepCrochet / 100 * 1.5 * __scrollSpeed);}
		} */

		var angleDir:Float = Math.PI / 180;
		if (isSustain) {
			var scrollAngle:Float = parent.scrollAngle + scrollAngle;
			angleDir = scrollAngle * angleDir;
			if (applyMods.angle) angle = scrollAngle - 90;
		} else {
			angleDir = scrollAngle * angleDir;
			if (applyMods.angle) angle = parentStrum.angle;
		}
		var pos:PositionMeta = new PositionMeta(parentStrum.x, parentStrum.y);
		distance.position = 0.45 * (distance.time = Conductor.songPosition - strumTime) * __scrollSpeed;

		// pos.x += offset.x;
		pos.x -= isSustain ? (width / 2) : 0;
		pos.x += isSustain ? (parentStrum.width / 2) : 0;
		pos.x += Math.cos(angleDir) * distance.position;

		// pos.y += offset.y;
		pos.y += isSustain ? (parentStrum.width / 2) : 0;
		pos.y += Math.sin(angleDir) * distance.position;
		setPosition(pos.x, pos.y);

		/* var strumCenter:Float = parentStrum.y + offset.y + (parentStrum.width / 2) + Math.sin(angleDir) * distance.position;
		if (isSustain && (wasHit || (prevNote.wasHit || !canHit))) {
			var swagRect:flixel.math.FlxRect = clipRect;
			if (swagRect == null) swagRect = new flixel.math.FlxRect(0, 0, frameWidth, frameHeight);
			if (y + offset.y * scale.y <= strumCenter) {
				swagRect.y = (strumCenter - y) / scale.y;
				swagRect.width = width / scale.x;
				swagRect.height = (height / scale.y) - swagRect.y;
			}
			clipRect = swagRect;
		} */

		if (!parentStrum.cpu) {
			// miss on the NEXT frame so lag doesnt make u miss notes
			if ((willMiss && !wasHit) || wasMissed) {
				tooLate = true;
				canHit = false;
			} else {
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * earlyHitMult)) {
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * lateHitMult))
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
	public var willDraw(get, never):Bool; inline function get_willDraw():Bool return forceDraw || !wasHit;// || isSustain;
	override public function draw()
		if (willDraw) // made var for if statement shit lol
			super.draw();

	override public function destroy() {
		for (note in tail) note.destroy();
		super.destroy();
	}
}