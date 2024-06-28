package fnf.objects;

import fnf.backend.interfaces.IPlayAnim;
import fnf.utils.ParseUtil.CharDataType;
import fnf.objects.FunkinSprite;
import flixel.util.FlxStringUtil;
import flixel.math.FlxRect;

typedef AnimSuffixes = { // will still work even if alt isn't found
	@:default('') var idle:String; // for idle/sway
	@:default('') var sing:String; // for sing anims (global version)
	@:default('') var anim:String; // for any anim
}

typedef CharData = {
	/**
	 * The display name.
	 */
	@:optional @:default('') var name:String;

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

class Character extends FunkinSprite implements INoteTriggers {
	public var charName(default, null):String;
	public var charVariant(default, null):String;
	public var hasVariant(get, never):Bool; inline function get_hasVariant():Bool return charVariant != 'none';

	public var quickDisplay(get, null):String; inline function get_quickDisplay():String return '$charName${hasVariant ? ' $charVariant' : ''}';
	public var displayName(get, null):String; inline function get_displayName():String return charData.name.trim() == '' ? '$charName${hasVariant ? ' ($charVariant)' : ''}' : displayName;

	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	public var stunned:Bool = false;

	public var bopSpeed(default, set):Int = 1; inline function set_bopSpeed(value:Int):Int return bopSpeed = bopSpeed < 1 ? 1 : value;
	public var beatInterval(get, default):Int = 0; inline function get_beatInterval():Int return beatInterval < 1 ? (hasSway ? 1 : 2) : beatInterval;
	public var singLength:Float = 4; // Multiplier of how long a character holds the sing pose.
	public var suffixes:AnimSuffixes = {idle: '', sing: '', anim: ''} // even tho @:default is used it didn't actually work lol
	public var preventIdle:Bool = false;
	public var hasSway(get, never):Bool; // Replaces 'danceLeft' with 'idle' and 'danceRight' with 'sway'.
	inline function get_hasSway():Bool return doesAnimExist('sway${suffixes.idle}') ? true : doesAnimExist('sway');

	public var xyOffset(default, never):PositionMeta = new PositionMeta();
	public var camPoint(default, never):PositionMeta = new PositionMeta();
	public function getCamPos():PositionMeta {
		var basePos:FlxPoint = getMidpoint();
		final isImag:Bool = isFromEngine == IMAG;
		var event:PointEvent = new PointEvent(
			basePos.x + (isImag ? 0 : (isFacing == leftFace ? -100 : 150)) + (xyOffset.x + camPoint.x) * (isImag ? (isFacing == rightFace ? 1 : -1) : 1),
			basePos.y - (isImag ? 0 : 100) + xyOffset.y + camPoint.y
		);
		basePos.put();
		script.call('getCameraPos', [event]);
		return new PositionMeta(event.x, event.y);
	}

	public var icon(get, null):String = 'face';
	inline function get_icon():String return icon.trim() == '' ? spritePath : icon;

	public var spritePath(default, null):String;
	public var scaleMult(default, null):Float;
	public var aliasing(default, null):Bool;
	public var flipSprite(default, null):Bool;
	@:isVar public var selfColor(get, set):Null<FlxColor>;
	inline function get_selfColor():FlxColor return selfColor == null ? 0xffffffff : selfColor;
	inline function set_selfColor(value:FlxColor):FlxColor {value.alphaFloat = 1; return selfColor = value;}
	public var isFromEngine(default, null):CharDataType;

	public var script(default, null):Script;

	public var charData(default, null):CharData;
	public function new(x:Float, y:Float, faceLeft:Bool = false, character:String = 'making this whatever to force failsafe', variant:String = 'Peanut Butter & (Blue) Cheese') {
		super(x, y);

		charName = character;
		charVariant = variant;
		isFacing = faceLeft ? leftFace : rightFace;

		script = Script.create('$charName${hasVariant ? '/$charVariant' : ''}', 'char');
		script.load(true);
		script.call('create');

		switch (charName) {
			/* case 'bf-pixel-dead':
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
				aliasing = true; */

			default:
				charData = ParseUtil.character(charName, charVariant); // get data

				displayName = charData.name;
				isFromEngine = charData.isFromEngine;

				frames = Paths.getAtlasFrames('characters/${spritePath = charData.sprite}');

				flipSprite = charData.flip;
				for (anim in charData.anims) {
					// multsparrow support soon
					var shouldFlip:Bool = flipSprite;
					if (anim.flip) shouldFlip = !shouldFlip;
					addAnimation(anim.name, anim.tag, anim.indices, anim.fps, anim.loop, shouldFlip);
					setupAnim(anim.name, anim.offset.x, anim.offset.y, anim.swapAnim, anim.flipAnim);
				}
				xyOffset.set(charData.position.x, charData.position.y);
				camPoint.set(charData.camera.x, charData.camera.y);

				scaleMult = charData.scale;
				singLength = charData.singLen;
				icon = charData.icon;
				aliasing = charData.aliasing;
				selfColor = FlxColor.fromString(charData.color);
				beatInterval = charData.beat;
		}

		antialiasing = aliasing;
		if (scaleMult != 1) {
			setGraphicSize(Std.int(width * scaleMult));
			updateHitbox();
		}

		dance();

		script.call('createPost');
	}

	override public function reload(hard:Bool = false) {
		script.call('parentReload', [hard, reloading]);
		lastHit = Math.NEGATIVE_INFINITY;
		super.reload(hard);
		stunned = preventIdle = onSway = false;
		bopSpeed = 1;
		suffixes = {idle: '', sing: '', anim: ''}
		script.call('parentReloadPost', [hard, reloading]);
		script.reload(hard);
	}

	inline function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);

	inline function quickAnimAdd(name:String, prefix:String)
		animation.addByPrefix(name, prefix, 24, false, flipSprite);

	var animB4Loop(default, null):String = ''; // "-end" anim code by @HIGGAMEON
	override public function update(elapsed:Float) {
		script.call('update', [elapsed]);
		if (!debugMode) {
			if (isAnimFinished() && doesAnimExist('${getAnimName()}-loop') && !getAnimName().endsWith('-loop')) {
				var event:PlaySpecialAnimEvent = script.event('playingSpecialAnim', new PlaySpecialAnimEvent('loop', true, NONE, false, 0));
				if (event.stopped) return;
				var prevAnimType:AnimType = animType;
				playAnim('${getAnimName()}-loop', event.force, event.animType, event.reverse, event.frame);
				if (prevAnimType == SING || prevAnimType == MISS) animType = prevAnimType; // for `tryDance()` checks
				script.call('playingSpecialAnimPost', [event]);
			}

			if (animType != DANCE) tryDance();
		}
		super.update(elapsed);
		script.call('updatePost', [elapsed]);
	}

	public var onSway:Bool = false;
	public function dance() {
		var event:BopEvent = script.event('dancing', new BopEvent(!onSway));
		if (!debugMode || !event.stopped) {
			if (isAnimFinished() && doesAnimExist('$animB4Loop-end') && !getAnimName().endsWith('-end')) {
				var event:PlaySpecialAnimEvent = script.event('playingSpecialAnim', new PlaySpecialAnimEvent('end', false, NONE, false, 0));
				if (event.stopped) return;
				playAnim('$animB4Loop-end', event.force, event.animType, event.reverse, event.frame);
				script.call('playingSpecialAnimPost', [event]);
			} else if (!preventIdle) {
				onSway = event.sway;
				final anim:String = onSway ? (hasSway ? 'sway' : 'idle') : 'idle';
				playAnim('$anim${doesAnimExist('$anim${suffixes.idle}') ? suffixes.idle : ''}', true, DANCE);
			}
		}
		script.call('dancingPost', [event]);
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
			default:
				if (getAnimName() == null || isAnimFinished())
					dance();
		}
	}

	public function noteHit(event:NoteHitEvent) {
		script.call('noteHit', [event]);
		if (!event.note.preventAnims.sing) {
			if (SaveManager.getOption('beatLoop')) playSingAnim(event.direction, event.note.animSuffix); else {
				if (!event.note.isSustain) playSingAnim(event.direction, event.note.animSuffix);
				else lastHit = Conductor.songPosition;
			}
		}
		script.call('noteHitPost', [event]);
	}
	public function noteMiss(event:NoteMissEvent) {
		script.call('noteMiss', [event]);
		if (!event.note.preventAnims.miss) {
			if (SaveManager.getOption('beatLoop')) playSingAnim(event.direction, event.note.animSuffix, MISS); else {
				if (!event.note.isSustain) playSingAnim(event.direction, event.note.animSuffix, MISS);
				else lastHit = Conductor.songPosition;
			}
		}
		script.call('noteMissPost', [event]);
	}
	public function generalMiss(event:MissEvent) {
		script.call('generalMiss', [event]);
		playSingAnim(event.direction, '', MISS);
		script.call('generalMissPost', [event]);
	}

	override public function stepHit(curStep:Int) {
		super.stepHit(curStep);
		script.call('stepHit', [curStep]);
	}

	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		if (curBeat % Math.round(bopSpeed * beatInterval) == 0) {
			tryDance();
			if (animType != DANCE && getAnimName().endsWith('-loop')) finishAnim(); // why tf
		}
		script.call('beatHit', [curBeat]);
	}

	override public function measureHit(curMeasure:Int) {
		super.measureHit(curMeasure);
		script.call('measureHit', [curMeasure]);
	}

	override public function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		var event:PlayAnimEvent = script.event('playingAnim', new PlayAnimEvent(checkAnimStatus(name), force, animType, reverse, frame));
		if (event.stopped) return;
		final anim:String = '${event.anim}${doesAnimExist('${event.anim}${suffixes.anim}') ? suffixes.anim : ''}';
		if (doesAnimExist(anim)) {
			if (!getAnimName().endsWith('-loop')) animB4Loop = anim;
			super.playAnim(anim, event.force, event.animType, event.reverse, event.frame);
			offset.set((offset.x - xyOffset.x) * (isFacing == leftFace ? 1 : -1), offset.y - xyOffset.y);
			if (animType == SING || animType == MISS) lastHit = Conductor.songPosition;
			script.call('playingAnimPost', [event]);
		}
	}

	inline public function singAnimCheck(sing:String, miss:String, suffix:String):Array<String> {
		final has:{miss:Bool, suffix:Bool} = {
			miss: doesAnimExist('${sing}miss$suffix') || doesAnimExist('${sing}miss'),
			suffix: suffix.trim() == '' ? false : doesAnimExist('$sing$miss$suffix')
		}
		final cool:{miss:String, suffix:String} = {
			miss: has.miss ? miss : '',
			suffix: has.suffix ? suffix : ''
		}
		return [sing, cool.miss, cool.suffix];
	}

	public static var globalSingAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public var singAnims(get, default):Array<String>;
	function get_singAnims():Array<String> {
		var theAnims:Array<String> = singAnims == null ? globalSingAnims : singAnims;
		for (index => anim in theAnims) theAnims[index] = anim == null ? globalSingAnims[index] : anim;
		return theAnims;
	}
	public function playSingAnim(direction:Int, suffix:String = '', animType:AnimType = SING, force:Bool = true, reverse:Bool = false, frame:Int = 0) {
		var event:PlaySingAnimEvent = script.event('playingSingAnim', new PlaySingAnimEvent(direction, suffix, animType, force, reverse, frame));
		if (event.stopped) return;
		var checkedAnims:Array<String> = singAnimCheck(
			event.checkAnim(singAnims, event.direction),
			event.missed ? 'miss' : '',
			event.suffix.trim() == '' ? suffixes.sing : event.suffix
		);
		playAnim('${checkedAnims[0]}${checkedAnims[1]}${checkedAnims[2]}', event.force, event.animType, event.reverse, event.frame);
		script.call('playingSingAnimPost', [event]);
	}

	override public function destroy() {
		script.destroy();
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
