package backend.scripting.events.menus.story;

final class LevelSongListEvent extends ScriptEvent {
	public var beatLevel:Bool = false;
	public var songs:Array<String> = [];

	override public function new(songs:Array<SongData>, beaten:Bool = false) {
		super();
		this.songs = [for (s in songs) s.name];
		beatLevel = beaten;
	}
}