#if IGROUP_INTERFACE
package backend.interfaces;

/**
 * Implementing this interface will allow a object to contain it's own `FlxSpriteGroup`.
 * As well as contain itself within the group.
 */
interface IGroup {
	/**
	 * The group inside the sprite.
	 */
	var group(default, null):BeatSpriteGroup;
	/**
	 * Iterates through every member.
	 * @param filter For filtering.
	 * @return `FlxTypedGroupIterator<FlxSprite>` ~ An iterator.
	 */
	function iterator(?filter:FlxSprite->Bool):FlxTypedGroupIterator<FlxSprite>;

	/**
	 * Adds a new `FlxSprite` to the group.
	 * @param sprite The sprite or sprite group you want to add to the group.
	 * @return `FlxSprite`
	 */
	function add(sprite:FlxSprite):FlxSprite;
	/**
	 * Adds a new `FlxSprite` behind the main member.
	 * @param sprite The sprite or sprite group you want to add to the group.
	 * @return `FlxSprite`
	 */
	function addBehind(sprite:FlxSprite):FlxSprite;
	/**
	 * Inserts a new `FlxSprite` subclass to the group at the specified position.
	 * @param position The position that the new sprite or sprite group should be inserted at.
	 * @param sprite The sprite or sprite group you want to insert into the group.
	 * @return `FlxSprite` ~ The same object that was passed in.
	 */
	function insert(position:Int, sprite:FlxSprite):FlxSprite;
	/**
	 * Removes the specified sprite from the group.
	 * @param sprite The `FlxSprite` you want to remove.
	 * @param splice Whether the object should be cut from the array entirely or not.
	 * @return `FlxSprite` ~ The removed sprite.
	 */
	function remove(sprite:FlxSprite, splice:Bool = false):FlxSprite;
}
#end