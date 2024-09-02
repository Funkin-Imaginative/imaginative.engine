package objects;

import utils.ParseUtil.LevelData;

class LevelObject extends FlxBasic {
	public var data:LevelData;
	public var sprite:FlxSprite;
	public var lock:FlxSprite;

	public var scripts:ScriptGroup;

	public var isLocked(get, never):Bool;
	inline function get_isLocked():Bool {
		var theCall:Dynamic = scripts.call('shouldLock');
		var result:Bool = theCall is Bool ? theCall : true;
		return result;
	}

	public function new(x:Float = 0, y:Float = 0, name:String, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		data = ParseUtil.level(name);
		scripts = new ScriptGroup(this);
		if (allowScripts)
			for (s in ['global', name])
				scripts.add(Script.create(s, LEVEL));
		else
			scripts.add(Script.create(''));
		scripts.load();

		if (loadSprites) {
			sprite = new FlxSprite(x, y, Paths.image('menus/story/levels/$name'));
			sprite.screenCenter(X);
			sprite.antialiasing = true;

			if (isLocked)
				sprite.color = FlxColor.subtract(data.color, FlxColor.fromRGB(100, 100, 100));

			lock = new FlxSprite(Paths.image('ui/lock'));
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

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (sprite != null) sprite.update(elapsed);
		if (isLocked && lock != null) lock.update(elapsed);
	}

	override public function draw() {
		super.draw();
		if (sprite != null) sprite.draw();
		if (isLocked && lock != null) lock.draw();
	}
}