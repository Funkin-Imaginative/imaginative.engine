package fnf.ui;

import fnf.objects.FunkinSprite;

typedef AnimlessList = {
	/**
	 * The name of the animatiom.
	 */
	var name:String;

	/**
	 * The name of the animation to play instead if facing right.
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

class HealthIcon extends FunkinSprite implements IMusicBeat {
	public var sprTracker:Dynamic;
	public var trackerFunc:Dynamic->PositionMeta;
	public var updateTracking:Bool = true;
	inline public function setupTracking(spr:Dynamic, func:Dynamic->PositionMeta) {
		sprTracker = spr;
		trackerFunc = func;
	}

	public var iconScript:Script;
	private function reloadScript(newIcon:String) {
		if (iconScript != null) {
			iconScript.call('iconChanged', [newIcon]);
			iconScript.destroy();
		}
		if (iconScript == null) {
			iconScript = Script.create(newIcon, 'icon');
			iconScript.load(true);
			iconScript.call('create');
		}
	}

	public var iconData:IconData;
	public function new(char:String = 'face', faceLeft:Bool = false) {
		super();
		curIcon = char;
		isFacing = faceLeft ? leftFace : rightFace;
	}

	var _lastIcon:String;
	public var isOldIcon:Bool = false;
	inline public function swapOldIcon():Void curIcon = (isOldIcon = !isOldIcon) ? 'bf-old' : _lastIcon;

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
			iconData = ParseUtil.icon(theIcon);
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
					setupAnim(anim.name, anim.offset.x, anim.offset.y, anim.flipAnim);
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
						setupAnim(frame.name, frame.offset.x, frame.offset.y, frame.flipAnim);
					}
				}
			}
			size.scale = iconData.scale; scale.set(size.scale, size.scale); updateHitbox();
			antialiasing = iconData.aliasing;
			playAnim('idle', true);
			if (value == 'bf-old' && isOldIcon) _lastIcon = curIcon;
			iconScript.call('createPost');
			return curIcon = value;
		}
		return curIcon;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		iconScript.call('update', [elapsed]);
		if (updateTracking && sprTracker != null && trackerFunc != null) {
			final pos:PositionMeta = trackerFunc(sprTracker);
			setPosition(pos.x, pos.y);
		}
		scale.x = scale.y = FlxMath.lerp(scale.x, size.scale * size.mult, 1);
		iconScript.call('updatePost', [elapsed]);
	}

	override public function stepHit(curStep:Int) {
		super.stepHit(curStep);
		iconScript.call('stepHit', [curStep]);
	}

	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		scale.x = scale.y = size.upBy * size.mult;
		iconScript.call('beatHit', [curBeat]);
	}

	override public function measureHit(curMeasure:Int) {
		super.measureHit(curMeasure);
		iconScript.call('measureHit', [curMeasure]);
	}

	override public function destroy() {
		iconScript.destroy();
		super.destroy();
	}
}
