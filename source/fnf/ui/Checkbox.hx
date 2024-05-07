package fnf.ui;

class Checkbox extends FlxSprite {
	public var daValue(default, set):Bool;

	public function new(x:Float, y:Float, daValue:Bool = false) {
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);
		antialiasing = true;

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		this.daValue = daValue;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		switch (animation.curAnim.name) {
			case 'static': offset.set();
			case 'checked': offset.set(17, 70);
		}
	}

	private function set_daValue(value:Bool):Bool {
		if (value) animation.play('checked', true);
		else animation.play('static');
		return value;
	}
}