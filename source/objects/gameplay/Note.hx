package objects.gameplay;

/**
 * States what note part it is.
 */
enum abstract NotePart(String) from String to String {
	/**
	 * The head of the note.
	 */
	var NoteHead = 'Head';
	/**
	 * A tail piece of a sustain.
	 */
	var NoteTail = 'Tail';
	/**
	 * The end of a sustain.
	 */
	var NoteEnd = 'End';
}

class Note extends FlxSprite /* implements ISelfGroup */ {
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
	 * The field the note is assigned to.
	 */
	public var setField(default, null):ArrowField;

	// Note specific variables.
	/**
	 * The base overall note width.
	 */
	public static var baseWidth(default, null):Float = 160 * 0.7;

	/**
	 * States what note part it is.
	 */
	public var part(default, null):NotePart;
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

	@:allow(objects.gameplay.ArrowField.parse)
	override function new(field:ArrowField, id:Int, time:Float, part:NotePart = NoteHead) {
		setField = field;
		this.id = id;

		super(-10000, -10000);
		// add(this);
		// group.setPosition(-10000, -10000);

		var col:String = ['purple', 'blue', 'green', 'red'][idMod];

		this.loadTexture('gameplay/notes/NOTE_assets');

		switch (this.part = part) {
			case NoteHead: animation.addByPrefix('note', '${col}0', 24);
			case NoteTail: animation.addByPrefix('note', '$col hold piece', 24);
			case NoteEnd: animation.addByPrefix('note', '$col hold end', 24);
		}

		animation.play('note', true);
		scale.set(0.7);
		updateHitbox();
	}

	// /**
	//  * Used to help with `ISelfGroup` updating conflicts.
	//  * This will be used to update the sprite itself.
	//  * While update now updates the group instead.
	//  * @param elapsed Time inbetween frames.
	//  */
	// public function selfUpdate(elapsed:Float):Void {
	// 	super.update(elapsed);
	// }

	// /**
	//  * Used to help with `ISelfGroup` drawing conflicts.
	//  * This will be used to draw the sprite itself.
	//  * While draw now draws the group instead.
	//  */
	// public function selfDraw():Void
	// 	super.draw();

	// // ISelfGroup shenanigans!
	// /**
	//  * The group inside the sprite.
	//  */
	// public var group(default, null):BeatSpriteGroup = new BeatSpriteGroup();
	// /**
	//  * Iterates through every member.
	//  * @param filter For filtering.
	//  * @return `FlxTypedGroupIterator<FlxSprite>` ~ An iterator.
	//  */
	// public function iterator(?filter:FlxSprite->Bool):FlxTypedGroupIterator<FlxSprite> return group.iterator(filter);

	// /**
	//  * Adds a new `FlxSprite` to the group.
	//  * @param sprite The sprite or sprite group you want to add to the group.
	//  * @return `FlxSprite`
	//  */
	// public function add(sprite:FlxSprite):FlxSprite return group.add(sprite);
	// /**
	//  * Adds a new `FlxSprite` behind the main member.
	//  * @param sprite The sprite or sprite group you want to add to the group.
	//  * @return `FlxSprite`
	//  */
	// public function addBehind(sprite:FlxSprite):FlxSprite return SpriteUtil.addBehind(sprite, this, cast group);
	// /**
	//  * Inserts a new `FlxSprite` subclass to the group at the specified position.
	//  * @param position The position that the new sprite or sprite group should be inserted at.
	//  * @param sprite The sprite or sprite group you want to insert into the group.
	//  * @return `FlxSprite` ~ The same object that was passed in.
	//  */
	// public function insert(position:Int, sprite:FlxSprite):FlxSprite return group.insert(position, sprite);
	// /**
	//  * Removes the specified sprite from the group.
	//  * @param sprite The `FlxSprite` you want to remove.
	//  * @param splice Whether the object should be cut from the array entirely or not.
	//  * @return `FlxSprite` ~ The removed sprite.
	//  */
	// public function remove(sprite:FlxSprite, splice:Bool = false):FlxSprite return group.remove(sprite, splice);

	// override public function update(elapsed:Float):Void
	// 	group.update(elapsed);
	// override public function draw():Void
	// 	group.draw();
}