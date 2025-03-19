package imaginative.states;

import imaginative.objects.gameplay.hud.*;
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
		return /* (countdownStarted || !songEnded) ? */ Conductor.song /* : Conductor.menu */;
	}
	override public function set_conductor(value:Conductor):Conductor {
		return /* (countdownStarted || !songEnded) ? */ Conductor.song /* : Conductor.menu */;
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
	 * The variable that tracks the countdown.
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
	 * @return `Array<ModPath>` ~ The mod paths of the items.
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
	 * The general vocal track instance.
	 */
	public var generalVocals:Null<FlxSound>;

	/**
	 * It true, your score will save.
	 */
	public var saveScore:Bool = true;

	/**
	 * The chart information.
	 */
	public static var chartData:ChartData;
	public var songEvents:Array<SongEvent> = [];

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
	public var canPlayerDie:Bool = !ArrowField.enemyPlay && !ArrowField.enableP2;
	/**
	 * If true, the enemy character can die upon losing all their health.
	 */
	public var canEnemyDie:Bool = ArrowField.enemyPlay && !ArrowField.enableP2;

	/**
	 * Scripts for the funny softcoding bullshit.
	 */
	public var scripts:ScriptGroup;
	/**
	 * The HUD itself.
	 */
	public var hud:HUDTemplate;

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

		hud = switch (chartData.hud ??= 'funkin') {
			case 'funkin':
				switch (Settings.setup.HUDSelection) {
					case VSlice: new VSliceHUD();
					case Kade: new KadeHUD();
					case Psych: new PsychHUD();
					case Codename: new CodenameHUD();
					case Imaginative: new ImaginativeHUD();
					default: new ImaginativeHUD(); // lol // new ScriptedHUD(chartData.hud);
				}
			default:
				new ScriptedHUD(chartData.hud);
		}
		hud.cameras = [camHUD];
		add(hud);

		rating = new BaseSprite(500, 300, 'gameplay/combo/combo');
		rating.cameras = [camHUD];
		rating.alpha = 0.0001;
		hud.elements.add(rating);

		/* rating.y = camPoint.y - camHUD.height * 0.1 - 60;
		rating.x = FlxMath.bound(
			camHUD.width * 0.55 - 40,
			camPoint.x - camHUD.width / 2 + rating.width,
			camPoint.x + camHUD.width / 2 - rating.width
		); */

		// character creation.
		var vocalSuffixes:Array<String> = [];
		/**
		 * K: Character Tag, V: Vocal Suffix List.
		 */
		var vocalTargeting:Map<String, Array<String>> = new Map<String, Array<String>>();
		var loadedCharacters:Array<String> = [];
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
			loadedCharacters.push(base.tag);
			add(character);

			var suffix:String = base.vocals ?? character.vocalSuffix ?? base.tag; // since vocalSuffix can be theirName, i'ma just go with this
			if (!vocalSuffixes.contains(suffix))
				vocalSuffixes.push(suffix);
			if (!vocalTargeting.exists(base.tag))
				vocalTargeting.set(base.tag, []);
			vocalTargeting.get(base.tag).push(suffix);
		}
		log('Character${loadedCharacters.length > 1 ? "'s" : ''} ${[for (i => char in loadedCharacters) (i == (loadedCharacters.length - 2) && loadedCharacters.length > 1) ? '"$char" and' : '"$char"'].join(', ').replace('and,', 'and')} loaded.', DebugMessage);

		if (characterMapping.exists(chartData.fieldSettings.cameraTarget))
			cameraTarget = chartData.fieldSettings.cameraTarget;
		log('The beginning camera target is "$cameraTarget".', DebugMessage);

		// arrow field creation
		var loadedFields:Array<String> = [];
		for (base in chartData.fields) {
			var field:ArrowField = new ArrowField([
				for (tag => char in characterMapping)
					if (base.characters.contains(tag))
						char
			]);
			field.parse(base);
			arrowFieldMapping.set(base.tag, field);
			loadedFields.push(base.tag);
			field.scrollSpeed = base.speed;
			field.visible = false;
			hud.fields.add(field);

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
					var actors:Array<Character> = event.note.renderActors();
					ArrowField.characterSing(event.field, actors, event.idMod, IsSinging, event.force, event.suffix);

					for (char in actors)
						for (track in char.assignedTracks)
							track.volume = 1;
					if (generalVocals != null)
						generalVocals.volume = 1;

					if (event.field.status != null)
						hud.health += 0.02 * (event.field.status ? 1 : -1);
					if (event.field.isPlayer) {
						// doing it here for now
						rating.loadImage('gameplay/combo/${Judging.calculateRating(Math.abs(event.field.conductor.time - event.note.time), event.field.settings)}');
						FlxTween.cancelTweensOf(rating, ['alpha']);
						rating.alpha = 0.0001;
						FlxTween.tween(rating, {alpha: 1}, (event.field.conductor.stepTime / 1000) * 1.2, {
							ease: FlxEase.quadIn,
							onComplete: (_:FlxTween) -> {
								FlxTween.tween(rating, {alpha: 0.0001}, (event.field.conductor.stepTime / 1000) * 2.4 , {
									startDelay: (event.field.conductor.stepTime / 1000) * 1.5,
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
					var actors:Array<Character> = event.sustain.renderActors();
					ArrowField.characterSing(event.field, actors, event.idMod, IsSinging, event.force, event.suffix);

					for (char in actors)
						for (track in char.assignedTracks)
							track.volume = 1;
					if (generalVocals != null)
						generalVocals.volume = 1;
				}

				scripts.event('sustainHitPost', event);
			});
			field.onNoteMissed.add((event) -> {
				scripts.event('preNoteMissed', event);
				scripts.event('noteMissed', event);

				if (!event.prevented) {
					var actors:Array<Character> = event.note.renderActors();
					ArrowField.characterSing(event.field, actors, event.idMod, HasMissed, event.force, event.suffix);

					for (char in actors)
						for (track in char.assignedTracks)
							track.volume = 0;
					if (generalVocals != null)
						generalVocals.volume = 0;

					if (event.field.status != null)
						hud.health -= 0.035 * (event.field.status ? 1 : -1);
				}

				scripts.event('noteMissedPost', event);
			});
			field.onSustainMissed.add((event) -> {
				scripts.event('preSustainMissed', event);
				scripts.event('sustainMissed', event);

				if (!event.prevented) {
					var actors:Array<Character> = event.sustain.renderActors();
					ArrowField.characterSing(event.field, actors, event.idMod, HasMissed, event.force, event.suffix);

					for (char in actors)
						for (track in char.assignedTracks)
							track.volume = 0;
					if (generalVocals != null)
						generalVocals.volume = 0;
				}

				scripts.event('sustainMissedPost', event);
			});
			field.onVoidMiss.add((event) -> {
				scripts.event('preVoidMiss', event);
				scripts.event('voidMiss', event);

				if (!event.prevented) {
					if (event.triggerMiss) {
						if (!event.stopMissAnimation)
							ArrowField.characterSing(event.field, event.field.assignedActors, event.idMod, HasMissed, event.force, event.suffix);

						for (char in event.field.assignedActors)
							for (track in char.assignedTracks)
								track.volume = 0;
						if (generalVocals != null)
							generalVocals.volume = 0;
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
		log('Field${loadedFields.length > 1 ? "'s" : ''} ${[for (i => field in loadedFields) (i == (loadedFields.length - 2) && loadedFields.length > 1) ? '"$field" and' : '"$field"'].join(', ').replace('and,', 'and')} loaded.', DebugMessage);

		// arrow field setup
		var fields:Array<ArrowField> = [
			for (tag in chartData.fieldSettings.order)
				if (arrowFieldMapping.exists(tag))
					arrowFieldMapping.get(tag)
		];
		// ArrowField.setupFieldXPositions(fields, camHUD);
		for (field in fields)
			field.y = hud.getFieldYLevel(Settings.setupP1.downscroll, field);

		if (arrowFieldMapping.exists(chartData.fieldSettings.enemy))
			ArrowField.enemy = arrowFieldMapping.get(chartData.fieldSettings.enemy);
		if (arrowFieldMapping.exists(chartData.fieldSettings.player))
			ArrowField.player = arrowFieldMapping.get(chartData.fieldSettings.player);

		// position system doesn't work yet, so for now there being put on screen like this
		enemyField.x = (camHUD.width / 2) - (camHUD.width / 4);
		playerField.x = (camHUD.width / 2) + (camHUD.width / 4);
		enemyField.visible = playerField.visible = true;

		countdownAssets = {
			images: getCountdownAssetList(null, [null, 'ready', 'set', 'go']),
			sounds: getCountdownAssetList(null, ['three', 'two', 'one', 'go'], 'gf')
		}

		camPoint = new FlxObject(0, 0, 1, 1);
		camGame.follow(camPoint, LOCKON, 0.05);
		add(camPoint);

		super.create();

		for (folder in ['content/songs', 'content/songs/$setSong/scripts'])
			for (ext in Script.exts)
				for (file in Paths.readFolder(folder, ext))
					for (script in Script.create(file))
						scripts.add(script);

		scripts.load();
		scripts.call('create');

		// hud.healthBar.setColors(enemy.healthColor, player.healthColor);

		conductor.loadSong(setSong, variant, (_:FlxSound) -> {
			/**
			 * K: Suffix, V: The Track.
			 */
			var tracks:Map<String, FlxSound> = new Map<String, FlxSound>();
			for (suffix in vocalSuffixes) {
				var track:Null<FlxSound> = conductor.addVocalTrack(setSong, suffix, variant);
				if (track != null)
					tracks.set(suffix, track);
			}

			// assigns tracks to characters
			for (charTag => suffixes in vocalTargeting)
				for (suffix in suffixes)
					if (tracks.exists(suffix))
						characterMapping.get(charTag).assignedTracks.push(tracks.get(suffix));

			// loads main suffixes
			if (tracks.empty()) {
				var enemyTrack:Null<FlxSound> = conductor.addVocalTrack(setSong, 'Enemy', variant);
				if (enemyTrack != null)
					enemy.assignedTracks.push(enemyTrack);

				var playerTrack:Null<FlxSound> = conductor.addVocalTrack(setSong, 'Player', variant);
				if (playerTrack != null)
					player.assignedTracks.push(playerTrack);
			}

			// loads general track
			if (tracks.empty()) {
				var generalTrack:Null<FlxSound> = conductor.addVocalTrack(setSong, '', variant);
				if (generalTrack != null)
					generalVocals = generalTrack;
			}

			conductor._onComplete = (event) -> {
				for (char in characterMapping)
					if (char.animContext == IsSinging || char.animContext == HasMissed)
						char.dance();

				for (field in arrowFieldMapping)
					for (strum in field.strums)
						if (strum.willReset)
							strum.playAnim('static');

				scripts.event('onSongEnd', event);
				songEnded = true;
				if (!event.prevented)
					endSong();
			}

			startSong();
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

		while (songEvents.length > 0 && songEvents.last().time <= time) {
			var poppedEvent:SongEvent = songEvents.pop();
			if (poppedEvent != null)
				poppedEvent.execute();
		}

		scripts.call('updatePost', [elapsed]);
	}

	function startSong():Void {
		var assets:CountdownAssets = {
			images: countdownAssets.images.copy(),
			sounds: countdownAssets.sounds.copy()
		}
		assets.images.reverse();
		assets.sounds.reverse();

		countdownStarted = true;
		if (countdownLength >= 1) {
			countdownTimer.start(beatTime / 1000, (timer:FlxTimer) -> {
				var assetIndex:Int = timer.loopsLeft - 1;

				var soundAsset:ModPath = assets.sounds[assetIndex];
				if (Paths.fileExists(Paths.sound(soundAsset)))
					FlxG.sound.play(Paths.sound(soundAsset));

				var imageAsset:ModPath = assets.images[assetIndex];
				if (Paths.fileExists(Paths.image(imageAsset))) {
					var sprite:FlxSprite = new FlxSprite().loadTexture(imageAsset);
					sprite.cameras = [camHUD];
					sprite.screenCenter();
					add(sprite);

					FlxTween.tween(sprite, {alpha: 0}, beatTime / 1.2 / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: (_:FlxTween) ->
							sprite.destroy()
					});
				}

				if (timer.loopsLeft == 0)
					songStarted = true;
			}, countdownLength + 1);
		}
		conductor.playFromTime(-beatTime * (countdownLength + 1));
	}

	function endSong():Void {

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
		var event:ScriptEvent = scripts.event('onDraw', new ScriptEvent());
		if (!event.prevented) {
			super.draw();
			scripts.call('onDrawPost');
		}
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
		ArrowField.enemyPlay = ArrowField.enableP2 = false;
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
		ArrowField.enemyPlay = playAsEnemy;
		ArrowField.enableP2 = p2AsEnemy;
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
			},
			hud: 'funkin'
		}
		log('Song "$loadedChart" loaded.', DebugMessage);
		PlayState.difficulty = diff;
		PlayState.variant = varia;
	}
}