package fnf.objects.note;

import fnf.backend.interfaces.IPlayAnim.AnimType;

class HoldCover extends FunkinSprite implements IReloadable {
	public var note:Note;
	public var endTimer:FlxTimer = new FlxTimer();
	public var killTimer:FlxTimer = new FlxTimer();

	override public function new(?note:Note) {super(); if (note != null) setupCover(note);}

	override function reload(hard:Bool = false) {
		if (hard && getAnimName() != 'end' && !reloading) {
			FlxTween.tween(this.scale, {x: 0, y: 0}, 2, {
				onStart: (tween:FlxTween) -> reloading = true,
				onComplete: (tween:FlxTween) -> {
					kill();
					reloading = false;
				}
			});
		}
	}

	public function setupCover(note:Note):HoldCover {
		this.note = note;
		note.holdCover = this;

		frames = Paths.getSparrowAtlas('gameplay/holdcovers/holdCovers');
		var col:String = ['Purple', 'Blue', 'Green', 'Red'][note.data];

		addAnimation('start', 'holdCoverStart$col'); setupAnim('start', -122, -125);
		addAnimation('hold', 'holdCover$col', [], 24, true); setupAnim('hold', -97, -105);
		addAnimation('end', 'holdCoverEnd$col'); setupAnim('end', -54, -77);

		animation.finishCallback = (name:String) -> {
			switch (name) {
				case 'start':
					playAnim('hold', true);
					if (getAnimName() == 'start') killTimer.start(0.3, (timer:FlxTimer) -> kill());
				case 'end':
					kill();
			}
		}

		playAnim('start', true);
		endTimer.start(note.sustainLength / 1000, (timer:FlxTimer) -> {
			playAnim('end', true);
		});

		return this;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (note != null)
			if (getAnimName() != 'end')
				setPosition(note.parentStrum.x - Note.swagWidth * 0.95 - 13, note.parentStrum.y - Note.swagWidth - 13);
	}

	override function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		super.playAnim(name, force, animType, reverse, frame);
		if (getAnimName() == null && !killTimer.active) killTimer.start(0.3, (timer:FlxTimer) -> {
			endTimer.cancel();
			kill();
		});
	}

	override public function draw() {
		if (note != null && note.parentStrum.cpu) {
			if (getAnimName() == 'hold')
				super.draw();
		} else super.draw();
	}

	override function kill() {
		endTimer.cancel();
		killTimer.cancel();
		super.kill();
	}
}