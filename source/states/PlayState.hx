package states;

import objects.LevelObject.LevelData;

class PlayState extends BeatState {
	override public function get_conductor():Conductor
		return Conductor.song;
	override public function set_conductor(value:Conductor):Conductor
		return Conductor.song;

	public var saveScore:Bool = true;

	public static var songChart:Dynamic;

	public static var levelData:LevelData;
	public static var storyMode:Bool = false;
	public static var songList:Array<String> = [];

	public static var difficulty:String = 'normal';
	public static var variant:String = 'normal';

	public var canPlayerDie:Bool = !PlayConfig.enemyPlay && !PlayConfig.enableP2;
	public var canEnemyDie:Bool = PlayConfig.enemyPlay && !PlayConfig.enableP2;

	/**
	 * Loads a level the next time you enter PlayState.
	 * @param level The level information.
	 * @param difficulty The difficulty name.
	 * @param variant The song variant.
	 */
	public static function renderLevel(level:LevelData, difficulty:String, variant:String = 'normal'):Void {
		levelData = level;
		songList = [for (s in levelData.songs) s.folder];
		storyMode = true;
		PlayConfig.enemyPlay = PlayConfig.enableP2 = false;
		_renderSong(songList[0], difficulty, variant);
		trace('Rendering level "${level.title}", songs are "${[for (song in levelData.songs) song.name].join('", "')}" at difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}" in variant "$variant"!');
	}

	/**
	 * Loads a song the next time you enter PlayState.
	 * @param song The song **folder** name.
	 * @param difficulty The difficulty name.
	 * @param variant The song variant.
	 * @param playAsEnemy Should the player be the enemy instead?
	 * @param p2AsEnemy Should the enemy be another player?
	 */
	public static function renderSong(song:String = 'test', difficulty:String = 'normal', variant:String = 'normal', playAsEnemy:Bool = false, p2AsEnemy:Bool = false):Void {
		storyMode = false;
		PlayConfig.enemyPlay = playAsEnemy;
		PlayConfig.enableP2 = p2AsEnemy;
		_renderSong(song, difficulty, variant);
		trace('Rendering song "$song" at difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}" in variant "$variant"!');
	}

	/**
	 * Loads set song info without screwing over the current playing song.
	 * @param song The song **folder** name.
	 * @param difficulty The difficulty name.
	 * @param variant The song variant.
	 */
	public static function _renderSong(song:String = 'test', difficulty:String = 'normal', variant:String = 'normal'):Void {
		PlayState.difficulty = difficulty;
		PlayState.variant = variant;
		//songChart = blah;
	}
}