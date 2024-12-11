package imaginative.states;

import imaginative.states.editors.ChartEditor.ChartData;

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

class SongEvent {
	/**
	 * States if the song event is from the chart.
	 */
	public var fromChart:Bool;

	/**
	 * NOTE: As of rn this is actually in milliseconds!!!!!
	 * The event position in steps.
	 */
	public var time:Float;
	/**
	 * The event code to run.
	 */
	var code:Void->Void;

	inline public function new(time:Float, code:Void->Void, fromChart:Bool = false) {
		this.time = time;
		this.code = code;

		this.fromChart = fromChart;
	}

	/**
	 * Execute's the event code.
	 */
	inline public function execute():Void
		if (code != null)
			code();
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
	 * Direct access to the state instance.
	 */
	public static var direct:PlayState;

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
	public static var chartData:ChartData;
	public var songEvents:Array<SongEvent>;

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
		songDisplay = FunkinUtil.getSongDisplay(setSong = songList[val]);
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
	public static var setSong(default, null):String;

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
	 * The current camera target.
	 */
	public var cameraTarget:String = null;
	/**
	 * The previous camera target.
	 */
	public var prevCameraTarget:String = null;

	// Character variables.
	/**
	 * Contains all existing characters.
	 * `May move to ArrowField.`
	 */
	public var characterMapping:Map<String, Character> = new Map<String, Character>();

	/**
	 * What would be known as the Girlfriend.
	 */
	// public var spectator:Character;

	/**
	 * What would be known as Daddy Dearest.
	 */
	public var enemy(get, set):Character;
	inline function get_enemy():Character
		return enemies[0];
	inline function set_enemy(value:Character):Character
		return enemies[1] = value;
	/**
	 * What would be known as the Boyfriend.
	 */
	public var player(get, set):Character;
	inline function get_player():Character
		return players[0];
	inline function set_player(value:Character):Character
		return players[0] = value;

	/**
	 * All characters from the enemy field.
	 */
	public var enemies(get, set):Array<Character>;
	inline function get_enemies():Array<Character>
		return enemyField.assignedActors;
	inline function set_enemies(value:Array<Character>):Array<Character>
		return enemyField.assignedActors = value;
	/**
	 * All characters from the player field.
	 */
	public var players(get, set):Array<Character>;
	inline function get_players():Array<Character>
		return playerField.assignedActors;
	inline function set_players(value:Array<Character>):Array<Character>
		return playerField.assignedActors = value;

	// ArrowField variables.
	/**
	 * Contains all existing arrow fields.
	 */
	public var arrowFieldMapping:Map<String, ArrowField> = new Map<String, ArrowField>();

	/**
	 * The enemy field.
	 */
	public var enemyField(get, set):ArrowField;
	inline function get_enemyField():ArrowField
		return ArrowField.enemy;
	inline function set_enemyField(value:ArrowField):ArrowField
		return ArrowField.enemy = value;
	/**
	 * The player field.
	 */
	public var playerField(get, set):ArrowField;
	inline function get_playerField():ArrowField
		return ArrowField.player;
	inline function set_playerField(value:ArrowField):ArrowField
		return ArrowField.player = value;

	//temp
	var rating:BaseSprite;

