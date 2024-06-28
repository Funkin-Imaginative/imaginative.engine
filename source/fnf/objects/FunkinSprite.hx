package fnf.objects;

import fnf.backend.interfaces.IPlayAnim;
import flixel.addons.effects.FlxSkewedSprite;

enum abstract SpriteFacing(String) from String to String {
	/**
	 * States that the object is facing left.
	 */
	var leftFace = 'left';

	/**
	 * States that the object is facing right.
	 */
	var rightFace = 'right';
}

typedef AnimList = {
	/**
	 * The name of the animatiom.
	 */
	var name:String;

	/**
	 * This is mostly used for swapping left and right anims when the character is flipped.
	 */
	@:optional var swapAnim:String;

	/**
	 * This is if you want your character to flip properly.
	 */
	@:optional var flipAnim:String;

	/**
	 * The internal animation name on the objects xml/json.
	 */
	var tag:String;

	/**
	 * The frames per second (FPS) of the animation.
	 */
	@:default(24) var fps:Float;

	/**
	 * Should the animation loop?
	 */
	@:optional @:default(false) var loop:Bool;

	/**
	 * The animation offsets.
	 */
	var offset:PositionMeta;

	/**
	 * The specified frame order to play out.
	 */
	@:optional @:default([]) var indices:Array<Int>;

	/**
	 * The alternate sprite path for this animation.
	 */
	@:optional var spritePath:String;

	/**
	 * Should the animation face the other way?
	 */
	@:optional @:default(false) var flip:Bool;
}

class FunkinSprite extends FlxSkewedSprite implements ISong implements IPlayAnim implements IReloadable {
	public var _update:Float->Void;
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var debugMode:Bool = false; // for editors

	public var animInfo:Map<String, AnimMapInfo> = new Map<String, AnimMapInfo>();
	public var animType:AnimType = NONE;

	// quick way to set which direction the object is facing
	@:isVar public var isFacing(get, set):SpriteFacing = rightFace;
	inline function get_isFacing():SpriteFacing return flipX ? rightFace : leftFace;
	inline function set_isFacing(value:SpriteFacing):SpriteFacing {
		flipX = value == leftFace;
		return isFacing = value;
	}

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
    }

	public var reloading(default, null):Bool = false;
	public function reload(hard:Bool = false) {
		reloading = true;
		if (hard) {
			extra.clear();
			_update = null;
		}
		reloading = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (_update != null) _update(elapsed);
	}

	inline public static function addAnimationToObject<Sprite:FlxSprite>(sprite:Sprite, name:String, tag:String, ?indices:Array<Int>, fps:Float = 24, loop:Bool = false, flipX:Bool = false, flipY:Bool = false):Void {
		if (indices != null && indices.length > 0) sprite.animation.addByIndices(name, tag, indices, '', fps, loop, flipX, flipY);
		else sprite.animation.addByPrefix(name, tag, fps, loop, flipX, flipY);
	}
	inline public function addAnimation(name:String, tag:String, ?indices:Array<Int>, fps:Float = 24, loop:Bool = false, flipX:Bool = false, flipY:Bool = false):Void {
		if (indices != null && indices.length > 0) animation.addByIndices(name, tag, indices, '', fps, loop, flipX, flipY);
		else animation.addByPrefix(name, tag, fps, loop, flipX, flipY);
	}

	inline public function setupAnim(name:String, x:Float = 0, y:Float = 0, swapAnim:String = '', flipAnim:String = '')
		if (!animInfo.exists(name)) animInfo.set(name, {offset: {x: x, y: y}, swapAnim: swapAnim, flipAnim: flipAnim});
	public function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		final anim:String = checkAnimStatus(name);
		if (doesAnimExist(anim)) {
			final daOffset:PositionMeta = getAnimInfo(anim).offset;
			animation.play(anim, force, reverse, frame);
			offset.set(daOffset.x, daOffset.y);
			this.animType = animType;
		}
	}
	inline public function checkAnimStatus(name:String):String {
		var targetName:String = name;
		// trace('OG: $targetName');

		if (!debugMode) {
			final swapName:String = doesAnimExist(targetName) ? animInfo.get(targetName).swapAnim : '';
			targetName = isFacing == leftFace ? targetName : (doesAnimExist(swapName) ? swapName : targetName);
			// trace('Swap: $targetName');

			final flipName:String = doesAnimExist(targetName) ? animInfo.get(targetName).flipAnim : '';
			targetName = isFacing == leftFace ? targetName : (doesAnimExist(flipName) ? flipName : targetName);
			// trace('Flip: $targetName');
		}

		return targetName;
	}

	inline public function getAnimName(ignoreSwap:Bool = true, ignoreFlip:Bool = false):String {
		if (animation.name != null) {
			var targetAnim:String = animation.name;
			targetAnim = (!ignoreSwap && doesAnimExist(targetAnim)) ? animInfo.get(targetAnim).swapAnim : targetAnim;
			targetAnim = (!ignoreFlip && doesAnimExist(targetAnim)) ? animInfo.get(targetAnim).flipAnim : targetAnim;
			return targetAnim;
		}
		return animation.name;
	}
	inline public function getAnimInfo(name:String):AnimMapInfo return doesAnimExist(name) ? animInfo.get(name) : {offset: {x: 0, y: 0}, swapAnim: '', flipAnim: ''}
	inline public function isAnimFinished():Bool return (animation == null || animation.curAnim == null) ? false : animation.curAnim.finished;

	inline public function finishAnim():Void if (animation.curAnim != null) animation.curAnim.finish();

	inline public function doesAnimExist(name:String, inGeneral:Bool = false):Bool return inGeneral ? animation.exists(name) : (animation.exists(name) && animInfo.exists(name));

	public function stepHit(curStep:Int) {}
	public function beatHit(curBeat:Int) {}
    public function measureHit(curMeasure:Int) {}

	override function destroy() {
		reloading = false;
		super.destroy();
	}
}