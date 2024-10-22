package objects.holders;

typedef ObjectTyping = {
	/**
	 * Is either the object json path or actually sprite data.
	 */
	var object:OneOfTwo<String, TypeSpriteData>;
	/**
	 * Should the object be flipped?
	 */
	@:optional @:default(false) var flip:Bool;
	/**
	 * Posiiton offsets.
	 */
	@:optional @:default({x: 0, y: 0}) var offsets:PositionStruct;
	/**
	 * Size multiplier.
	 */
	@:optional @:default(1) var size:Float;
	/**
	 * Will is play a cheer animation when entering the week?
	 */
	@:default(false) var willHey:Bool;
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef LevelParse = {
	var title:String;
	var songs:Array<String>;
	@:optional var startingDiff:Int;
	var difficulties:Array<String>;
	@:optional var variants:Array<String>;
	var objects:Array<ObjectTyping>;
	@:optional var color:String;
}
typedef LevelData = {
	/**
	 * The display name.
	 */
	var name:String;
	/**
	 * The title.
	 */
	var title:String;
	/**
	 * List of each songs data.
	 */
	var songs:Array<SongData>;
	/**
	 * Starting difficulty index.
	 */
	@:optional public var startingDiff:Int;
	/**
	 * Difficulty listing.
	 */
	var difficulties:Array<String>;
	/**
	 * Variation listing.
	 */
	var variants:Array<String>;
	/**
	 * List of week object data's.
	 * This is mostly used for the story menu.
	 */
	var objects:Array<ObjectTyping>;
	/**
	 * Associated color.
	 */
	var color:FlxColor;
}

/**
 * The level sprite name.
 * This is mostly used for the story menu.
 */
class LevelHolder extends FlxBasic {
	/**
	 * The difficulty data.
	 */
	public var data:LevelData;
	/**
	 * The actaully sprite.
	 */
	public var sprite:BaseSprite;
	/**
	 * The lock sprite.
	 */
	public var lock:BaseSprite;

	/**
	 * The scripts attached to this holder.
	 */
	public var scripts:ScriptGroup;

	/**
	 * Is it locked?
	 */
	public var isLocked(get, never):Bool;
	inline function get_isLocked():Bool {
		var theCall:Dynamic = scripts.call('shouldLock');
		var result:Bool = theCall is Bool ? theCall : false;
		return result;
	}
	/**
	 * The week character for that week.
	 * This is mostly used for the story menu.
	 */
	public var weekObjects:Array<BeatSprite> = [];

	public function new(x:Float = 0, y:Float = 0, name:String, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		data = ParseUtil.level(name);
		scripts = new ScriptGroup(this);
		if (allowScripts)
			for (level in ['global', name])
				for (script in Script.create('content/levels/$level'))
					scripts.add(script);
		scripts.load();

		if (loadSprites) {
			sprite = new BaseSprite(x, y, 'menus/story/levels/$name');
			sprite.screenCenter(X);
			sprite.antialiasing = true;

			if (isLocked)
				sprite.color -= 0xFF646464;

			lock = new BaseSprite('ui/lock');
			lock.antialiasing = true;
			updateLock();
		}
	}

	/**
	 * Updates the lock position.
	 */
	public function updateLock():Void {
		if (sprite == null || lock == null) return;
		var mid:PositionStruct = PositionStruct.getObjMidpoint(sprite);
		lock.setPosition(mid.x, mid.y);
		lock.x -= lock.width / 2;
		lock.y -= lock.height / 2;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (sprite != null) sprite.update(elapsed);
		if (isLocked && lock != null) lock.update(elapsed);
	}

	override public function draw():Void {
		super.draw();
		if (sprite != null) sprite.draw();
		if (isLocked && lock != null) lock.draw();
	}
}