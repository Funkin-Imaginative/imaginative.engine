package imaginative.objects.holders;

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
class DifficultyHolder extends BeatSpriteGroup {
	/**
	 * The difficulty data.
	 */
	public var data:DifficultyData;
	/**
	 * The actually sprite.
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

	override public function new(x:Float = 0, y:Float = 0, diff:String, loadSprites:Bool = false, allowScripts:Bool = true) {
		super(x, y);

		data = ParseUtil.difficulty(name = diff.toLowerCase());
		scripts = new ScriptGroup(this);
		if (allowScripts)
			for (diff in ['lead:global', name])
				for (script in Script.create('content/difficulties/$diff'))
					scripts.add(script);

		scripts.load();

		if (loadSprites) {
			sprite = new BaseSprite('ui/difficulties/$name');
			if (Paths.spriteSheetExists('ui/difficulties/$name'))
				sprite.animation.addByPrefix('idle', 'idle', 24);
			else sprite.animation.add('idle', [0], 24, false);
			sprite.anims.set('idle', {offset: new Position(0, 0), swapName: '', flipName: '', extra: new Map<String, Dynamic>()});
			refreshAnim();
			add(sprite);

			if (isLocked) {
				sprite.color -= 0xFF646464;

				var mid:Position = Position.getObjMidpoint(sprite);
				lock = new BaseSprite(mid.x, mid.y, 'ui/lock');
				lock.x -= lock.width / 2;
				lock.y -= lock.height / 2;
				add(lock);
			}
		}
	}

	/**
	 * Refreshes the animation.
	 */
	inline public function refreshAnim():Void {
		if (sprite == null) return;
		sprite.playAnim('idle', true);
		sprite.centerOffsets();
		sprite.centerOrigin();
	}

	override public function destroy():Void {
		scripts.end();
		super.destroy();
	}
}