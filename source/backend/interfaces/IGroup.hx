#if IGROUP_INTERFACE
package backend.interfaces;

interface IGroup {
	var group(default, null):BeatSpriteGroup;
	function iterator(?filter:FlxSprite->Bool):FlxTypedGroupIterator<FlxSprite>;

	function add(sprite:FlxSprite):FlxSprite;
	function insert(position:Int, sprite:FlxSprite):FlxSprite;
	function remove(sprite:FlxSprite, splice:Bool = false):FlxSprite;
}
#end