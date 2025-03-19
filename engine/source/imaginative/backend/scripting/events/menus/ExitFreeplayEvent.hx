package imaginative.backend.scripting.events.menus;

final class ExitFreeplayEvent extends MenuSFXEvent {
	/**
	 * If true, it continues playing the menu music instead of leaving freeplay.
	 */
	public var stopSongAudio:Bool;

	override public function new(stopSongAudio:Bool) {
		super();
		this.stopSongAudio = stopSongAudio;
	}
}