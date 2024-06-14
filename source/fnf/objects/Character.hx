package fnf.objects;

import fnf.utils.ParseUtil.CharDataType;
import fnf.objects.FunkinSprite;
import flixel.math.FlxRect;
import flixel.util.FlxStringUtil;

typedef AnimSuffixes = { // will still work even if alt isn't found
	@:default('') var idle:String; // for idle/sway
	@:default('') var sing:String; // for sing anims (global version)
	@:default('') var anim:String; // for any anim
}

typedef CharData = {
	/**
	 * The sprite path.
	 */
	var sprite:String;

	/**
	 * Should the character face the other way?
	 */
	@:default(false) var flip:Bool;

	/**
	 * The animation(s) information.
	 */
	var anims:Array<AnimList>;

	/**
	 * Offset xy position.
	 */
	var position:PositionMeta;

	/**
	 * Camera xy position.
	 */
	var camera:PositionMeta;



	/**
	 * The scale multiplier.
	 */
	@:optional @:default(1) var scale:Float;

	/**
	 * Sing animation duration.
	 */
	@:optional @:default(4) var singLen:Float;

	/**
	 * The icon name.
	 */
	@:optional @:default('') var icon:String;

	/**
	 * Should use aliasing?
	 */
	@:optional @:default(true) var aliasing:Bool;

	/**
	 * Health Bar Color.
	 */
	@:optional @:default('') var color:String;

	/**
	 * Bops ber beat.
	 */
	@:optional @:default(0) var beat:Int;

	/**
	 * The engine the character file came from.
	 */
	@:optional @default(IMAG) var isFromEngine:CharDataType;
}

private typedef AnimHas = {
	var miss:Bool;
	var suffix:Bool;
}
private typedef AnimCheck = {
	var miss:String;
	var suffix:String;
}

class Character extends FunkinSprite implements IMusicBeat {
	// internal set to prevent setting
	@:unreflective var __name:String = 'boyfriend';
	@:unreflective var __variant:String = 'normal';
	// vars to actually use
	@:isVar public var charName(get, never):String; inline function get_charName():String return __name;
	@:isVar public var charVariant(get, never):String; inline function get_charVariant():String return __variant;
	public var hasVariant(get, never):Bool; inline function get_hasVariant():Bool return charVariant != 'none';

	// quick way to set which direction the character is facing
	@:isVar public var isFacing(get, set):SpriteFacing = rightFace;
	inline function get_isFacing():SpriteFacing return flipX ? rightFace : leftFace;
	inline function set_isFacing(value:SpriteFacing):SpriteFacing {
		flipX = value == leftFace;
		return isFacing = value;
	}

	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	public var stunned:Bool = false;

	public var bopSpeed(default, set):Int = 1; function set_bopSpeed(value:Int):Int return bopSpeed = bopSpeed < 1 ? 1 : value;
	public var beatInterval(get, default):Int = 0; function get_beatInterval():Int return beatInterval < 1 ? (hasSway ? 1 : 2) : beatInterval;
	public var singLength:Float = 4; // Multiplier of how long a character holds the sing pose.
	public var suffixes:AnimSuffixes = {idle: '', sing: '', anim: ''} // even tho @:default is used it didn't actually work lol
	public var preventIdle:Bool = false;
	public var hasSway(get, never):Bool; // Replaces 'danceLeft' with 'idle' and 'danceRight' with 'sway'.
	function get_hasSway():Bool return suffixes.idle.trim() == '' ? doesAnimExists('sway') : doesAnimExists('sway${suffixes.idle}');

	public var xyOffset(default, never):PositionMeta = new PositionMeta();
	public var camPoint(default, never):PositionMeta = new PositionMeta();
	public function getCamPos():PositionMeta {
		var basePos:FlxPoint = getMidpoint();
		var event:PointEvent = new PointEvent(
			basePos.x + (isFacing == rightFace && isFromEngine == PSYCH ? -100 : 150) + (xyOffset.x + camPoint.x) * (isFacing == rightFace ? 1 : -1),
			basePos.y - (isFromEngine == PSYCH ? 100 : 0) + xyOffset.y + camPoint.y
		);
		basePos.put();
		scripts.call('getCameraPos', [event]);
		return new PositionMeta(event.x, event.y);
	}

