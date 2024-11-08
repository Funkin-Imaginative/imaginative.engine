package objects;

import backend.scripting.events.objects.BopEvent;
import backend.scripting.events.objects.PlaySpecialAnimEvent;

typedef BeatData = {
	/**
	 * The amount of beats it takes to trigger the dance.
	 */
	@:default(0) var interval:Int;
	/**
	 * If true, the dance will still happen, even if the beat numbers are in the negatives.
	 */
	@:default(false) var skipnegative:Bool;
}

/**
 * This class BaseSprite but with IBeat implementation.
 */
class BeatSprite extends BaseSprite implements ITexture<BeatSprite> implements IBeat {
	// Texture related stuff.
	override public function loadTexture(newTexture:ModPath):BeatSprite
		return cast super.loadTexture(newTexture);
	override public function loadImage(newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):BeatSprite
		return cast super.loadImage(newTexture, animated, width, height);
	override public function loadSheet(newTexture:ModPath):BeatSprite
		return cast super.loadSheet(newTexture);

	/**
	 *	The amount of beats it takes to trigger the dance.
	 */
	public var bopRate(get, set):Int;
	inline function get_bopRate():Int
		return Math.round(beatInterval * bopSpeed);
	inline function set_bopRate(value:Int):Int
		return beatInterval = value;
	/**
	 * The multiplier for the `beatInterval`.
	 */
	public var bopSpeed(default, set):Float = 1;
	inline function set_bopSpeed(value:Float):Float
		return bopSpeed = value < 1 ? 1 : value;
	/**
	 *	The internal amount of beats it takes to trigger the dance.
	 */
	public var beatInterval(default, set):Int = 0;
	inline function set_beatInterval(value:Int):Int
		return beatInterval = value < 1 ? (hasSway ? 1 : 2) : value;

	/**
	 * If true, the dance will still happen, even if the beat numbers are in the negatives.
	 */
	public var skipNegativeBeats:Bool = false;
	/**
	 * If true, the character will play the sway animation on the off beat.
	 */
	public var hasSway(get, never):Bool; // Replaced 'danceLeft' with 'idle' and 'danceRight' with 'sway'.
	inline function get_hasSway():Bool
		return animation.exists('sway$idleSuffix') ? true : animation.exists('sway');
	/**
	 * If true, it prevents the idle animation from playing altogether.
	 */
	public var preventIdle:Bool = false;

	override public function renderData(inputData:SpriteData, applyStartValues:Bool = false):Void {
		var modPath:ModPath = null;
		try {
			modPath = inputData.asset.image;
			if (inputData.beat != null) {
				beatInterval = inputData.beat.interval;
				skipNegativeBeats = inputData.beat.skipnegative;
			}
		} catch(error:haxe.Exception)
			try {
				trace('Something went wrong. All try statements were bypassed! Tip: "${modPath.format()}"');
			} catch(error:haxe.Exception) trace('Something went wrong. All try statements were bypassed! Tip: "null"');
		super.renderData(inputData, applyStartValues);
	}

	var animB4Loop(default, null):String = ''; // "-end" anim code by @HIGGAMEON
	override public function update(elapsed:Float):Void {
		scripts.call('update', [elapsed]);
		if (!debugMode) {
			if (isAnimFinished() && doesAnimExist('${getAnimName()}-loop') && !getAnimName().endsWith('-loop')) {
				final event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('loop'));
				if (!event.prevented) {
					final prevAnimContext:AnimContext = animContext;
					playAnim('${getAnimName()}-loop', event.force, event.context, event.reverse, event.frame);
					if (prevAnimContext == IsSinging || prevAnimContext == HasMissed) animContext = prevAnimContext; // for `tryDance()` checks
					scripts.call('playingSpecialAnimPost', [event]);
				}
			}

			if (animContext != IsDancing) tryDance();
		}
		super.update(elapsed);
	}

	/**
	 * The animation suffix for the idle.
	 */
	public var idleSuffix(default, set):String = '';
	inline function set_idleSuffix(value:String):String
		return idleSuffix = value.trim();

	/**
	 * When run, it attempts to trigger the dance.
	 */
	public function tryDance():Void {
		switch (animContext) {
			case IsDancing:
				dance();
			case NoDancing | NoSinging:
				if (getAnimName() == null)
					dance();
			default:
				if (getAnimName() == null || isAnimFinished())
					dance();
		}
	}

	/**
	 * States when the sway would play instead.
	 */
	public var onSway:Bool = false;
	/**
	 * When run, it triggers the dance.
	 */
	public function dance():Void {
		final event:BopEvent = scripts.event('dancing', new BopEvent(!onSway));
		if (!debugMode || !event.prevented) {
			if (isAnimFinished() && doesAnimExist('$animB4Loop-end') && !getAnimName().endsWith('-end')) {
				final event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('end'));
				if (event.prevented) return;
				playAnim('$animB4Loop-end', event.force, event.context, event.reverse, event.frame);
				scripts.call('playingSpecialAnimPost', [event]);
			} else if (!preventIdle) {
				onSway = event.sway;
				final anim:String = onSway ? (hasSway ? 'sway' : 'idle') : 'idle';
				playAnim('$anim', IsDancing, doesAnimExist('$anim$idleSuffix') ? idleSuffix : '');
			}
		}
		scripts.call('dancingPost', [event]);
	}

	override function generalSuffixCheck(context:AnimContext):String {
		return switch (context) {
			case IsDancing:
				idleSuffix;
			default:
				super.generalSuffixCheck(context);
		}
	}

	/**
	 * The current step.
	 */
	public var curStep(default, null):Int;
	/**
	 * Runs when the next step happens.
	 * @param curStep The current step.
	 */
	public function stepHit(curStep:Int):Void {
		this.curStep = curStep;
		scripts.call('stepHit', [curStep]);
	}

	/**
	 * The current beat.
	 */
	public var curBeat(default, null):Int;
	/**
	 * Runs when the next beat happens.
	 * @param curBeat The current beat.
	 */
	public function beatHit(curBeat:Int):Void {
		this.curBeat = curBeat;
		if (!(skipNegativeBeats && curBeat < 0) && curBeat % (bopRate < 1 ? 1 : bopRate) == 0) {
			tryDance();
			if (animContext != IsDancing && getAnimName().endsWith('-loop')) finishAnim();
		}
		scripts.call('beatHit', [curBeat]);
	}

	/**
	 * The current measure.
	 */
	public var curMeasure(default, null):Int;
	/**
	 * Runs when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	public function measureHit(curMeasure:Int):Void {
		this.curMeasure = curMeasure;
		scripts.call('measureHit', [curMeasure]);
	}
}