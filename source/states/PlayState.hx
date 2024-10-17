package states;

class PlayState extends BeatState {
	override public function get_conductor():Conductor
		return Conductor.song;
	override public function set_conductor(value:Conductor):Conductor
		return Conductor.song;

	public var saveScore:Bool = true;

	public static var chartData:Dynamic;
	public var chartEvents:Array<Dynamic> = [];
	// public var stepEvents:Map<Float, Void->Void> = new Map<Float, Void->Void>();

	public static var levelData(default, null):LevelData;
	public static var storyIndex(default, set):Int = 0;
	inline static function set_storyIndex(value:Int):Int {
		var val:Int = storyIndex = FlxMath.wrap(value, 0, songList.length - 1);
		songDisplay = FunkinUtil.getSongDisplay(curSong = songList[val]);
		return val;
	}
	public static var storyMode(default, null):Bool = false;
	public static var songList(default, null):Array<String> = ['Test'];

	public static var songDisplay(default, null):String;
	public static var curSong(default, null):String;

	public static var difficulty(default, null):String = 'normal';
	public static var variant(default, null):String = 'normal';

	public var canPlayerDie:Bool = !PlayConfig.enemyPlay && !PlayConfig.enableP2;
	public var canEnemyDie:Bool = PlayConfig.enemyPlay && !PlayConfig.enableP2;

	public var scripts:ScriptGroup;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	public var camPoint:FlxObject;

	public var spectator:Character;
	public var enemy:BeatSprite;
	public var player:Character;

	override function create():Void {
		scripts = new ScriptGroup(this);

		camGame = camera;
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor = FlxColor.TRANSPARENT;

		// if (chartData == null)
		// 	chartData = blah;

		conductor.loadSong(curSong, variant, (_:FlxSound) -> {
			conductor.addVocalTrack(curSong, '', variant);
			conductor.addVocalTrack(curSong, 'Enemy', variant);
			conductor.addVocalTrack(curSong, 'Player', variant);
			conductor.play();
		});

		camPoint = new FlxObject(0, 0, 1, 1);
		camGame.follow(camPoint, LOCKON, 0.2);
		add(camPoint);

		super.create();

		for (folder in ['content/songs', 'content/songs/$curSong/scripts'])
			for (file in Paths.readFolder(folder))
				if ([for (ext in Script.exts) FilePath.extension(file) == ext].contains(true))
					for (script in Script.create('$folder/${FilePath.withoutExtension(file)}'))
						scripts.add(script);
		scripts.set('chartData', chartData);
		scripts.load();
		scripts.call('create');

		add(spectator = new Character(0, 0, 'gf', true));
		add(enemy = new BeatSprite(-500, 0, 'characters/boyfriend'));
		add(player = new Character(500, 0, true));
		camPoint.setPosition(spectator.getCamPos().x, spectator.getCamPos().y);
		camGame.snapToTarget();
		camGame.zoom = 0.7;
	}

	override function createPost():Void {
		super.createPost();
		scripts.call('createPost');
	}

	override function update(elapsed:Float):Void {
		scripts.call('update', [elapsed]);

		super.update(elapsed);

		scripts.call('updatePost', [elapsed]);
	}

	override function stepHit(curStep:Int):Void {
		super.stepHit(curStep);
		scripts.call('stepHit', [curStep]);
	}

	override function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		scripts.call('beatHit', [curBeat]);
	}

	override function measureHit(curMeasure:Int):Void {
		super.measureHit(curMeasure);
		scripts.call('measureHit', [curMeasure]);
	}

	override function draw():Void {
		var event:ScriptEvent = scripts.event('draw', new ScriptEvent());
		if (!event.stopped) super.draw();
		scripts.event('drawPost', event);
	}

	override function onFocus():Void {
		scripts.call('onFocus');
		super.onFocus();
	}

	override function onFocusLost():Void {
		scripts.call('onFocusLost');
		super.onFocusLost();
	}

	override function destroy():Void {
		if (conductor.audio.playing)
			conductor.reset();
		super.destroy();
	}

	/**
	 * Loads a level the next time you enter PlayState.
	 * @param level The level information.
	 * @param difficulty The difficulty name.
	 * @param variant The song variant.
	 */
	public static function renderLevel(level:LevelData, difficulty:String, variant:String = 'normal'):Void {
		levelData = level;
		songList = [for (song in levelData.songs) song.folder];
		storyIndex = 0;
		storyMode = true;
		PlayConfig.enemyPlay = PlayConfig.enableP2 = false;
		_renderSong(songList[0], difficulty, variant);
		trace('Rendering level "${level.name}", rendering songs "${[for (song in levelData.songs) song.name].join('", "')}" under difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}"${variant == 'normal' ? '.' : ' in variant "$variant".'}');
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
		trace('Rendering song "$song" under difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}"${variant == 'normal' ? '.' : ' in variant "$variant".'}');
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
		//chartData = blah;
	}
}