	public var icon(get, default):String = 'face';
	function get_icon():String return icon.trim() == '' ? spritePath : icon;

	public var animationNotes:Array<Dynamic> = [];

	public var spritePath(default, null):String;
	public var scaleMult(default, null):Float;
	public var aliasing(default, null):Bool;
	public var flipSprite(default, null):Bool;
	@:isVar public var iconColor(get, set):Null<FlxColor>;
	inline function get_iconColor():FlxColor return iconColor == null ? 0xffa1a1a1 : iconColor;
	inline function set_iconColor(value:FlxColor):FlxColor {value.alphaFloat = 1; return iconColor = value;}
	public var isFromEngine(default, null):CharDataType;

	public var charData:CharData;
	inline public static function applyCharData(content:Dynamic):CharData {
		return cast content == null ? FailsafeUtil.charYaml : {
			sprite: content.sprite,
			flip: content.flip,
			anims: content.anims,
			position: content.position,
			camera: content.camera,

			scale: content.scale,
			singLen: content.singLen,
			icon: content.icon,
			aliasing: content.aliasing,
			color: content.color,
			beat: content.beat,

			isFromEngine: content.isFromEngine
		}
	}

	public var scripts:ScriptGroup; // just for effecting both scripts at once lmao
	public var charScript:Script;
	public var variantScript:Script;

	public function new(x:Float, y:Float, faceLeft:Bool = false, character:String = 'making this whatever to force failsafe', variant:String = 'Peanut Butter & (Blue) Cheese') {
		super(x, y);

		__name = character;
		__variant = variant;
		isFacing = faceLeft ? leftFace : rightFace;

		scripts = new ScriptGroup(this);
		charScript = Script.create(charName, 'char');
		if (hasVariant) variantScript = Script.create('$charName/$charVariant', 'char');
		for (script in [charScript, variantScript]) {
			if (script == null) script = new Script(FailsafeUtil.invaildScriptKey);
			scripts.add(script);
		}
		scripts.load(true);
		scripts.call('create');

		switch (charName) {
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'bfPixelsDEAD'}');

				flipSprite = true;
				quickAnimAdd('firstDeath', 'BF Dies pixel');
				animation.addByPrefix('deathLoop', 'Retry Loop', 24, false, flipSprite);
				quickAnimAdd('deathConfirm', 'RETRY CONFIRM');
				// quickAnimAdd('singUP', 'BF Dies pixel');

				loadOffsetFile(charName);

				scaleMult = 6;
				aliasing = false;

			case 'bf-holding-gf-dead':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'bfHoldingGF-DEAD'}');

				flipSprite = true;
				quickAnimAdd('firstDeath', 'BF Dies with GF');
				animation.addByPrefix('deathLoop', 'BF Dead with GF Loop', 24, false, flipSprite);
				quickAnimAdd('deathConfirm', 'RETRY confirm holding gf');
				// quickAnimAdd('singUP', 'BF Dead with GF Loop');

				loadOffsetFile(charName);

				scaleMult = 1;
				aliasing = true;

			default:
				charData = ParseUtil.character(charName, charVariant); // get char data
				isFromEngine = charData.isFromEngine;

				frames = Paths.getAtlasFrames('characters/${spritePath = charData.sprite}');

				flipSprite = charData.flip;
				for (anim in charData.anims) {
					// multsparrow support soon
					var shouldFlip:Bool = flipSprite;
					if (anim.flip) shouldFlip = !shouldFlip;
					if (anim.indices != null && anim.indices.length > 0)
						animation.addByIndices(anim.name, anim.tag, anim.indices, '', anim.fps, anim.loop, shouldFlip);
					else animation.addByPrefix(anim.name, anim.tag, anim.fps, anim.loop, shouldFlip);
					setupAnim(anim.name, anim.offset.x, anim.offset.y, anim.flipAnim);
				}
				xyOffset.set(charData.position.x, charData.position.y);
				camPoint.set(charData.camera.x, charData.camera.y);

