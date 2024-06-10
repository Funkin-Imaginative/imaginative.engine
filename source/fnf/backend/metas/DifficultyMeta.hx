package fnf.backend.metas;

typedef DiffData = {
	var audioVariant:Null<String>;
	var scoreMult:Float;
	@:optional var fps:Float;
}

class DifficultyMeta {
	public static var curDiffData:DiffData; // is set outside of this class

	public var diffName:String;
	public var audioVariant:Null<String> = null;
	public var scoreMult:Float = 1;
	public var spriteFps:Float = 24;

	// for stuff like story menu
	inline public function createSprite():FlxSprite { // wip
		var sprite:FlxSprite = new FlxSprite(0, 0, Paths.image('difficulties/$diffName'));
		if (FileSystem.exists(Paths.xml('images/difficulties/$diffName'))) {
			sprite.frames = Paths.getSparrowAtlas('difficulties/$diffName');
			sprite.animation.addByPrefix('diff', 'diff', spriteFps, true);
			sprite.animation.play('diff', true);
		}
		return sprite;
	}

	public var diffData:DiffData;
	public function new(diffName:String) {
		diffData = ParseUtil.difficulty(this.diffName = diffName);
		audioVariant = diffData.audioVariant;
		scoreMult = diffData.scoreMult;
		spriteFps = diffData.fps == null ? 24 : diffData.fps;
	}
}