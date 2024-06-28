package fnf.ui;

import flixel.math.FlxRect;
import fnf.backend.interfaces.IPlayAnim.AnimType;
import fnf.objects.FunkinSprite;

typedef AnimlessList = {
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
	 * The animation index of the image.
	 */
	var index:Int;

	/**
	 * The animation offsets.
	 */
	@:optional var offset:PositionMeta;

	/**
	 * The alternate sprite path for this animation.
	 */
	@:optional var spritePath:String;

	/**
	 * Should the animation face the other way?
	 */
	@:optional @:default(false) var flip:Bool;
}

typedef IconData = {
	var dimensions:Int;
	var scale:Float;
	var flip:Bool;
	var aliasing:Bool;
	@:optional var anims:Array<AnimList>;
	@:optional var frames:Array<AnimlessList>;
}

class HealthIcon extends FunkinSprite {
	public var sprTracker:Dynamic;
	public var trackerFunc:Dynamic->PositionMeta;
	public var updateTracking:Bool = true;
	inline public function setupTracking(spr:Dynamic, func:Dynamic->PositionMeta) {
		sprTracker = spr;
		trackerFunc = func;
	}

	public var script:Script;
	private function reloadScript(newIcon:String) {
		if (script != null) {
			script.call('iconChanged', [newIcon]);
			script.destroy();
		}
		if (script == null) {
			script = Script.create(newIcon, 'icon');
			script.load(true);
			script.call('create');
		}
	}

	public var iconData:IconData;
	public function new(char:String = 'face', faceLeft:Bool = false) {
		super();
		curIcon = char;
		isFacing = faceLeft ? leftFace : rightFace;
	}

	override public function reload(hard:Bool = false) super.reload(hard);

	var _lastIcon:String;
	public var isOldIcon:Bool = false;
	inline public function swapOldIcon():Void curIcon = (isOldIcon = !isOldIcon) ? 'bf-old' : _lastIcon;

	@:isVar public var selfColor(get, set):Null<FlxColor>;
	inline function get_selfColor():FlxColor return selfColor == null ? CoolUtil.dominantColor(this) : selfColor;
	inline function set_selfColor(value:FlxColor):FlxColor {value.alphaFloat = 1; return selfColor = value;}

	public var size:{scale:Float, mult:Float, upBy:Float} = {
		scale: 1,
		mult: 1,
		upBy: 1.3
	}

	public var curIcon(default, set):String;
	function set_curIcon(value:String):String {
		if (value != curIcon) {
			var theIcon:String = value;
			if (!FileSystem.exists(Paths.image('icons/$theIcon'))) theIcon = 'face';
			iconData = ParseUtil.icon(theIcon); // get data
			reloadScript(theIcon);
			if (FileSystem.exists(Paths.xml('images/icons/$theIcon'))) {
				if (iconData.anims != null)
				for (anim in iconData.anims) {
					frames = Paths.getSparrowAtlas('icons/$theIcon');
					var shouldFlip:Bool = iconData.flip;
					if (anim.flip) shouldFlip = !shouldFlip;
					if (anim.indices != null && anim.indices.length > 0)
						animation.addByIndices(anim.name, anim.tag, anim.indices, '', anim.fps, anim.loop, shouldFlip);
					else animation.addByPrefix(anim.name, anim.tag, anim.fps, anim.loop, shouldFlip);
					setupAnim(anim.name, anim.offset.x, anim.offset.y, anim.swapAnim, anim.flipAnim);
				}
			} else {
				if (iconData.frames == null) {
					loadGraphic(Paths.image('icons/$theIcon'), true, 150, 150);
					animation.add('idle', [0], 0, false); setupAnim('idle');
					animation.add('losing', [1], 0, false); setupAnim('losing');
				} else {
					for (frame in iconData.frames) {
						loadGraphic(Paths.image('icons/$theIcon'), true, iconData.dimensions, iconData.dimensions);
						var shouldFlip:Bool = iconData.flip;
						if (frame.flip) shouldFlip = !shouldFlip;
						animation.add(frame.name, [frame.index], 0, false, shouldFlip);
						setupAnim(frame.name, frame.offset.x, frame.offset.y, frame.swapAnim, frame.flipAnim);
					}
				}
			}
			size.scale = iconData.scale; scale.set(size.scale, size.scale); updateHitbox();
			antialiasing = iconData.aliasing;
			playAnim('idle', true);
			if (value == 'bf-old' && isOldIcon) _lastIcon = curIcon;
			script.call('createPost');
			return curIcon = value;
		}
		return curIcon;
	}

	override public function update(elapsed:Float) {
		script.call('update', [elapsed]);
		scale.x = scale.y = FlxMath.lerp(scale.x, size.scale * size.mult, 0.33);
		super.update(elapsed);
		if (updateTracking && sprTracker != null && trackerFunc != null) {
			final pos:PositionMeta = trackerFunc(sprTracker);
			setPosition(pos.x, pos.y);
		}
		script.call('updatePost', [elapsed]);
	}

	override function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		var event:PlayAnimEvent = script.event('playingAnim', new PlayAnimEvent(checkAnimStatus(name), force, animType, reverse, frame));
		if (event.stopped) return;
		final anim:String = event.anim;
		if (doesAnimExist(anim)) {
			super.playAnim(anim, event.force, event.animType, event.reverse, event.frame);
			offset.set((offset.x) * (isFacing == leftFace ? 1 : -1), offset.y);
			script.call('playingAnimPost', [event]);
		}
	}

	override public function stepHit(curStep:Int) {
		super.stepHit(curStep);
		script.call('stepHit', [curStep]);
	}

	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		scale.x = scale.y = size.upBy * size.mult;
		script.call('beatHit', [curBeat]);
	}

	override public function measureHit(curMeasure:Int) {
		super.measureHit(curMeasure);
		script.call('measureHit', [curMeasure]);
	}

	override public function destroy() {
		script.destroy();
		super.destroy();
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
