package objects;

typedef DifficultyData = {
	var display:String;
	@:optional var variant:String;
	@:optional var scoreMult:Float;
}

class DifficultyObject extends FlxBasic {
	public var data:DifficultyData;
	public var sprite:BaseSprite;
	public var lock:BaseSprite;

	public var scripts:ScriptGroup;

	public var name:String;
	public var isLocked:Bool = false;

	public function new(x:Float = 0, y:Float = 0, diff:String, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		data = ParseUtil.difficulty(name = diff.toLowerCase());
		scripts = new ScriptGroup(this);
		if (allowScripts)
			for (s in ['global', name])
				for (script in Script.create(s, DIFFICULTY))
					scripts.add(script);
		else
			scripts.add(new Script());
		scripts.load();

		if (loadSprites) {
			sprite = new BaseSprite(x, y, 'ui/difficulties/$name');
			if (Paths.fileExists('images/ui/difficulties/$name.xml'))
				sprite.animation.addByPrefix('idle', 'idle', 24);
			else sprite.animation.add('idle', [0], 24, false);
			refreshAnim();

			if (isLocked)
				sprite.color = FlxColor.subtract(sprite.color, FlxColor.fromRGB(100, 100, 100));

			lock = new BaseSprite('ui/lock');
			lock.antialiasing = true;
			updateLock();
		}
	}

	inline public function refreshAnim():Void {
		sprite.animation.play('idle', true);
		sprite.centerOffsets();
		sprite.centerOrigin();
	}

	public function updateLock():Void {
		if (sprite == null || lock == null) return;
		lock.scale.copyFrom(sprite.scale);
		lock.updateHitbox();
		var mid:PositionStruct = PositionStruct.getObjMidpoint(sprite);
		lock.setPosition(mid.x, mid.y);
		lock.x -= lock.width / 2;
		lock.y -= lock.height / 2;
		lock.alpha = sprite.alpha;
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