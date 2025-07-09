package imaginative.animation;

import flixel.animation.FlxAnimation;
#if ANIMATE_SUPPORT
import animate.FlxAnimateController as Controller;
import animate.internal.Timeline;
#else
import flixel.animation.FlxAnimationController as Controller;
#end

@SuppressWarnings('checkstyle:FieldDocComment')
private typedef Anim = {
	var name:String;
	var anim:FlxAnimation;
}

class BetterAnimationController extends Controller {
	function checkAnims(?specificAnim:String):Void {
		var anims:Array<Anim> = [];

		if (specificAnim == null)
			anims = [for (tag => anim in _animations) {name: tag, anim: anim}].filter((anim:Anim) -> return !(anim.anim is BetterAnimation));
		else if (_animations.exists(specificAnim))
			anims = [{name: specificAnim, anim: _animations.get(specificAnim)}];

		for (anim in anims) {
			_animations.remove(anim.name);
			var newAnim:BetterAnimation = new BetterAnimation(this, anim.anim.name, anim.anim.frames, anim.anim.frameRate, anim.anim.looped, anim.anim.flipX, anim.anim.flipY);
			#if ANIMATE_SUPPORT
			var flxAnim:animate.FlxAnimateController.FlxAnimateAnimation = cast anim.anim;
			newAnim.timeline = flxAnim.timeline;
			#end
			_animations.set(anim.name, newAnim);
			anim.anim.destroy();
		}
	}

	override public function add(name:String, frames:Array<Int>, frameRate:Float = 30, looped:Bool = true, flipX:Bool = false, flipY:Bool = false):Void {
		super.add(name, frames, frameRate, looped, flipX, flipY);
		checkAnims(name);
	}
	override public function addByNames(Name:String, FrameNames:Array<String>, FrameRate:Float = 30, Looped:Bool = true, FlipX:Bool = false, FlipY:Bool = false):Void {
		super.addByNames(Name, FrameNames, FrameRate, Looped, FlipX, FlipY);
		checkAnims(Name);
	}
	override public function addByStringIndices(Name:String, Prefix:String, Indices:Array<String>, Postfix:String, FrameRate:Float = 30, Looped:Bool = true, FlipX:Bool = false, FlipY:Bool = false):Void {
		super.addByStringIndices(Name, Prefix, Indices, Postfix, FrameRate, Looped, FlipX, FlipY);
		checkAnims(Name);
	}
	override public function addByIndices(Name:String, Prefix:String, Indices:Array<Int>, Postfix:String, FrameRate:Float = 30, Looped:Bool = true, FlipX:Bool = false, FlipY:Bool = false):Void {
		super.addByIndices(Name, Prefix, Indices, Postfix, FrameRate, Looped, FlipX, FlipY);
		checkAnims(Name);
	}
	override public function addByPrefix(name:String, prefix:String, frameRate:Float = 30, looped:Bool = true, flipX:Bool = false, flipY:Bool = false):Void {
		super.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);
		checkAnims(name);
	}

	#if ANIMATE_SUPPORT
	override public function addByFrameLabel(name:String, label:String, ?frameRate:Float, ?looped:Bool = true, ?flipX:Bool, ?flipY:Bool, ?timeline:Timeline):Void {
		super.addByFrameLabel(name, label, frameRate, looped, flipX, flipY, timeline);
		checkAnims(name);
	}
	override public function addByFrameLabelIndices(name:String, label:String, indices:Array<Int>, ?frameRate:Float, ?looped:Bool = true, ?flipX:Bool, ?flipY:Bool, ?timeline:Timeline):Void {
		super.addByFrameLabelIndices(name, label, indices, frameRate, looped, flipX, flipY, timeline);
		checkAnims(name);
	}
	override public function addByTimelineIndices(name:String, timeline:Timeline, indices:Array<Int>, ?frameRate:Float, ?looped:Bool = true, ?flipX:Bool, ?flipY:Bool):Void {
		super.addByTimelineIndices(name, timeline, indices, frameRate, looped, flipX, flipY);
		checkAnims(name);
	}
	override public function addBySymbol(name:String, symbolName:String, ?frameRate:Float, ?looped:Bool = true, ?flipX:Bool, ?flipY:Bool):Void {
		super.addBySymbol(name, symbolName, frameRate, looped, flipX, flipY);
		checkAnims(name);
	}
	override public function addBySymbolIndices(name:String, symbolName:String, indices:Array<Int>, ?frameRate:Float, ?looped:Bool = true, ?flipX:Bool, ?flipY:Bool):Void {
		super.addBySymbolIndices(name, symbolName, indices, frameRate, looped, flipX, flipY);
		checkAnims(name);
	}
	#end
}