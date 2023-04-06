package objects;

import states.editors.ChartingState;

import shaders.ColorSwap;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite {
	public var extraData:Map<String,Dynamic> = [];

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

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var animToPlay(default, set):String = 'loadDefaults';
	public var animMissed(default, set):String = 'loadDefaults';
	public var noteType(default, set):String = '';

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var isPixel:Bool = false;
	public var pixelScale:Float = 6;

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;
	
	public var animSuffix:String = '';
	public var oppoNote:Bool = false;
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	
	private var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	private var pixelInt:Array<Int> = [0, 1, 2, 3];
	
	public var splashDisabled:Bool = false;
	public var splashTexture:String = 'noteSplashes';
	public var splashRed:Float = 0;
	public var splashGreen:Float = 0;
	public var splashBlue:Float = 0;
	
	public var extraOffsets = {
		x: 0.0,
		y: 0.0,
		angle: 0.0
		// scale: 1.0 // ??
	};
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;
	
	public var copyFromStrum = {
		x: true,
		y: true,
		angle: true,
		alpha: true
	};
	
	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;
	
	public var texture(default, set):String = 'NOTE_assets';
	
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb
	
	public var hitsoundDisabled:Bool = false;
	
	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		return value;
	}

	public function resizeByRatio(ratio:Float) { //haha funny twitter shit
		if (isSustainNote && !animation.curAnim.name.endsWith('end')) {
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value:String):String {
		if (!Paths.fileExists('images/' + texture, IMAGE)) texture = 'NOTE_assets';
		if (texture != value) reloadNote('', value);
		texture = value;
		return value;
	}

	private function set_animToPlay(value:String):String {
		var singAnims:Array<String> = [this.mustPress ? 'singTO' : 'singAWAY', 'singDOWN', 'singUP', this.mustPress ? 'singAWAY' : 'singTO'];
		if (value == 'loadDefaults' || value = null)
			value = singAnims[this.noteData];
		return value;
	}

	private function set_animMissed(value:String):String {
		var singAnims:Array<String> = [this.mustPress ? 'singTO' : 'singAWAY', 'singDOWN', 'singUP', this.mustPress ? 'singAWAY' : 'singTO'];
		if (value == 'loadDefaults' || value == null)
			value = singAnims[this.noteData] + 'miss';
		return value;
	}

	private function set_noteType(value:String):String {
		splashTexture = PlayState.chartData.splashSkin;
		if (noteData > -1 && noteData < ClientPrefs.data.arrowRGB.length) {
			colorSwap.red = ClientPrefs.data.arrowRGB[noteData][0] / 360;
			colorSwap.green = ClientPrefs.data.arrowRGB[noteData][1] / 100;
			colorSwap.blue = ClientPrefs.data.arrowRGB[noteData][2] / 100;
		}

		if (noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT', 'NOTE_assets');
					splashTexture = 'HURTnoteSplashes';
					colorSwap.red = 0;
					colorSwap.green = 0;
					colorSwap.blue = 0;
					lowPriority = true;
					missHealth = isSustainNote ? 0.1 : 0.3;
					hitCausesMiss = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					animToPlay = '';
					animMissed = '';
				case 'Opponent Sing':
					oppoNote = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		splashRed = colorSwap.red;
		splashGreen = colorSwap.green;
		splashBlue = colorSwap.blue;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, pixelStuff:Array<Dynamic>, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false) {
		super();

		if (prevNote == null) prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.isPixel = pixelStuff[0];
		this.pixelScale = pixelStuff[1];
		this.inEditor = inEditor;
		this.moves = false;
		
		this.strumTime = strumTime;
		if (!inEditor) this.strumTime += ClientPrefs.data.noteOffset;

		this.noteData = noteData;

		if (noteData > -1) {
			// texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
			x += swagWidth * (noteData);
			if (!isSustainNote && noteData > -1 && noteData < 4) { //Doing this 'if' check to fix the warnings on Senpai songs
				var anim:String = '';
				anim = colArray[noteData % 4];
				animation.play(anim + 'Scroll');
			}
		}

		if (prevNote != null) prevNote.nextNote = this;
		if (isSustainNote && prevNote != null) {
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if (ClientPrefs.data.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			animation.play(colArray[noteData % 4] + 'holdend');

			updateHitbox();

			offsetX -= width / 2;

			if (isPixel) offsetX += 30;

			if (prevNote.isSustainNote) {
				prevNote.animation.play(colArray[prevNote.noteData % 4] + 'hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if (PlayState.instance != null) prevNote.scale.y *= PlayState.instance.songSpeed;

				if (isPixel) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
			}
			
			if (isPixel) {
				scale.y *= pixelScale;
				updateHitbox();
			}
		} else if (!isSustainNote) earlyHitMult = 1;
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if (prefix == null) prefix = '';
		if (texture == null) texture = '';
		if (suffix == null) suffix = '';

		var skin:String = texture;
		if (texture.length < 1) {
			skin = PlayState.chartData.arrowSkin;
			if (skin == null || skin.length < 1) skin = 'NOTE_assets';
		}

		var animName:String = null;
		if (animation.curAnim != null) animName = animation.curAnim.name;

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		if (isPixel) {
			if (isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int(width * pixelScale));
			loadPixelNoteAnims();
			antialiasing = false;

			if (isSustainNote) {
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (pixelScale / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
			}
		} else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			antialiasing = ClientPrefs.data.antialiasing;
		}
		
		if (isSustainNote) scale.y = lastScaleY;
		updateHitbox();
		
		if (animName != null) animation.play(animName, true);
		
		if (inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims() {
		animation.addByPrefix(colArray[noteData] + 'Scroll', colArray[noteData] + '0');
		if (isSustainNote) {
			animation.addByPrefix('purpleholdend', 'pruple end hold'); // ?????
			animation.addByPrefix(colArray[noteData] + 'holdend', colArray[noteData] + ' hold end');
			animation.addByPrefix(colArray[noteData] + 'hold', colArray[noteData] + ' hold piece');
		}
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if (isSustainNote) {
			animation.add(colArray[noteData] + 'holdend', [pixelInt[noteData] + 4]);
			animation.add(colArray[noteData] + 'hold', [pixelInt[noteData]]);
		} else {
			animation.add(colArray[noteData] + 'Scroll', [pixelInt[noteData] + 4]);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (mustPress) {
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult) && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true; else canBeHit = false;
			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		} else {
			canBeHit = false;
			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult)) {
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}
		if (tooLate && !inEditor) {
			if (alpha > 0.3) alpha = 0.3;
		}
	}
}