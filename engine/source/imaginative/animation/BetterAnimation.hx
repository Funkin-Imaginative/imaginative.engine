package imaginative.animation;

import flixel.animation.FlxAnimation;
import flixel.animation.FlxAnimationController;

class BetterAnimation extends FlxAnimation {
	/**
	 * The offset position for the animation.
	 */
	public var offset:FlxPoint;

	override public function new(parent:FlxAnimationController, name:String, frames:Array<Int>, frameRate:Float = 0, looped:Bool = true, flipX:Bool = false, flipY:Bool = false) {
		super(parent, name, frames, frameRate, looped, flipX, flipY);
		offset = FlxPoint.get();
	}

	override public function destroy():Void {
		offset.put();
		super.destroy();
	}

	override public function clone(newParent:FlxAnimationController):BetterAnimation
		return new BetterAnimation(newParent, name, frames, frameRate, looped, flipX, flipY);
}