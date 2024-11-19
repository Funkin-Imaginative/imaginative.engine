package states;

typedef CountdownAssets = {
	/**
	 * Countdown images.
	 */
	var images:Array<ModPath>;
	/**
	 * Countdown sounds.
	 */
	var sounds:Array<ModPath>;
}

/**
 * Where all the funny beep boops happen!
 */
class PlayState extends BeatState {
	override public function get_conductor():Conductor {
		return (countdownStarted || !songEnded) ? Conductor.song : Conductor.menu;
	}
	override public function set_conductor(value:Conductor):Conductor {
		return (countdownStarted || !songEnded) ? Conductor.song : Conductor.menu;
	}

	/**
	 * The amount of beats the countdown lasts for.
	 */
	public var countdownLength(default, set):Int = 4;
	inline function set_countdownLength(value:Int):Int
		return countdownLength = value < 1 ? 1 : value;
	/**
	 * The variable that says how far in the countdown is.
	 */
	public var countdownTimer:FlxTimer = new FlxTimer();
	/**
	 * The assets what will be used in the countdown.
	 */
	public var countdownAssets:CountdownAssets;
	/**
	 * Set's up the listings for the countdownAssets variable.
	 * @param root The path to the assets.
	 * @param parts List of assets to get from root var path.
	 * @param suffix Adds a suffix to each item of the parts array.
	 * @return `Array<ModPath>`
	 */
	inline public function getCountdownAssetList(?root:ModPath, parts:Array<String>, suffix:String = ''):Array<ModPath> {
		if (root == null)
			root = 'gameplay/countdown/';
		return [
			for (part in parts)
				part == null ? null : '${root.type}:${FilePath.addTrailingSlash(root.path)}$part${suffix.trim() == '' ? '' : '-$suffix'}'
		];
	}

	/**
	 * States if the countdown has started.
	 */
	public var countdownStarted:Bool = false;
	/**
	 * States if the song has started.
	 */
	public var songStarted:Bool = false;
	/**
	 * States if the song has ended.
	 */
	public var songEnded:Bool = false;

	/**
	 * It true, your score will save.
	 */
	public var saveScore:Bool = true;

	/**
	 * The chart information.
	 */
	public static var chartData:Dynamic;
	/**
	 * Contains all events obtained from the `chartData`.
	 */
	public var chartEvents:Array<Dynamic> = [];
	// public var stepEvents:Map<Float, Void->Void> = new Map<Float, Void->Void>();

	/**
	 * Contains the week information.
	 */
	public static var levelData(default, null):LevelData;
	/**
	 * The current song your doing in story mode.
	 */
	public static var storyIndex(default, set):Int = 0;
	inline static function set_storyIndex(value:Int):Int {
		var val:Int = storyIndex = FlxMath.wrap(value, 0, songList.length - 1);
		songDisplay = FunkinUtil.getSongDisplay(curSong = songList[val]);
		return val;
	}
	/**
	 * If true, your in story mode.
	 * If false, your playing the song by choice.
	 */
	public static var storyMode(default, null):Bool = false;
	/**
	 * List of songs that will play in story mode.
	 */
	public static var songList(default, null):Array<String> = ['Test'];

	/**
	 * The display name of the current song.
	 */
	public static var songDisplay(default, null):String;
	/**
	 * The folder name of the current song.
	 */
	public static var curSong(default, null):String;

	/**
	 * The difficulty key of the current song.
	 */
	public static var difficulty(default, null):String = 'normal';
	/**
	 * The variant key of the current song.
	 */
	public static var variant(default, null):String = 'normal';

	/**
	 * If true, the player character can die upon losing all their health.
	 */
	public var canPlayerDie:Bool = !PlayConfig.enemyPlay && !PlayConfig.enableP2;
	/**
	 * If true, the enemy character can die upon losing all their health.
	 */
	public var canEnemyDie:Bool = PlayConfig.enemyPlay && !PlayConfig.enableP2;

	/**
	 * Scripts for the funny softcoding bullshit.
	 */
	public var scripts:ScriptGroup;

	/**
	 * The main camera, all characters and stage elements will be shown here.
	 */
	public var camGame:FlxCamera;
	/**
	 * The HUD camera, all ui elements will be shown here.
	 */
	public var camHUD:FlxCamera;

	/**
	 * The current camera position.
	 */
	public var camPoint:FlxObject;

	/**
	 * What would be known as the Girlfriend.
	 */
	public var spectator:Character;
	/**
	 * What would be known as Daddy Dearest.
	 */
	public var enemy:Character;
	/**
	 * What would be known as the Boyfriend.
	 */
	public var player:Character;

	/**
	 * The enemy field.
	 */
	public var enemyField:ArrowField;
	/**
	 * The player field.
	 */
	public var playerField:ArrowField;

