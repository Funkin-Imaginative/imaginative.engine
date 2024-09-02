package states;

class PlayState extends BeatState {
	override public function get_conductor():Conductor
		return Conductor.song;
	override public function set_conductor(value:Conductor):Conductor
		return Conductor.song;

	public static function loadLevel(level:utils.ParseUtil.LevelData, difficulty:String, variant:String = null):Void {
		//
	}

	public static function loadSong(song:String, difficulty:String, variant:String = null, playAsEnemy:Bool = false, p2AsEnemy:Bool = false):Void {
		//
	}
}