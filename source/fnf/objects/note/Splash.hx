package fnf.objects.note;

import fnf.backend.interfaces.IPlayAnim.AnimType;

class Splash extends FunkinSprite {
	public var note:Note;
	public var killTimer:FlxTimer = new FlxTimer();

	public function new(?note:Note) {super(); if (note != null) setupSplash(note);}

	public function setupSplash(note:Note):Splash {
		this.note = note;

		frames = Paths.getSparrowAtlas('gameplay/splashes/noteSplashes');
		var set:Int = FlxG.random.int(1, 2);
		var offsets:Array<Array<Float>> = [
			[-46, -20],
			[-33, -14]
		];
		addAnimation('splash', 'note impact $set ${['purple', 'blue', 'green', 'red'][note.data]}', [], 24 + FlxG.random.float(-2, 2));
		setupAnim('splash', offsets[set - 1][0], offsets[set - 1][1]);

		animation.finishCallback = (name:String) -> {
			switch (name) {
				case 'splash': kill();
			}
		}

		setPosition(note.parentStrum.x, note.parentStrum.y);
		playAnim('splash', true);

		return this;
	}

	override function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		super.playAnim(name, force, animType, reverse, frame);
		if (getAnimName() == null && !killTimer.active) killTimer.start(0.3, (timer:FlxTimer) -> kill());
	}
}
