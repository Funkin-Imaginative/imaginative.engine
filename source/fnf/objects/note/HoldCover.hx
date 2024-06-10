package fnf.objects.note;

class HoldCover extends FlxSprite {
	public var note:Note;
	public var endTimer:FlxTimer = new FlxTimer();
	public var killTimer:FlxTimer = new FlxTimer();

	override public function new(?note:Note) {super(); if (note != null) setupCover(note);}

	public function setupCover(note:Note):HoldCover {
		this.note = note;
		note.holdCover = this;

		frames = Paths.getSparrowAtlas('holdCovers');
		var col:String = ['Purple', 'Blue', 'Green', 'Red'][note.data];

		animation.addByPrefix('start', 'holdCoverStart$col', 24, false);
		animation.addByPrefix('hold', 'holdCover$col', 24, true);
		animation.addByPrefix('end', 'holdCoverEnd$col', 24, false);

		animation.finishCallback = (name:String) ->
			switch (name) {
				case 'start': playAnim('hold');
				case 'end': kill();
			}

		playAnim('start');
		var killFunc:Void->Void = () -> if (animation.name == null && !killTimer.active) killTimer.start(0.3, (timer:FlxTimer) -> kill());
		endTimer.start(note.sustainLength / 1000, (timer:FlxTimer) -> {
			playAnim('end');
			killFunc();
		});
		killFunc();
		return this;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (note != null)
			if (animation.name != 'end')
				setPosition(note.parentStrum.x - Note.swagWidth * 0.95, note.parentStrum.y - (Note.swagWidth / 1.15));
	}

	override public function draw() {
		if (note != null && note.parentStrum.cpu) {
			if (animation.name == 'hold')
				super.draw();
		} else super.draw();
	}

	var animCheck:Map<String, HoldCover->Bool> = [
		'start' => (cover:HoldCover) -> return cover.animation.name == null,
		'hold' => (cover:HoldCover) -> return cover.animation.name == 'start' || cover.animation.name == 'hold',
		'end' => (cover:HoldCover) -> return cover.animation.name == 'hold'
	];
	public function playAnim(name:String, force:Bool = false) {
		if (animation.exists(name) && animCheck.exists(name) ? (force ? true : animCheck.get(name)(this)) : true) {
			animation.play(name, true);
		}
	}
}