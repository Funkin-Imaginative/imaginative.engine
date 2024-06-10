package fnf.objects.note;

class Splash extends FlxSprite {
	public var note:Note;
	public var killTimer:FlxTimer = new FlxTimer();

	public function new(?note:Note) {super(); if (note != null) setupSplash(note);}

	public function setupSplash(note:Note):Splash {
		this.note = note;

		frames = Paths.getSparrowAtlas('noteSplashes');
		animation.addByPrefix('splash', 'note impact ${FlxG.random.int(1, 2)} ${['purple', 'blue', 'green', 'red'][note.data]}', 24 + FlxG.random.float(-2, 2), false);

		setPosition(note.parentStrum.x, note.parentStrum.y);
		animation.play('splash', true);
		updateHitbox();

		offset.set(width * 0.3, height * 0.3);

		animation.finishCallback = (name:String) ->
			switch (name) {
				case 'splash': kill();
			}

		if (animation.name == null) killTimer.start(0.3, (timer:FlxTimer) -> kill());
		return this;
	}
}
