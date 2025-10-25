package imaginative.backend.scripting.events.menus;

final class PreviewSongEvent extends ScriptEvent {
	/**
	 * If true it plays the song preview.
	 */
	public var playPreview:Bool;

	/**
	 * Contains the chart data of the preview song.
	 * Incase people wanna use it.
	 */
	public var chartData:imaginative.states.editors.ChartEditor.ChartData;

	override public function new(playPreview:Bool) {
		super();
		this.playPreview = playPreview;
	}
}