				scaleMult = charData.scale;
				singLength = charData.singLen;
				icon = charData.icon;
				aliasing = charData.aliasing;
				iconColor = FlxColor.fromString(charData.color);
				beatInterval = charData.beat;
		}

		antialiasing = aliasing;
		if (scaleMult != 1) {
			setGraphicSize(Std.int(width * scaleMult));
			updateHitbox();
		}

		dance();

		scripts.call('createPost');
	}

	public function loadMappedAnims() {
		final swagshit = Song.loadFromJson('Stress', 'picolol');

		final notes = swagshit.notes;
		for (section in notes)
			for (idk in section.sectionNotes)
				animationNotes.push(idk);

		fnf.objects.background.TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	inline function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);

	inline function quickAnimAdd(name:String, prefix:String)
		animation.addByPrefix(name, prefix, 24, false, flipSprite);

	private function loadOffsetFile(offsetCharacter:String) {
		for (i in CoolUtil.splitTextByLine(Paths.txt('images/characters/${offsetCharacter}Offsets'))) {
			final splitWords:Array<String> = i.split(' ');
			setupAnim(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]), splitWords[3]);
		}
	}

	// "-end" anim code by @HIGGAMEON
	private var animB4Loop:String = '';
	override public function update(elapsed:Float) {
		scripts.call('update', [elapsed]);
		if (!debugMode && animation.curAnim != null) {
			switch (charName) {
				case 'pico-speaker':
					if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0]) {
						var noteData:Int = 1;
						if (animationNotes[0][1] > 2) noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if (isAnimFinished()) playAnim(getAnimName(), false, false, animation.curAnim.frames.length - 3);
			}

			if (isAnimFinished() && doesAnimExists('${getAnimName()}-loop') && !getAnimName().endsWith('-loop')) {
				var event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('loop', false, NONE, false, 0));
				if (event.stopped) return;
				var prevAnimType:AnimType = animType;
				playAnim('${getAnimName()}-loop', event.force, event.animType, event.reverse, event.frame);
				if (prevAnimType == SING || prevAnimType == MISS) animType = prevAnimType; // for `tryDance()` checks
				scripts.call('playingSpecialAnimPost', [event]);
			}

			if (/* animType != VOID || */ animType != DANCE) tryDance();
		}
		super.update(elapsed);
		scripts.call('updatePost', [elapsed]);
	}

	public var onSway:Bool = false;
	public function dance() {
		var event:BopEvent = scripts.event('dancing', new BopEvent(!onSway));
		if (!debugMode || !event.stopped) {
			if (isAnimFinished() && doesAnimExists('$animB4Loop-end') && !getAnimName().endsWith('-end')) {
				var event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('end', false, NONE, false, 0));
				if (event.stopped) return;
				playAnim('$animB4Loop-end', event.force, event.animType, event.reverse, event.frame);
				scripts.call('playingSpecialAnimPost', [event]);
			} else if (!preventIdle) {
				onSway = event.sway;
				final anim:String = onSway ? (hasSway ? 'sway' : 'idle') : 'idle';
				final suffix:String = doesAnimExists('$anim${suffixes.idle}') ? suffixes.idle : '';
				playAnim('$anim$suffix', true, DANCE);
			}
		}
		scripts.call('dancingPost', [event]);
	}

	public function tryDance() {
		switch (animType) {
			case SING | MISS:
				if (lastHit + (Conductor.stepCrochet * singLength) < Conductor.songPosition)
					dance();
			case DANCE:
				dance();
			case LOCK:
				if (getAnimName() == null)
					dance();
			case VOID:
				dance();
			default:
				if (getAnimName() == null || isAnimFinished())
					dance();
		}
	}

	override public function stepHit(curStep:Int) {
		super.stepHit(curStep);
		scripts.call('stepHit', [curStep]);
	}

	public var preventIdleBopping:Bool = false;
	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		if (!preventIdleBopping && curBeat % Math.round(bopSpeed * beatInterval) == 0) tryDance();
		scripts.call('beatHit', [curBeat]);
	}

	override public function measureHit(curMeasure:Int) {
		super.measureHit(curMeasure);
		scripts.call('measureHit', [curMeasure]);
	}

	override public function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		final flipAnim:String = doesAnimExists(name) ? animInfo.get(name).flipAnim : '';
		var event:PlayAnimEvent = scripts.event('playingAnim', new PlayAnimEvent(isFacing == leftFace ? name : (doesAnimExists(flipAnim) ? flipAnim : name), force, animType, reverse, frame));
		if (event.stopped) return;
		final suffix:String = doesAnimExists('${event.anim}${suffixes.anim}') ? suffixes.anim : '';
		final anim:String = '${event.anim}$suffix';
		if (doesAnimExists(anim)) {
			if (!getAnimName().endsWith('-loop')) animB4Loop = anim;
			super.playAnim(anim, event.force, event.animType, event.reverse, event.frame);
			offset.set((offset.x - xyOffset.x) * (isFacing == rightFace ? -1 : 1), offset.y - xyOffset.y);
			if (animType == SING || animType == MISS) lastHit = Conductor.songPosition;
			scripts.call('playingAnimPost', [event]);
		}
	}

	public function singAnimCheck(sing:String, miss:String, suffix:String):Array<String> {
		var has:AnimHas = {
			miss: doesAnimExists('${sing}miss$suffix') || doesAnimExists('${sing}miss'),
			suffix: suffix.trim() == '' ? false : doesAnimExists('$sing$miss$suffix')
		}
		var cool:AnimCheck = {
			miss: has.miss ? miss : '',
			suffix: has.suffix ? suffix : ''
		}
		return [sing, cool.miss, cool.suffix];
	}

	public static final globalSingAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public var singAnims(get, default):Null<Array<Null<String>>>;
	function get_singAnims():Array<String> {
		var theAnims:Array<String> = singAnims == null ? globalSingAnims : singAnims;
		for (index => anim in theAnims) theAnims[index] = anim == null ? globalSingAnims[index] : anim;
		return theAnims;
	}
	public function playSingAnim(direction:Int, suffix:String = '', animType:AnimType = SING, force:Bool = true, reverse:Bool = false, frame:Int = 0) {
		var event:PlaySingAnimEvent = scripts.event('playingSingAnim', new PlaySingAnimEvent(direction, suffix, animType, force, reverse, frame));
		if (event.stopped) return;
		var checkedAnims:Array<String> = singAnimCheck(
			event.checkAnim(singAnims, event.direction),
			event.missed ? 'miss' : '',
			event.suffix.trim() == '' ? suffixes.sing : event.suffix
		);
		playAnim('${checkedAnims[0]}${checkedAnims[1]}${checkedAnims[2]}', event.force, event.animType, event.reverse, event.frame);
		scripts.call('playingSingAnimPost', [event]);
	}

	override public function destroy() {
		scripts.destroy();
		super.destroy();
	}

	override public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('Name', charName),
			LabelValuePair.weak('Variant', charVariant),
			LabelValuePair.weak('Facing', isFacing),
			LabelValuePair.weak('Beat Invertal', beatInterval),
			LabelValuePair.weak('Can Sway', hasSway)
		]);
	}

	// make offset flipping look not broken, and yes cne also does this
	var __offsetFlip:Bool = false;

	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__offsetFlip) {
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
	}

	override public function draw() {
		if (isFacing == rightFace) {
			__offsetFlip = true;

			flipX = !flipX;
			scale.x *= -1;
			super.draw();
			flipX = !flipX;
			scale.x *= -1;

			__offsetFlip = false;
		} else super.draw();
	}
}