	override function create():Void {
		scripts = new ScriptGroup(this);

		bgColor = 0xFFBDBDBD;

		camGame = camera; // may make a separate camera class for shiz
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor = FlxColor.TRANSPARENT;

		// if (chartData == null)
		// 	chartData = blah;

		countdownAssets = {
			images: getCountdownAssetList(null, [null, 'ready', 'set', 'go']),
			sounds: getCountdownAssetList(null, ['three', 'two', 'one', 'go'], 'gf')
		}

		enemyField = new ArrowField((FlxG.width / 2) - (FlxG.width / 4), (FlxG.height / 2) - (FlxG.height / 2.3));
		playerField = new ArrowField((FlxG.width / 2) + (FlxG.width / 4), (FlxG.height / 2) - (FlxG.height / 2.3));
		enemyField.cameras = playerField.cameras = [camHUD];
		add(ArrowField.enemy = enemyField);
		add(ArrowField.player = playerField);

		camPoint = new FlxObject(0, 0, 1, 1);
		camGame.follow(camPoint, LOCKON, 0.05);
		add(camPoint);

		super.create();

		for (folder in ['content/songs', 'content/songs/$curSong/scripts']) {
			for (ext in Script.exts) {
				for (file in Paths.readFolder(folder, ext)) {
					for (script in Script.create(file)) {
						scripts.add(script);
					}
				}
			}
		}

		scripts.set('chartData', chartData);
		scripts.load();
		scripts.call('create');

		conductor.loadSong(curSong, variant, (_:FlxSound) -> {
			conductor.addVocalTrack(curSong, '', variant);
			conductor.addVocalTrack(curSong, 'Enemy', variant);
			conductor.addVocalTrack(curSong, 'Player', variant);

			var assets:CountdownAssets = {
				images: countdownAssets.images.copy(),
				sounds: countdownAssets.sounds.copy()
			}
			assets.images.reverse();
			assets.sounds.reverse();

			countdownStarted = true;
			FlxTween.num((-crochet * (countdownLength + 1)) + conductor.posOffset, conductor.posOffset, ((crochet * (countdownLength + 1)) + conductor.posOffset) / 1000, (output:Float) -> songPosition = output);
			countdownTimer.start(crochet / 1000, (timer:FlxTimer) -> {
				/* new FlxTimer().start(stepCrochet / 1000, (_:FlxTimer) -> {
					conductor.stepHit(Math.floor(-(timer.loopsLeft * stepsPerBeat)));
					if (curStep % stepsPerBeat == 0)
						conductor.beatHit(-timer.loopsLeft);
					if (curBeat % beatsPerMeasure == 0)
						conductor.measureHit(Math.floor(-(timer.loopsLeft / beatsPerMeasure)));
				}, stepsPerBeat); */

				conductor.beatHit(-timer.loopsLeft);

				final assetIndex:Int = timer.loopsLeft - 1;
				final soundAsset:ModPath = assets.sounds[assetIndex];
				final imageAsset:ModPath = assets.images[assetIndex];
				if (Paths.fileExists(Paths.sound(soundAsset)))
					FlxG.sound.play(Paths.sound(soundAsset).format());
				if (Paths.fileExists(Paths.image(imageAsset))) {
					var sprite:FlxSprite = new FlxSprite().loadTexture(imageAsset);
					sprite.cameras = [camHUD];
					sprite.screenCenter();
					add(sprite);

					FlxTween.tween(sprite, {alpha: 0}, crochet / 1.2 / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: (_:FlxTween) -> sprite.destroy()
					});
				}

				if (timer.loopsLeft == 0) {
					conductor.play();
					songStarted = true;
					conductor._onComplete = () -> scripts.call('onEndSong');
				}
			}, countdownLength + 1);
		});

		add(spectator = new Character(400, 130, 'gf', true));
		add(enemy = new Character(100, 100));
		add(player = new Character(770, 100, true));

		camPoint.setPosition(spectator.getCamPos().x, spectator.getCamPos().y);
		camGame.snapToTarget();
		camGame.zoom = 0.9;
		camPoint.setPosition(player.getCamPos().x, player.getCamPos().y);
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
		if (!event.prevented) super.draw();
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
		scripts.end();
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
		log('Rendering level "${level.name}", rendering songs ${[for (i => song in levelData.songs) (i == (levelData.songs.length - 2) && levelData.songs.length > 1) ? '"${song.name}" and' : '"${song.name}"'].join(', ').replace('and,', 'and')} under difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}"${variant == 'normal' ? '.' : ' in variant "$variant".'}', SystemMessage);
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
		log('Rendering song "$song" under difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}"${variant == 'normal' ? '.' : ' in variant "$variant".'}', SystemMessage);
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