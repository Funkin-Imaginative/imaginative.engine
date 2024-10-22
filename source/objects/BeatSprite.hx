package objects;

import backend.scripting.events.objects.sprites.BopEvent;
import backend.scripting.events.objects.sprites.PlaySpecialAnimEvent;

typedef BeatData = {
	/**
	 * The amount of beats it takes to trigger the dance.
	 */
	@:default(0) var invertal:Int;
	/**
	 * If true, the dance will still happen, even if the beat numbers are in the negatives.
	 */
	@:default(false) var skipnegative:Bool;
}

/**
 * This class BaseSprite but with IBeat implementation.
 */
class BeatSprite extends BaseSprite implements IBeat {
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

	/**
	 * The beat sprite data.
	 */
	public var beatData:BeatData = null;
	/**
	 * Another way to create a BeatSprite. But you can set the root this time.
	 * @param x Starting x position.
	 * @param y Starting y position.
	 * @param path The mod path.
	 * @param pathType The path type.
	 * @return `BeatSprite`
	 */
	public static function makeSprite(x:Float = 0, y:Float = 0, path:String, pathType:FunkinPath = ANY):BeatSprite {
		return new BeatSprite(x, y, ParseUtil.object(path, isBeatSprite, pathType), Paths.script(path, pathType));
	}
	override public function renderData(inputData:TypeSpriteData):Void {
		final incomingData:BeatSpriteData = cast inputData;
		super.renderData(inputData);
		try {
			try {
				beatInterval = incomingData.beat.invertal.getDefault(0);
			} catch(error:haxe.Exception) trace('Couldn\'t set object bop rate.');
			try {
				skipNegativeBeats = incomingData.beat.skipnegative.getDefault(false);
			} catch(error:haxe.Exception) trace('Couldn\'t set skipping negative beats.');

			try {
				beatData = incomingData.beat;
			} catch(error:haxe.Exception) trace('Couldn\'t set the beat data variable.');
		} catch(error:haxe.Exception)
			try {
				trace('Something went very wrong! What could bypass all the try\'s??? Tip: "${incomingData.asset.image}"');
			} catch(error:haxe.Exception) trace('Something went very wrong! What could bypass all the try\'s??? Tip: "null"');
	}

	var animB4Loop(default, null):String = ''; // "-end" anim code by @HIGGAMEON
	override public function update(elapsed:Float):Void {
		scripts.call('update', [elapsed]);
		if (!debugMode) {
			if (isAnimFinished() && doesAnimExist('${getAnimName()}-loop') && !getAnimName().endsWith('-loop')) {
				final event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('loop', true, Unclear, false, 0));
				if (!event.stopped) {
					final prevAnimContext:AnimContext = animContext;
					playAnim('${getAnimName()}-loop', event.force, event.animContext, event.reverse, event.frame);
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
		if (!debugMode || !event.stopped) {
			if (isAnimFinished() && doesAnimExist('$animB4Loop-end') && !getAnimName().endsWith('-end')) {
				final event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('end', true, Unclear, false, 0));
				if (event.stopped) return;
				playAnim('$animB4Loop-end', event.force, event.animContext, event.reverse, event.frame);
				scripts.call('playingSpecialAnimPost', [event]);
			} else if (!preventIdle) {
				onSway = event.sway;
				final anim:String = onSway ? (hasSway ? 'sway' : 'idle') : 'idle';
				playAnim('$anim', true, IsDancing, doesAnimExist('$anim$idleSuffix') ? idleSuffix : '');
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
		if (!(skipNegativeBeats && curBeat < 0) && curBeat % bopRate == 0) {
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