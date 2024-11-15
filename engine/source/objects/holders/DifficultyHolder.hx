package objects.holders;

typedef DifficultyData = {
	/**
	 * The difficulty display name.
	 */
	@:default(null) var display:String;
	/**
	 * The variant key.
	 */
	@:default('normal') var variant:String;
	/**
	 *  The score multiplier.
	 */
	@:default(1) var scoreMult:Float;
}

/**
 * The difficulty sprite.
 * This is mostly used for the story menu.
 */
class DifficultyHolder extends FlxBasic {
	/**
	 * The difficulty data.
	 */
	public var data:DifficultyData;
	/**
	 * The actaully sprite.
	 */
	public var sprite:BaseSprite;
	/**
	 * The lock sprite.
	 */
	public var lock:BaseSprite;

	/**
	 * The scripts attached to this holder.
	 */
	public var scripts:ScriptGroup;

	/**
	 * The difficulty key.
	 */
	public var name:String;
	/**
	 * Is the difficulty locked?
	 */
	public var isLocked:Bool = false;

	public function new(x:Float = 0, y:Float = 0, diff:String, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		data = ParseUtil.difficulty(name = diff.toLowerCase());
		scripts = new ScriptGroup(this);
		if (allowScripts)
			for (diff in ['lead:global', name])
				for (script in Script.create('content/difficulties/$diff'))
					scripts.add(script);

		scripts.load();

		if (loadSprites) {
			sprite = new BaseSprite(x, y, 'ui/difficulties/$name');
			if (Paths.spriteSheetExists('ui/difficulties/$name'))
				sprite.animation.addByPrefix('idle', 'idle', 24);
			else sprite.animation.add('idle', [0], 24, false);
			refreshAnim();

			if (isLocked)
				sprite.color -= 0xFF646464;

			lock = new BaseSprite('ui/lock');
			updateLock();
		}
	}

	/**
	 * Refreshes the animation.
	 */
	inline public function refreshAnim():Void {
		sprite.animation.play('idle', true);
		sprite.centerOffsets();
		sprite.centerOrigin();
	}

	/**
	 * Updates the lock position.
	 */
	public function updateLock():Void {
		if (sprite == null || lock == null) return;
		lock.scale.copyFrom(sprite.scale);
		lock.updateHitbox();
		var mid:Position = Position.getObjMidpoint(sprite);
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

	override public function destroy():Void {
		scripts.end();
		super.destroy();
	}
}