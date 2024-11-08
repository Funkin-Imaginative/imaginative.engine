package backend.selfgroup.group;

/**
 * This class is just `FlxGroup` but with `ISelfGroup` in mind.
 */
typedef SelfSpriteGroup = SelfTypedSpriteGroup<FlxSprite>;

/**
 * This class is just `FlxTypedGroup` but with `ISelfGroup` in mind.
 */
class SelfTypedSpriteGroup<T:FlxSprite> extends FlxTypedSpriteGroup<T> {
	override public function new(x:Float = 0, y:Float = 0, maxSize:Int = 0) {
		super(x, y);
		group.destroy();
		group = new backend.selfgroup.group.SelfGroup.SelfTypedGroup<T>(maxSize);
	}
}