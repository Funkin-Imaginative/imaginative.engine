package fnf.backend.metas;

class LevelMeta {
	public var isSolo:Bool;
	public var inMod:String;

	public var name:String;
	public var title:String;
	public var songs:Array<String> = [];
	public var chars:Array<String> = [];
	public var color:FlxColor;

	public var diffs:Array<String> = [];

	public function new(name:String, title:String, songs:Array<String>, chars:Array<String>, color:FlxColor = FlxColor.WHITE) {
		this.title = name;
		this.title = title;
		this.songs = songs;
		this.chars = chars;
		this.color = color;
	}

	public function setModType(isSolo:Bool, modName:String) {
		this.isSolo = isSolo;
		inMod = modName;
	}
}