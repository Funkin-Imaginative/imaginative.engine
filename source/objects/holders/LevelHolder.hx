package objects.holders;

typedef ObjectTyping = {
	var object:OneOfTwo<String, TypeSpriteData>;
	@:optional @:default(false) var flip:Bool;
	@:optional @:default({x: 0, y: 0}) var offsets:PositionStruct;
	@:optional @:default(1) var size:Float;
	@:default(false) var willHey:Bool;
}

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
	var name:String;
	var title:String;
	var songs:Array<SongData>;
	@:optional public var startingDiff:Int;
	var difficulties:Array<String>;
	var variants:Array<String>;
	var objects:Array<ObjectTyping>;
	var color:FlxColor;
}

class LevelHolder extends FlxBasic {
	public var data:LevelData;
	public var sprite:BaseSprite;
	public var lock:BaseSprite;

	public var scripts:ScriptGroup;

	public var isLocked(get, never):Bool;
	inline function get_isLocked():Bool {
		var theCall:Dynamic = scripts.call('shouldLock');
		var result:Bool = theCall is Bool ? theCall : false;
		return result;
	}
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