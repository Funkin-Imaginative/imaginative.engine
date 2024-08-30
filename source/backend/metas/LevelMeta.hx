package backend.metas;

import utils.ParseUtil.LevelData;

class LevelMeta extends FlxBasic {
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

	public function new(x:Float = 0, y:Float = 0, name:String, loadSprites:Bool = false) {
		super();

		data = ParseUtil.level(name);
		scripts = new ScriptGroup(this);
		for (s in ['global', name]) {
			var script:Script = Script.create(s, LEVEL);
			scripts.add(script);
		}
		scripts.load();

		if (loadSprites) {
			sprite = new FlxSprite(x, y, Paths.image('menus/story/levels/$name'));
			sprite.screenCenter(X);
			sprite.antialiasing = true;

			if (isLocked)
				sprite.color = FlxColor.subtract(data.color, FlxColor.fromRGB(100, 100, 100));

			lock = new FlxSprite(Paths.image('ui/lock'));
			lock.antialiasing = true;
			updateLockPosition();
		}
	}

	public function updateLockPosition():Void {
		if (sprite == null || lock == null) return;
		var mid:FlxPoint = sprite.getMidpoint();
		lock.setPosition(mid.x, mid.y);
		lock.x -= lock.width / 2;
		lock.y -= lock.height / 2;
		mid.put();
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