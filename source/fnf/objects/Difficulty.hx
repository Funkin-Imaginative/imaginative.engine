package fnf.objects;

typedef DiffData = {
	var audioVariant:Null<String>;
	var scoreMult:Float;
	@:optional var fps:Float;
}

class Difficulty extends FlxBasic {
	public static var curDiffData:DiffData; // is set outside of this class
	public static var a:Int;

	public var diffName(default, null):String;
	public var audioVariant(get, never):Null<String>; private function get_audioVariant():Null<String> return diffData.audioVariant;
	public var scoreMult(get, never):Float; private function get_scoreMult():Float return diffData.scoreMult == null ? 1 : diffData.scoreMult;

	public var sprite:FlxSprite; // for stuff like story menu
	public function createSprite():FlxSprite { // wip
		sprite = new FlxSprite(0, 0, Paths.image('difficulties/$diffName'));
		if (FileSystem.exists(Paths.xml('images/difficulties/$diffName'))) {
			sprite.frames = Paths.getSparrowAtlas('difficulties/$diffName');
			sprite.animation.addByPrefix('diff', 'diff', diffData.fps, true);
			sprite.animation.play('diff', true);
		}
		return sprite;
	}

	public var diffData:DiffData;
	override public function new(diffName:String) {
		super();
		diffData = ParseUtil.parseDifficulty(this.diffName = diffName);
	}

	override public function destroy() {
		if (sprite != null) sprite.destroy();
		super.destroy();
	}
}