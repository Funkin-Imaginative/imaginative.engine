package objects;

import utils.ParseUtil.DifficultyData;

class DifficultyObject extends FlxBasic {
	public var data:DifficultyData;
	public var sprite:FlxSprite;

	public var scripts:ScriptGroup;

	public var name:String;

	public function new(x:Float = 0, y:Float = 0, diff:String) {
		super();

		data = ParseUtil.difficulty(name = diff.toLowerCase());
		scripts = new ScriptGroup(this);
		for (s in ['global', name]) {
			var script:Script = Script.create(s, DIFFICULTY);
			scripts.add(script);
		}
		scripts.load();

		sprite = new FlxSprite(x, y);
		if (FileSystem.exists(Paths.xml('images/ui/difficulties/$name'))) {
			sprite.frames = Paths.frames('ui/difficulties/$name');
			sprite.animation.addByPrefix('idle', 'idle', 24);
		} else {
			sprite.loadGraphic(Paths.image('ui/difficulties/$name'));
			sprite.loadGraphic(Paths.image('ui/difficulties/$name'), true, Math.floor(sprite.width), Math.floor(sprite.height));
			sprite.animation.add('idle', [0], 24, false);
		}

		sprite.antialiasing = true;
		sprite.scale.set(0.85, 0.85);
		sprite.updateHitbox();

		sprite.animation.play('idle', true);
		sprite.centerOffsets();
		sprite.centerOrigin();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		sprite.update(elapsed);
	}

	override public function draw() {
		super.draw();
		sprite.draw();
	}
}