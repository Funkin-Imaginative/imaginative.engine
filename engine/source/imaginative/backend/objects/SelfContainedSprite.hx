package imaginative.backend.objects;

import flixel.addons.effects.FlxSkewedSprite;

// TODO: Look back at ISelfGroup code.
/**
 * Used for allowing sprites to be their own group.
 */
class SelfContainedSprite extends FlxSkewedSprite {

	/**
	 * The group inside the sprite.
	 */
	public var group(default, null):BeatSpriteGroup;

	/**
	 * Iterates through every member.
	 * @param filter For iterating through the group.
	 * @return `FlxTypedGroupIterator<FlxSprite>` ~ An iterator.
	 */
	public function iterator(?filter:FlxSprite->Bool):FlxTypedGroupIterator<FlxSprite>
		return group.iterator(filter);

	/**
	 * Adds a new `FlxSprite` to the group.
	 * @param sprite The sprite or sprite group you want to add to the group.
	 * @return `FlxSprite` ~ The added sprite.
	 */
	public function add(sprite:FlxSprite):FlxSprite
		return group.add(sprite);
	/**
	 * Adds a new `FlxSprite` behind the main member.
	 * @param sprite The sprite or sprite group you want to add to the group.
	 * @return `FlxSprite` ~ The added sprite.
	 */
	public function addBehind(sprite:FlxSprite):FlxSprite
		return SpriteUtil.addBehind(sprite, this, group.group);
	/**
	 * Inserts a new `FlxSprite` subclass to the group at the specified position.
	 * @param position The position that the new sprite or sprite group should be inserted at.
	 * @param sprite The sprite or sprite group you want to insert into the group.
	 * @return `FlxSprite` ~ The same object that was passed in.
	 */
	public function insert(position:Int, sprite:FlxSprite):FlxSprite
		return group.insert(position, sprite);

	/**
	 * Removes the specified sprite from the group.
	 * @param sprite The `FlxSprite` you want to remove.
	 * @param splice Whether the object should be cut from the array entirely or not.
	 * @return `FlxSprite` ~ The removed sprite.
	 */
	public function remove(sprite:FlxSprite, splice:Bool = false):FlxSprite
		return group.remove(sprite, splice);

	/**
	 * Used to help with updating conflicts.
	 * This will be used to update the sprite itself.
	 * While update now updates the group instead.
	 * @param elapsed Time in-between frames.
	 */
	public function sprite_update(elapsed:Float):Void
		super.update(elapsed);
	/**
	 * Used to help with drawing conflicts.
	 * This will be used to draw the sprite itself.
	 * While draw now draws the group instead.
	 */
	public function sprite_draw():Void
		super.draw();

	override public function new(x:Float = 0, y:Float = 0, ?simpleGraphic:flixel.system.FlxAssets.FlxGraphicAsset) {
		super(0, 0, simpleGraphic);
		group = new BeatSpriteGroup(x, y);
		add(this);
	}

	override public function update(elapsed:Float):Void
		group.update(elapsed);
	override public function draw():Void
		group.draw();
}