package objects;

import utils.ParseUtil.SongData;

typedef ObjectTyping = {
	var object:OneOfTwo<String, utils.SpriteUtil.SpriteData>;
	@:optional var flip:Bool;
	@:optional var offsets:PositionStruct;
}

typedef LevelParse = {
	var title:String;
	var songs:Array<String>;
	@:optional var startingDiff:Int;
	var difficulties:Array<String>;
	var objects:Array<ObjectTyping>;
	@:optional var color:String;
}
typedef LevelData = {
	var title:String;
	var songs:Array<SongData>;
	@:optional public var startingDiff:Int;
	var difficulties:Array<String>;
	var objects:Array<ObjectTyping>;
	var color:FlxColor;
}

class LevelObject extends FlxBasic {
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

	public function new(x:Float = 0, y:Float = 0, name:String, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		data = ParseUtil.level(name);
		scripts = new ScriptGroup(this);
		if (allowScripts)
			for (s in ['global', name])
				for (script in Script.create(s, LEVEL))
					scripts.add(script);
		else
			scripts.add(new Script());
		scripts.load();

		if (loadSprites) {
			sprite = new BaseSprite(x, y, 'menus/story/levels/$name');
			sprite.screenCenter(X);
			sprite.antialiasing = true;

			if (isLocked)
				sprite.color = FlxColor.subtract(data.color, FlxColor.fromRGB(100, 100, 100));

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