package imaginative.animation;

import flixel.animation.FlxAnimationController;
#if ANIMATE_SUPPORT
import animate.FlxAnimateController.FlxAnimateAnimation as Animation;
#else
import flixel.animation.FlxAnimation as Animation;
#end

// TODO: This class in unneeded, revert the usage of this class.
class BetterAnimation extends Animation {
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

	override public function clone(newParent:FlxAnimationController):BetterAnimation {
		var anim = new BetterAnimation(newParent, name, frames, frameRate, looped, flipX, flipY);
		#if ANIMATE_SUPPORT anim.timeline = timeline; #end
		return anim;
	}
}