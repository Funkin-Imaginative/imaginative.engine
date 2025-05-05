package imaginative.objects.holders;

typedef ObjectTyping = {
	/**
	 * Is the object json mod path.
	 */
	var path:String;
	/**
	 * Is the sprite data.
	 */
	var ?object:SpriteData;
	/**
	 * Should the object be flipped?
	 */
	@:default(false) var flip:Bool;
	/**
	 * Position offsets.
	 */
	@:default({x: 0, y: 0}) var offsets:Position;
	/**
	 * Size multiplier.
	 */
	@:default(1) var size:Float;
	/**
	 * Will is play a cheer animation when entering the week?
	 */
	@:default(false) var willHey:Bool;
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef LevelParse = {
	var title:String;
	var songs:Array<String>;
	var ?startingDiff:Int;
	var difficulties:Array<String>;
	var ?variants:Array<String>;
	var objects:Array<ObjectTyping>;
	@:default('#F9CF51') var color:String;
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
	public var startingDiff:Int;
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
class LevelHolder extends BeatSpriteGroup {
	/**
	 * The holder's path type.
	 */
	public var pathType:ModType;

	/**
	 * The level data.
	 */
	public var data:LevelData;
	/**
	 * The actually sprite.
	 */
	public var sprite:BaseSprite;
	/**
	 * The lock sprite.
	 */
	public var lock:FlxSprite;//BaseSprite;

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
		return false;//result;
	}
	/**
	 * Is the holder be hidden?
	 */
	public var isHidden(get, never):Bool;
	inline function get_isHidden():Bool {
		var theCall:Dynamic = scripts.call('shouldHide');
		var result:Bool = theCall is Bool ? theCall : false;
		return result;
	}
	/**
	 * The week character for that week.
	 * This is mostly used for the story menu.
	 */
	public var weekObjects:Array<BeatSprite> = [];

	override public function new(name:ModPath, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		pathType = name.type;
		data = ParseUtil.level(name);
		scripts = new ScriptGroup(this);
		if (allowScripts) {
			var bruh:Array<ModPath> = ['lead:global', name];
			for (level in bruh)
				for (script in Script.create('${level.type}:content/levels/${level.path}'))
					scripts.add(script);
		}
		scripts.load();

		if (loadSprites) {
			sprite = new BaseSprite('$pathType:menus/story/levels/${name.path}');
			add(sprite);

			if (isLocked) {
				sprite.color -= 0xFF646464;

				var mid:Position = Position.getObjMidpoint(sprite);
				lock = new FlxSprite(mid.x, mid.y, Assets.image('ui/lock'));//new BaseSprite(mid.x, mid.y, 'lol/lol');
				lock.x -= lock.width / 2;
				lock.y -= lock.height / 2;
				add(lock);
			}
		}
	}
	override public function destroy():Void {
		scripts.end();
		super.destroy();
	}
}