	override public function create():Void {
		scripts = new ScriptGroup(direct = this);

		bgColor = 0xFFBDBDBD;

		camGame = camera; // may make a separate camera class for shiz
		FlxG.cameras.add(camHUD = new FlxCamera(), false);
		camHUD.bgColor = FlxColor.TRANSPARENT;

		rating = new BaseSprite(500, 300, 'gameplay/combo/combo');
		rating.cameras = [camHUD];
		rating.alpha = 0.0001;
		add(rating);

		/* rating.y = camPoint.y - FlxG.camera.height * 0.1 - 60;
		rating.x = FlxMath.bound(
			FlxG.width * 0.55 - 40,
			camPoint.x - FlxG.camera.width / 2 + rating.width,
			camPoint.x + FlxG.camera.width / 2 - rating.width
		); */

		// character creation.
		for (base in chartData.characters) {
			var pos:Position = new Position(
				switch (base.position) {
					case 'enemy': 100;
					case 'player': 770;
					case 'spectator': 400;
					default: 0;
				},
				switch (base.position) {
					case 'enemy': 100;
					case 'player': 100;
					case 'spectator': 130;
					default: 0;
				}
			);
			var character:Character = new Character(pos.x, pos.y, base.name, base.position != 'enemy');
			characterMapping.set(base.tag, character);
			log('Character "${base.tag}" loaded.', DebugMessage);
			add(character);
		}

		if (characterMapping.exists(chartData.fieldSettings.cameraTarget))
			cameraTarget = chartData.fieldSettings.cameraTarget;
		log('Starting camera target is "$cameraTarget".', DebugMessage);

		// arrow field creation
		for (base in chartData.fields) {
			var field:ArrowField = new ArrowField([
				for (tag => char in characterMapping)
					if (base.characters.contains(tag))
						char
			]);
			field.parse(base);
			arrowFieldMapping.set(base.tag, field);
			log('Field "${base.tag}" loaded.', DebugMessage);
			field.cameras = [camHUD];
			field.visible = false;
			add(field);

			inline function characterSing(songPos:Float, actors:Array<Character>, i:Int, context:AnimationContext, force:Bool = true, ?suffix:String):Void {
				for (char in actors) {
					if (char != null) {
						var temp:String = ['LEFT', 'DOWN', 'UP', 'RIGHT'][i];
						char.playAnim('sing$temp', context, suffix);
						char.lastHit = conductor.songPosition;
					}
				}
			}

			/**
			Starting to think of doing these method's.

			```haxe
			scripts.event('pre[____]', event);
			scripts.event('[____]', event);

			if (!event.prevented) {
				// code
			}

			scripts.event('[____]Post', event);
			```

			or

			```haxe
			scripts.event('pre[____]', event);
			if (!event.prevented) {
				scripts.event('[____]', event);
				if (!event.prevented) { // idfk lmao, probably wont do this now that I've written it out lol
					scripts.event('[____]Post', event);
				}
			}
			```
			**/
			field.onNoteHit.add((event) -> {
				scripts.event('preNoteHit', event);
				scripts.event('noteHit', event);

				if (!event.prevented) {
					characterSing(event.field.conductor.songPosition, event.note.renderActors(), event.idMod, IsSinging, event.force, event.suffix);

					// doing it here for now
					if (event.field.isPlayer) {
						rating.loadImage('gameplay/combo/${PlayConfig.calculateRating(Math.abs(event.field.conductor.songPosition - event.note.time), event.field.status == PlayConfig.enemyPlay ? Settings.setupP2 : Settings.setupP1)}');
						FlxTween.cancelTweensOf(rating, ['alpha']);
						rating.alpha = 0.0001;
						FlxTween.tween(rating, {alpha: 1}, (conductor.stepCrochet / 1000) * 1.2, {
							ease: FlxEase.quadIn,
							onComplete: (_:FlxTween) -> {
								FlxTween.tween(rating, {alpha: 0.0001}, (conductor.stepCrochet / 1000) * 2.4 , {
									startDelay: (conductor.stepCrochet / 1000) * 1.5 ,
									ease: FlxEase.expoOut
								});
							}
						});
					}
				}

				scripts.event('noteHitPost', event);
			});
			field.onSustainHit.add((event) -> {
				scripts.event('preSustainHit', event);
				scripts.event('sustainHit', event);

				if (!event.prevented) {
					characterSing(event.field.conductor.songPosition, event.sustain.renderActors(), event.idMod, IsSinging, event.force, event.suffix);
				}

				scripts.event('sustainHitPost', event);
			});
			field.onNoteMissed.add((event) -> {
				scripts.event('preNoteMissed', event);
				scripts.event('noteMissed', event);

				if (!event.prevented) {
					characterSing(event.field.conductor.songPosition, event.note.renderActors(), event.idMod, HasMissed, event.force, event.suffix);
				}

				scripts.event('noteMissedPost', event);
			});
			field.onSustainMissed.add((event) -> {
				scripts.event('preSustainMissed', event);
				scripts.event('sustainMissed', event);

				if (!event.prevented) {
					characterSing(event.field.conductor.songPosition, event.sustain.renderActors(), event.idMod, HasMissed, event.force, event.suffix);
				}

				scripts.event('sustainMissedPost', event);
			});
			field.onVoidMiss.add((event) -> {
				scripts.event('preVoidMiss', event);
				scripts.event('voidMiss', event);

				if (!event.prevented) {
					if (event.triggerMiss) {
						if (!event.stopMissAnimation)
							characterSing(event.field.conductor.songPosition, event.field.assignedActors, event.idMod, HasMissed, event.force, event.suffix);
					}
				}

				scripts.event('voidMissPost', event);
			});
			field.userInput.add((event) -> {
				scripts.event('preFieldInput', event);
				scripts.event('fieldInput', event);
				scripts.event('fieldInputPost', event);
			});
		}

		// arrow field setup
		for (order in chartData.fieldSettings.order) {
			var fields:Array<ArrowField> = [
				for (tag => field in arrowFieldMapping)
					if (order.contains(tag))
						field
			];
			// TODO: @Zyflx said to tweak the y position, do it after HUD visuals are finalized.
			for (i => field in fields) {
				// TODO: Get ArrowField positioning working!
				field.y = (FlxG.height / 2) - ((FlxG.height / 2.6) * (Settings.setupP1.downscroll ? -1 : 1));
				field.x = (FlxG.width / 2) - (field.strums.width / 2);
				field.x += field.strums.width * i;
				field.x -= (field.strums.width * ((fields.length - 1) / 2));
				field.visible = true;
			}
		}

		if (arrowFieldMapping.exists(chartData.fieldSettings.enemy))
			ArrowField.enemy = arrowFieldMapping.get(chartData.fieldSettings.enemy);
		if (arrowFieldMapping.exists(chartData.fieldSettings.player))
			ArrowField.player = arrowFieldMapping.get(chartData.fieldSettings.player);

		// position system doesn't work yet, so for now there being put on screen like this
		enemyField.setPosition((FlxG.width / 2) - (FlxG.width / 4), (FlxG.height / 2) - ((FlxG.height / 2.6) * (Settings.setupP2.downscroll ? -1 : 1)));
		playerField.setPosition((FlxG.width / 2) + (FlxG.width / 4), (FlxG.height / 2) - ((FlxG.height / 2.6) * (Settings.setupP1.downscroll ? -1 : 1)));
		enemyField.visible = playerField.visible = true;

		countdownAssets = {
			images: getCountdownAssetList(null, [null, 'ready', 'set', 'go']),
			sounds: getCountdownAssetList(null, ['three', 'two', 'one', 'go'], 'gf')
		}

		camPoint = new FlxObject(0, 0, 1, 1);
		camGame.follow(camPoint, LOCKON, 0.05);
		add(camPoint);

		super.create();

		for (folder in ['content/songs', 'content/songs/$setSong/scripts']) {
			for (ext in Script.exts) {
				for (file in Paths.readFolder(folder, ext)) {
					for (script in Script.create(file)) {
						scripts.add(script);
					}
				}
			}
		}

		scripts.load();
		scripts.call('create');

		conductor.loadSong(setSong, variant, (_:FlxSound) -> {
			conductor.addVocalTrack(setSong, '', variant);
			conductor.addVocalTrack(setSong, 'Enemy', variant);
			conductor.addVocalTrack(setSong, 'Player', variant);

			var assets:CountdownAssets = {
				images: countdownAssets.images.copy(),
				sounds: countdownAssets.sounds.copy()
			}
			assets.images.reverse();
			assets.sounds.reverse();

			countdownStarted = true;
			FlxTween.num(
				(-crochet * (countdownLength + 1)) + conductor.posOffset,
				conductor.posOffset,
				((crochet * (countdownLength + 1)) + conductor.posOffset) / 1000,
				(output:Float) -> songPosition = output
			);
			countdownTimer.start(crochet / 1000, (timer:FlxTimer) -> {
				/* new FlxTimer().start(stepCrochet / 1000, (_:FlxTimer) -> {
					conductor.stepHit(Math.floor(-(timer.loopsLeft * stepsPerBeat)));
					if (curStep % stepsPerBeat == 0)
						conductor.beatHit(-timer.loopsLeft);
					if (curBeat % beatsPerMeasure == 0)
						conductor.measureHit(Math.floor(-(timer.loopsLeft / beatsPerMeasure)));
				}, stepsPerBeat); */

				conductor.beatHit(-timer.loopsLeft);

				var assetIndex:Int = timer.loopsLeft - 1;
				var soundAsset:ModPath = assets.sounds[assetIndex];
				var imageAsset:ModPath = assets.images[assetIndex];
				if (Paths.fileExists(Paths.sound(soundAsset)))
					FlxG.sound.play(Paths.sound(soundAsset).format());
				if (Paths.fileExists(Paths.image(imageAsset))) {
					var sprite:FlxSprite = new FlxSprite().loadTexture(imageAsset);
					sprite.cameras = [camHUD];
					sprite.screenCenter();
					add(sprite);

					FlxTween.tween(sprite, {alpha: 0}, crochet / 1.2 / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: (_:FlxTween) ->
							sprite.destroy()
					});
				}

				if (timer.loopsLeft == 0) {
					conductor.play();
					songStarted = true;
					conductor._onComplete = () -> {
						for (char in characterMapping) {
							if (char.animContext == IsSinging || char.animContext == HasMissed) {
								char.tryDance(true);
								char.finishAnim();
							}
						}
						scripts.call('onSongEnd');
					}
				}
			}, countdownLength + 1);
		});

