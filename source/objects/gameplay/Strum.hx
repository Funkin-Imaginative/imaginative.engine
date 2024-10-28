package objects.gameplay;

class Strum extends FlxSprite implements ISelfGroup {
	// Cool variables.
	/**
	 * Custom update function.
	 */
	public var _update:Float->Void;
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * The field the strum is assigned to.
	 */
	public var setField(default, null):ArrowField;

	// Strum specific variables.
	/**
	 * The strum lane index.
	 */
	public var id(default, null):Int;
	/**
	 * Its just id but with % applied.
	 */
	public var idMod(get, null):Int;
	inline function get_idMod():Int
		return id % setField.strumCount;

	@:allow(objects.gameplay.ArrowField.new)
	override function new(field:ArrowField, id:Int) {
		setField = field;
		this.id = id;

		super();
		add(this);

		var dir:String = ['Left', 'Down', 'Up', 'Right'][idMod];

		this.loadSheet('gameplay/arrows/noteStrumline');

		animation.addByPrefix('static', 'static$dir', 24, false);
		animation.addByPrefix('press', 'press$dir', 24, false);
		animation.addByPrefix('confirm', 'confirm$dir', 24, false);

		playAnim('static');
		scale.set(0.7);
		updateHitbox();
	}

	/**
	 * Play's an animation.
	 * @param name The animation name.
	 * @param force If true, the game won't care if another one is already playing.
	 * @param reverse If true, the animation will play backwards.
	 * @param frame The starting frame. By default it's 0.
	 * 				Although if reversed it will use the last frame instead.
	 */
	public function playAnim(name:String, force:Bool = true, reverse:Bool = false, frame:Int = 0):Void {
		if (animation.exists(name)) {
			animation.play(name, force, reverse, frame);
			centerOffsets();
			centerOrigin();
		}
	}

	/**
	 * Used to help with `ISelfGroup` updating conflicts.
	 * This will be used to update the sprite itself.
	 * While update now updates the group instead.
	 * @param elapsed Time inbetween frames.
	 */
	public function selfUpdate(elapsed:Float):Void {
		super.update(elapsed);
	}

	/**
	 * Used to help with `ISelfGroup` drawing conflicts.
	 * This will be used to draw the sprite itself.
	 * While draw now draws the group instead.
	 */
	public function selfDraw():Void
		super.draw();

	// ISelfGroup shenanigans!
	/**
	 * The group inside the sprite.
	 */
	public var group(default, null):BeatSpriteGroup = new BeatSpriteGroup();
	/**
	 * Iterates through every member.
	 * @param filter For filtering.
	 * @return `FlxTypedGroupIterator<FlxSprite>` ~ An iterator.
	 */
	public function iterator(?filter:FlxSprite->Bool):FlxTypedGroupIterator<FlxSprite> return group.iterator(filter);

	/**
	 * Adds a new `FlxSprite` to the group.
	 * @param sprite The sprite or sprite group you want to add to the group.
	 * @return `FlxSprite`
	 */
	public function add(sprite:FlxSprite):FlxSprite return group.add(sprite);
	/**
	 * Adds a new `FlxSprite` behind the main member.
	 * @param sprite The sprite or sprite group you want to add to the group.
	 * @return `FlxSprite`
	 */
	public function addBehind(sprite:FlxSprite):FlxSprite return SpriteUtil.addBehind(sprite, this, cast group);
	/**
	 * Inserts a new `FlxSprite` subclass to the group at the specified position.
	 * @param position The position that the new sprite or sprite group should be inserted at.
	 * @param sprite The sprite or sprite group you want to insert into the group.
	 * @return `FlxSprite` ~ The same object that was passed in.
	 */
	public function insert(position:Int, sprite:FlxSprite):FlxSprite return group.insert(position, sprite);
	/**
	 * Removes the specified sprite from the group.
	 * @param sprite The `FlxSprite` you want to remove.
	 * @param splice Whether the object should be cut from the array entirely or not.
	 * @return `FlxSprite` ~ The removed sprite.
	 */
	public function remove(sprite:FlxSprite, splice:Bool = false):FlxSprite return group.remove(sprite, splice);

	override public function update(elapsed:Float):Void
		group.update(elapsed);
	override public function draw():Void
		group.draw();
}