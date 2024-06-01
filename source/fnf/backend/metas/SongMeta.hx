package fnf.backend.metas;

class SongMeta {
	public var isSolo:Bool;
	public var inMod:String;

	public var song:String;
	public var week:String;
	public var icon:String;
	public var color:FlxColor;

	public var diffs:Array<String>;

	public function new(song:String, week:String, icon:String, color:FlxColor = FlxColor.WHITE) {
		this.song = song;
		this.week = week;
		this.icon = icon;
		this.color = color;
	}

	public function setModType(isSolo:Bool, modName:String) {
		this.isSolo = isSolo;
		inMod = modName;
	}
}