		camPoint.setPosition(characterMapping.get(cameraTarget).getCamPos().x, characterMapping.get(cameraTarget).getCamPos().y);
		camGame.snapToTarget();
		camGame.zoom = 0.9;
	}

	override public function createPost():Void {
		super.createPost();
		scripts.call('createPost');
	}

	override public function update(elapsed:Float):Void {
		scripts.call('update', [elapsed]);
		super.update(elapsed);
		scripts.call('updatePost', [elapsed]);
	}

	override public function stepHit(curStep:Int):Void {
		super.stepHit(curStep);
		scripts.call('stepHit', [curStep]);
	}
	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		scripts.call('beatHit', [curBeat]);
	}
	override public function measureHit(curMeasure:Int):Void {
		super.measureHit(curMeasure);
		scripts.call('measureHit', [curMeasure]);
	}

	override public function draw():Void {
		var event:ScriptEvent = scripts.event('draw', new ScriptEvent());
		if (!event.prevented) super.draw();
		scripts.event('drawPost', event);
	}

	override public function onFocus():Void {
		scripts.call('onFocus');
		super.onFocus();
	}
	override public function onFocusLost():Void {
		scripts.call('onFocusLost');
		super.onFocusLost();
	}

	override public function destroy():Void {
		scripts.end();
		direct = null;
		super.destroy();
	}

	/**
	 * Loads a level the next time you enter PlayState.
	 * @param level The level information.
	 * @param difficulty The difficulty name.
	 * @param variant The song variant.
	 */
	inline public static function renderLevel(level:LevelData, difficulty:String, variant:String = 'normal'):Void {
		levelData = level;
		songList = [for (song in levelData.songs) song.folder];
		storyIndex = 0;
		storyMode = true;
		PlayConfig.enemyPlay = PlayConfig.enableP2 = false;
		renderChart(songList[0], difficulty, variant);
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
	inline public static function renderSong(song:String = 'Test', difficulty:String, variant:String = 'normal', playAsEnemy:Bool = false, p2AsEnemy:Bool = false):Void {
		storyMode = false;
		PlayConfig.enemyPlay = playAsEnemy;
		PlayConfig.enableP2 = p2AsEnemy;
		renderChart(song, difficulty, variant);
		log('Rendering song "$song" under difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}"${variant == 'normal' ? '.' : ' in variant "$variant".'}', SystemMessage);
	}

	/**
	 * Loads set song info without screwing over the current playing song.
	 * @param song The song **folder** name.
	 * @param difficulty The difficulty name.
	 * @param variant The song variant.
	 */
	inline public static function renderChart(song:String = 'Test', difficulty:String = 'normal', variant:String = 'normal'):Void {
		// chart parsing
		var loadedChart:String = song;
		var diff:String = difficulty;
		var varia:String = variant;
		chartData = ParseUtil.chart(loadedChart, diff, varia) ?? ParseUtil.chart(loadedChart = 'Test', diff = 'normal', varia = 'normal') ?? {
			speed: 2.6,
			stage: 'void',
			fields: [
				{
					tag: 'field',
					characters: ['bf'],
					notes: [
						{
							id: 0,
							length: 6000,
							time: 8000,
							characters: ['bf'],
							type: ''
						}
					]
				}
			],
			characters: [
				{
					tag: 'bf',
					name: 'boyfriend',
					position: ''
				}
			],
			fieldSettings: {
				cameraTarget: 'bf',
				order: ['field'],
				enemy: loadedChart = diff = varia = 'null',
				player: 'field'
			}
		}
		log('Song "$loadedChart" loaded.', DebugMessage);
		PlayState.difficulty = diff;
		PlayState.variant = varia;
	}
}