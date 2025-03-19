package imaginative.backend.scripting.events.menus;

final class SongDisplayListEvent extends ScriptEvent {
	/**
	 * States if the level has been played already.
	 */
	public var beatLevel:Bool = false;
	/**
	 * The list of song names to show in the level.
	 */
	public var songs:Array<String> = [];

	override public function new(songs:Array<SongData>, beaten:Bool = false) {
		super();
		this.songs = [for (song in songs) song.name];
		beatLevel = beaten;
	}
}