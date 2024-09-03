package objects;

import utils.ParseUtil.DifficultyData;

class DifficultyObject extends FlxBasic {
	public var data:DifficultyData;
	public var sprite:FlxSprite;
	public var lock:FlxSprite;

	public var scripts:ScriptGroup;

	public var name:String;
	public var isLocked:Bool = true;

	public function new(x:Float = 0, y:Float = 0, diff:String, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		data = ParseUtil.difficulty(name = diff.toLowerCase());
		scripts = new ScriptGroup(this);
		if (allowScripts)
			for (s in ['global', name])
				for (script in Script.create(s, DIFFICULTY))
					scripts.add(script);
		else
			scripts.add(Script.create('', false)[0]);
		scripts.load();

		if (loadSprites) {
			sprite = new FlxSprite(x, y);
			if (Paths.fileExists('images/ui/difficulties/$name.xml')) {
				sprite.frames = Paths.frames('ui/difficulties/$name');
				sprite.animation.addByPrefix('idle', 'idle', 24);
			} else {
				sprite.loadGraphic(Paths.image('ui/difficulties/$name'));
				sprite.loadGraphic(Paths.image('ui/difficulties/$name'), true, Math.floor(sprite.width), Math.floor(sprite.height));
				sprite.animation.add('idle', [0], 24, false);
			}
			refreshAnim();

			if (isLocked)
				sprite.color = FlxColor.subtract(sprite.color, FlxColor.fromRGB(100, 100, 100));

			lock = new FlxSprite(Paths.image('ui/lock'));
			lock.antialiasing = true;
			updateLock();
		}
	}

	inline public function refreshAnim() {
		sprite.animation.play('idle', true);
		sprite.centerOffsets();
		sprite.centerOrigin();
	}

	public function updateLock():Void {
		if (sprite == null || lock == null) return;
		lock.scale.set();
		lock.updateHitbox();
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