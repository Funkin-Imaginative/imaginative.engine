package objects;

import backend.scripting.events.objects.sprites.BopEvent;
import backend.scripting.events.objects.sprites.PlaySpecialAnimEvent;

typedef BeatData = {
	@:default(0) var invertal:Int;
	@:default(false) var skipnegative:Bool;
}

class BeatSprite extends BaseSprite implements IBeat {
	public var idleSuffix:String = '';
	public var animSuffix:String = '';

	public var bopRate(get, set):Int;
	inline function get_bopRate():Int return Math.round(beatInterval * bopSpeed);
	inline function set_bopRate(value:Int):Int return beatInterval = value;
	public var bopSpeed(default, set):Float = 1; inline function set_bopSpeed(value:Float):Float return bopSpeed = value < 1 ? 1 : value;
	public var beatInterval(get, default):Int = 0; inline function get_beatInterval():Int return beatInterval < 1 ? (hasSway ? 1 : 2) : beatInterval;

	public var skipNegativeBeats:Bool = false;
	public var hasSway(get, never):Bool; // Replaced 'danceLeft' with 'idle' and 'danceRight' with 'sway'.
	inline function get_hasSway():Bool return animation.exists('sway$idleSuffix') ? true : animation.exists('sway');
	public var preventIdle:Bool = false;

	public var beatData:BeatData = null;
	public static function makeSprite(x:Float = 0, y:Float = 0, path:String, pathType:FunkinPath = ANY):BeatSprite {
		return new BeatSprite(x, y, cast ParseUtil.object(path, isBeatSprite, pathType));
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

	public var onSway:Bool = false;
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
				playAnim('$anim${doesAnimExist('$anim$idleSuffix') ? idleSuffix : ''}', true, IsDancing);
			}
		}
		scripts.call('dancingPost', [event]);
	}

	public var curStep(default, null):Int;
	public function stepHit(curStep:Int):Void {
		this.curStep = curStep;
		scripts.call('stepHit', [curStep]);
	}

	public var curBeat(default, null):Int;
	public function beatHit(curBeat:Int):Void {
		this.curBeat = curBeat;
		if (!(skipNegativeBeats && curBeat < 0) && curBeat % bopRate == 0) {
			tryDance();
			if (animContext != IsDancing && getAnimName().endsWith('-loop')) finishAnim();
		}
		scripts.call('beatHit', [curBeat]);
	}

	public var curMeasure(default, null):Int;
	public function measureHit(curMeasure:Int):Void {
		this.curMeasure = curMeasure;
		scripts.call('measureHit', [curMeasure]);
	}
}