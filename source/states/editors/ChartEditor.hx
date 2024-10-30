package states.editors;

class ChartEditor extends BeatState {
	override public function get_conductor():Conductor
		return Conductor.charter;
	override public function set_conductor(value:Conductor):Conductor
		return Conductor.charter;

	override public function new() {
		super();
		/* conductor.loadSong(song, variant, (_:FlxSound) -> {
			conductor.addVocalTrack(song, '', variant);
			conductor.addVocalTrack(song, 'Enemy', variant);
			conductor.addVocalTrack(song, 'Player', variant);
		}); */
	}
}