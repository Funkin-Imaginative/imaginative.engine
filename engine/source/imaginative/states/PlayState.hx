package imaginative.states;

import imaginative.objects.gameplay.hud.*;
import imaginative.objects.ui.cameras.PlayCamera;
import imaginative.states.editors.ChartEditor.ChartData;
import imaginative.states.menus.*;

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

	// NOTE: As of rn this is actually in milliseconds!!!!!
	/**
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
	 * Executes the event code.
	 */
	inline public function execute():Void
		if (code != null)
			code();
}

/**
 * Where all the funny beep boops happen!
 */
class PlayState extends BeatState {
	/**
	 * The variable that handles the song audio.
	 */
	public var songAudio(get, never):Conductor;
	inline function get_songAudio():Conductor
		return Conductor.song;
	/**
	 * The variable that handles the cutscene audio.
	 */
	public var cutsceneAudio(get, never):Conductor;
	inline function get_cutsceneAudio():Conductor
		return Conductor.cutscene;

	override function get_conductor():Conductor {
		if (songEnded || !(songStarted || countdownStarted))
			return cutsceneAudio;
		return songAudio;
	}
	inline override function set_conductor(value:Conductor):Conductor
		return get_conductor();

	/**
	 * Direct access to the state instance.
	 */
	public static var instance:PlayState;

	/**
	 * The amount of beats the countdown lasts for.
	 */
	public var countdownLength(default, set):Int = 4;
	inline function set_countdownLength(value:Int):Int
		return countdownLength = Std.int(Math.max(value, 1));
	/**
	 * This timer that tracks the countdown steps.
	 */
	public var countdownTimer:FlxTimer = new FlxTimer();
	/**
	 * The assets what will be used in the countdown.
	 */
	public var countdownAssets:CountdownAssets;
	/**
	 * Sets up the listings for the countdownAssets variable.
	 * @param root The path to the assets.
	 * @param parts List of assets to get from root var path.
	 * @param suffix Adds a suffix to each item of the parts array.
	 * @return Array<ModPath> ~ The mod paths of the items.
	 */
	inline public function getCountdownAssetList(?root:ModPath, parts:Array<String>, ?suffix:String):Array<ModPath> {
		if (root == null)
			root = 'gameplay/countdown/';
		return [
			for (part in parts)
				part == null ? null : '${root.type}:${FilePath.addTrailingSlash(root.path)}$part${suffix.isNullOrEmpty() ? '' : '-$suffix'}'
		];
	}

	/**
	 * States if the countdown has started.
	 */
	public var countdownStarted(default, null):Bool = false;
	/**
	 * States if the song has started.
	 */
	public var songStarted(default, null):Bool = false;
	/**
	 * States if the song has ended.
	 */
	public var songEnded(default, null):Bool = false;

	/**
	 * The general vocal track instance.
	 */
	public var generalVocals:Null<FlxSound>;

	// TODO: Figure out what to do with this.
	/**
	 * If true your score will save.
	 */
	public var saveScore(default, null):Bool = true;

	/**
	 * The chart information that *PlayState* uses.
	 */
	public static var chartData:ChartData;
	// TODO: Code this shit in.
	public var songEvents:Array<SongEvent> = [];

	// TODO: Rework these into playlist specific stuff.
	// MAYBE: Move these into a util class?
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
	 * If true your in story mode.
	 * If false your playing the song by choice.
	 */
	public static var storyMode(default, null):Bool = false;
	/**
	 * List of songs that will play out.
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
	public static var curDifficulty(default, null):String = 'normal';
	/**
	 * The variant key of the current song.
	 */
	public static var curVariant(default, null):String = 'normal';

	/**
	 * If true the player character can die upon losing all their health.
	 */
	public var canPlayerDie:Bool = !ArrowField.enemyPlay && !ArrowField.enableP2;
	/**
	 * If true the enemy character can die upon losing all their health.
	 */
	public var canEnemyDie:Bool = ArrowField.enemyPlay && !ArrowField.enableP2;

	/**
	 * Scripts for the funny softcoding bullshit.
	 */
	public var songScripts:ScriptGroup;
	/**
	 * The HUD itself.
	 */
	public var hud:HUDTemplate;

	/**
	 * The main camera, all characters and stage elements will be shown here.
	 */
	public var camGame:PlayCamera;
	/**
	 * The HUD camera, all ui elements will be shown here.
	 */
	public var camHUD:BeatCamera;

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
	public var enemy(get, set):Null<Character>;
	inline function get_enemy():Null<Character>
		return enemies[0];
	inline function set_enemy(?value:Character):Null<Character> {
		if (enemyField == null) return null;
		return enemies[0] = value; // don't want to be setting an empty field
	}
	/**
	 * What would be known as the Boyfriend.
	 */
	public var player(get, set):Null<Character>;
	inline function get_player():Null<Character>
		return players[0];
	inline function set_player(?value:Character):Null<Character> {
		if (playerField == null) return null;
		return players[0] = value; // don't want to be setting an empty field
	}

	/**
	 * All characters from the enemy field.
	 */
	public var enemies(get, set):Array<Character>;
	inline function get_enemies():Array<Character> {
		if (enemyField == null) return [];
		return enemyField.assignedActors;
	}
	inline function set_enemies(value:Array<Character>):Array<Character> {
		if (enemyField == null) return [];
		return enemyField.assignedActors = value;
	}
	/**
	 * All characters from the player field.
	 */
	public var players(get, set):Array<Character>;
	inline function get_players():Array<Character> {
		if (playerField == null) return [];
		return playerField.assignedActors;
	}
	inline function set_players(value:Array<Character>):Array<Character> {
		if (playerField == null) return [];
		return playerField.assignedActors = value;
	}

	// 'ArrowField' variables.
	/**
	 * Contains all existing arrow fields.
	 */
	public var arrowFieldMapping:Map<String, ArrowField> = new Map<String, ArrowField>();

	/**
	 * The enemy field.
	 */
	public var enemyField(get, set):Null<ArrowField>;
	inline function get_enemyField():Null<ArrowField>
		return ArrowField.enemy;
	inline function set_enemyField(?value:ArrowField):Null<ArrowField>
		return ArrowField.enemy = value;
	/**
	 * The player field.
	 */
	public var playerField(get, set):Null<ArrowField>;
	inline function get_playerField():Null<ArrowField>
		return ArrowField.player;
	inline function set_playerField(?value:ArrowField):Null<ArrowField>
		return ArrowField.player = value;

	/**
	 * The fields that will be positioned and visible on screen.
	 */
	public var activeFields:Array<ArrowField> = [];

	//temp
	var ratings:FlxTypedGroup<BaseSprite>;

	override function initCamera():Void {}

	override public function create():Void {
		Assets.clearCache(true, false, true, true);
		// precache them here for now
		for (i in [1, 2, 3]) // lazy
			FlxG.sound.load(Assets.sound('gameplay/missnote$i'));

		add(songScripts = new ScriptGroup(instance = this));

		bgColor = 0xFFBDBDBD;

		FlxG.cameras.reset(camera = mainCamera = camGame = new PlayCamera('World Camera').beatSetup(songAudio));
		FlxG.cameras.add(camHUD = new BeatCamera('Hud Camera').beatSetup(songAudio), false);
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
		hud.healthBar.setCallbacks(
			() ->
				if (canPlayerDie) {
					var actors:Array<Character> = [];
					if (enemyField != null) actors.concat(enemyField.previousInteractedActors);
					if (enemyField != null) actors.concat(playerField.previousInteractedActors);
					initGameover(actors);
				},
			() ->
				if (canEnemyDie) {
					var actors:Array<Character> = [];
					if (enemyField != null) actors.concat(enemyField.previousInteractedActors);
					if (enemyField != null) actors.concat(playerField.previousInteractedActors);
					initGameover(actors);
				}
		);
		hud.cameras = [camHUD];
		add(hud);

		ratings = new FlxTypedGroup<BaseSprite>();
		ratings.cameras = [camHUD];
		hud.elements.add(ratings);

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
		log('Character(s) ${loadedCharacters.cleanDisplayList()} loaded.', DebugMessage);

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
			field.conductor = songAudio;
			field.parse(base);
			arrowFieldMapping.set(base.tag, field);
			loadedFields.push(base.tag);
			field.scrollSpeed = base.speed;
			field.visible = false;
			hud.fields.add(field);

			/**
			Starting to think of doing these method's.

			```haxe
			songScripts.event('pre[____]', event);
			songScripts.event('[____]', event);

			if (!event.prevented) {
				// code
			}

			songScripts.event('[____]Post', event);
			```

			or

			```haxe
			songScripts.event('pre[____]', event);
			if (!event.prevented) {
				songScripts.event('[____]', event);
				if (!event.prevented) { // idfk lmao, probably wont do this now that I've written it out lol
					songScripts.event('[____]Post', event);
				}
			}
			```
			**/
			field.onNoteHit.add((event) -> {
				songScripts.event('preNoteHit', event);
				songScripts.event('noteHit', event);

				if (!event.prevented) {
					var actors:Array<Character> = event.note.renderActors();
					ArrowField.characterSing(event.field, actors, event.id, IsSinging, event.force, event.suffix);

					for (char in actors)
						for (track in char.assignedTracks)
							track.volume = 1;
					if (generalVocals != null)
						generalVocals.volume = 1;

					if (event.field.status != null)
						hud.health += 0.02 * (event.field.status ? 1 : -1);
					if (event.field.isPlayer) {
						// doing it here for now
						var rating:BaseSprite = ratings.recycle(BaseSprite, () -> return new BaseSprite('gameplay/combo/combo'));
						rating.acceleration.y = rating.velocity.y = rating.velocity.x = 0;
						rating.setPosition(500, 300);

						rating.loadImage('gameplay/combo/${Judging.calculateRating(Math.abs(event.field.conductor.time - event.note.time), event.field.settings)}');
						FlxTween.cancelTweensOf(rating, ['alpha']);
						rating.alpha = 0.0001;
						FlxTween.tween(rating, {alpha: 1}, (event.field.conductor.stepTime / 1000) * 1.2, {
							ease: FlxEase.quadIn,
							onComplete: (_:FlxTween) -> {
								rating.acceleration.y = 550;
								rating.velocity.x -= FlxG.random.float(0, 10);
								rating.velocity.y -= FlxG.random.float(140, 175);
								FlxTween.tween(rating, {alpha: 0.0001}, (event.field.conductor.stepTime / 1000) * 2.4, {
									startDelay: (event.field.conductor.stepTime / 1000) * 1.5,
									onComplete: (_:FlxTween) -> new FlxTimer().start(1, (_:FlxTimer) -> rating.kill()),
									ease: FlxEase.expoOut
								});
							}
						});
					}
				}

				songScripts.event('noteHitPost', event);
			});
			field.onSustainHit.add((event) -> {
				songScripts.event('preSustainHit', event);
				songScripts.event('sustainHit', event);

				if (!event.prevented) {
					var actors:Array<Character> = event.sustain.renderActors();
					ArrowField.characterSing(event.field, actors, event.id, IsSinging, event.force, event.suffix);

					for (char in actors)
						for (track in char.assignedTracks)
							track.volume = 1;
					if (generalVocals != null)
						generalVocals.volume = 1;
				}

				songScripts.event('sustainHitPost', event);
			});
			field.onNoteMissed.add((event) -> {
				songScripts.event('preNoteMissed', event);
				songScripts.event('noteMissed', event);

				if (!event.prevented) {
					var actors:Array<Character> = event.note.renderActors();
					ArrowField.characterSing(event.field, actors, event.id, HasMissed, event.force, event.suffix);

					for (char in actors)
						for (track in char.assignedTracks)
							track.volume = 0;
					if (generalVocals != null)
						generalVocals.volume = 0;

					if (event.field.status != null)
						hud.health -= 0.035 * (event.field.status ? 1 : -1);
				}

				songScripts.event('noteMissedPost', event);
			});
			field.onSustainMissed.add((event) -> {
				songScripts.event('preSustainMissed', event);
				songScripts.event('sustainMissed', event);

				if (!event.prevented) {
					var actors:Array<Character> = event.sustain.renderActors();
					ArrowField.characterSing(event.field, actors, event.id, HasMissed, event.force, event.suffix);

					for (char in actors)
						for (track in char.assignedTracks)
							track.volume = 0;
					if (generalVocals != null)
						generalVocals.volume = 0;
				}

				songScripts.event('sustainMissedPost', event);
			});
			field.onVoidMiss.add((event) -> {
				songScripts.event('preVoidMiss', event);
				songScripts.event('voidMiss', event);

				if (!event.prevented) {
					if (event.triggerMiss) {
						if (!event.stopMissAnimation)
							ArrowField.characterSing(event.field, event.field.assignedActors, event.id, HasMissed, event.force, event.suffix);

						for (char in event.field.assignedActors)
							for (track in char.assignedTracks)
								track.volume = 0;
						if (generalVocals != null)
							generalVocals.volume = 0;
					}
				}

				songScripts.event('voidMissPost', event);
			});
			field.userInput.add((event) -> {
				songScripts.event('preFieldInput', event);
				songScripts.event('fieldInput', event);
				songScripts.event('fieldInputPost', event);
			});
		}
		log('Field(s) ${loadedFields.cleanDisplayList()} loaded.', DebugMessage);

		// arrow field setup
		activeFields = [
			for (tag in chartData.fieldSettings.order)
				if (arrowFieldMapping.exists(tag)) {
					var field:ArrowField = arrowFieldMapping.get(tag);
					field.visible = true;
					field;
				}
		].filter((field:ArrowField) -> return field != null);
		for (i => data in ArrowField.getFieldSetupData(activeFields)) {
			var field:ArrowField = activeFields[i];
			if (data.scale != 1) {
				field.scale.set(data.scale, data.scale);
				field.resetInternalPositions();
			}
			field.setPosition(data.x, hud.getFieldYLevel(Settings.setupP1.downscroll, field));
		}

		if (arrowFieldMapping.exists(chartData.fieldSettings.enemy))
			ArrowField.enemy = arrowFieldMapping.get(chartData.fieldSettings.enemy);
		if (arrowFieldMapping.exists(chartData.fieldSettings.player))
			ArrowField.player = arrowFieldMapping.get(chartData.fieldSettings.player);

		countdownAssets = {
			images: getCountdownAssetList(null, [null, 'ready', 'set', 'go']),
			sounds: getCountdownAssetList(null, ['three', 'two', 'one', 'go'], 'gf')
		}

		camGame.follow(camPoint = new FlxObject(0, 0, 1, 1), LOCKON, 0.05);
		add(camPoint);

		if (chartData.events.empty())
			_log('[PlayState] This song has no events.', DebugMessage);
		else {
			for (event in chartData.events)
				for (data in event.data)
					songEvents.push(new SongEvent(event.time, switch (data.name) {
						default:
							() -> {
								_log('[Event] Ran "${data.name} at ${event.time} with paramaters of ${data.params}.', DebugMessage);
							}
					}));
		}

		super.create();

		for (folder in ['content/songs', 'content/songs/$setSong/scripts'])
			for (ext in Script.exts)
				for (file in Paths.readFolder(folder, ext))
					for (script in Script.createMulti(file))
						songScripts.add(script);

		songScripts.load();
		songScripts.call('create');

		// hud.healthBar.setColors(enemy.healthColor, player.healthColor);

		songAudio.loadSong(setSong, curVariant, (_:FlxSound) -> {
			/**
			 * K: Suffix, V: The Track.
			 */
			var tracks:Map<String, FlxSound> = new Map<String, FlxSound>();
			for (suffix in vocalSuffixes) {
				var track:Null<FlxSound> = songAudio.addVocalTrack(setSong, suffix, curVariant);
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
				var enemyTrack:Null<FlxSound> = songAudio.addVocalTrack(setSong, 'Enemy', curVariant);
				if (enemyTrack != null)
					enemy.assignedTracks.push(enemyTrack);

				var playerTrack:Null<FlxSound> = songAudio.addVocalTrack(setSong, 'Player', curVariant);
				if (playerTrack != null)
					player.assignedTracks.push(playerTrack);
			}

			// loads general track
			if (tracks.empty()) {
				var generalTrack:Null<FlxSound> = songAudio.addVocalTrack(setSong, '', curVariant);
				if (generalTrack != null)
					generalVocals = generalTrack;
			}

			songAudio._onComplete = (event) -> {
				_log('[PlayState] Song Ended.', DebugMessage);
				for (char in characterMapping)
					if (char.animContext == IsSinging || char.animContext == HasMissed)
						char.dance();

				for (field in arrowFieldMapping)
					for (strum in field.strums)
						if (strum.willReset)
							strum.playAnim('static');

				songScripts.event('onSongEnd', event);
				songEnded = true;
				if (!event.prevented)
					endSong();
			}

			startCountdown(countdownAssets);
		});

	}
	override public function createPost():Void {
		var startPosition:Position = characterMapping.exists(cameraTarget) ? characterMapping.get(cameraTarget).getCamPos() : new Position();
		camPoint.setPosition(startPosition.x, startPosition.y);
		camGame.snapToTarget();
		camGame.snapZoom();
		songScripts.call('createPost');
	}

	override public function update(elapsed:Float):Void {
		songScripts.call('update', [elapsed]);
		super.update(elapsed);

		while (songEvents.length > 0 && songEvents.last().time <= time) {
			var poppedEvent:SongEvent = songEvents.pop();
			if (poppedEvent != null)
				poppedEvent.execute();
		}

		if (Controls.global.pause) initPause();
		if (Controls.global.reset && !Settings.setup.disableDeathBind)
			initGameover([enemy, player]);
		songScripts.call('updatePost', [elapsed]);
	}

	function startCountdown(saidAssets:CountdownAssets):Void {
		var assets:CountdownAssets = {
			images: saidAssets.images.copy(),
			sounds: saidAssets.sounds.copy()
		}
		assets.images.reverse();
		assets.sounds.reverse();

		countdownStarted = true;
		if (countdownLength >= 1) {
			countdownTimer.start(beatTime / 1000, (timer:FlxTimer) -> {
				var assetIndex:Int = timer.loopsLeft - 1;
				_log('[PlayState] Countdown step $assetIndex.', DebugMessage);

				var soundAsset:ModPath = assets.sounds[assetIndex];
				if (Paths.sound(soundAsset).isFile) {
					_log('[PlayState] Played countdown sound "$soundAsset".', DebugMessage);
					FlxG.sound.play(Assets.sound(soundAsset));
				}

				var imageAsset:ModPath = assets.images[assetIndex];
				if (Paths.image(imageAsset).isFile) {
					_log('[PlayState] Spawned countdown image "$imageAsset".', DebugMessage);
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

				if (!songStarted)
					startSong(countdownLength);
			}, countdownLength + 1);
		}
	}

	function startSong(startDelay:Int = 0):Void {
		songStarted = true;
		songAudio.playFromTime(-beatTime * Math.abs(startDelay));
		_log('[PlayState] Song started with a delay of ${Math.abs(startDelay)} beats.', DebugMessage);
	}

	function endSong():Void {
		if (storyMode) {
			if (storyIndex == songList.length - 1)
				BeatState.switchState(() -> new StoryMenu());
			else {
				storyIndex++;
				renderChart(songList[storyIndex], curDifficulty, curVariant);
				BeatState.resetState();
			}
		} else {
			BeatState.switchState(() -> new FreeplayMenu());
		}
	}

	function initPause(?subState:FlxSubState):Void {
		openSubState(subState ?? new PauseMenu());
	}

	function initGameover(?potentialChars:Array<Character>):Void {
		potentialChars = potentialChars.filter((char:Character) -> return char != null);
		_log('[PlayState] Triggered Gameover.', DebugMessage);
		var potentialEnemies = potentialChars.filter((char:Character) -> return enemyField == null ? false : enemyField.previousInteractedActors.contains(char));
		var potentialPlayers = potentialChars.filter((char:Character) -> return playerField == null ? false : playerField.previousInteractedActors.contains(char));
		var targetChar:Character = null;
		var enemyHasGameover = potentialEnemies.empty() ? false : Paths.character('${potentialEnemies[0].theirName}-dead').isFile;
		if (!(potentialEnemies.empty() && potentialPlayers.empty()))
			targetChar = enemyHasGameover ? potentialEnemies[0] : potentialPlayers[0];
		else if (!potentialPlayers.empty())
			targetChar = potentialPlayers[0];
		else if (!potentialEnemies.empty())
			targetChar = enemyHasGameover ? potentialEnemies[0] : null;
		openSubState(new GameoverState(targetChar));
	}

	override public function stepHit(curStep:Int):Void {
		super.stepHit(curStep);
		songScripts.call('stepHit', [curStep]);
	}
	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		songScripts.call('beatHit', [curBeat]);
	}
	override public function measureHit(curMeasure:Int):Void {
		super.measureHit(curMeasure);
		songScripts.call('measureHit', [curMeasure]);
	}

	override public function draw():Void {
		var event:ScriptEvent = songScripts.event('onDraw', new ScriptEvent());
		if (!event.prevented) {
			super.draw();
			songScripts.call('onDrawPost');
		}
	}

	override public function onFocus():Void {
		songScripts.call('onFocus');
		super.onFocus();
	}
	override public function onFocusLost():Void {
		songScripts.call('onFocusLost');
		super.onFocusLost();
	}

	override public function destroy():Void {
		instance = null;
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
		_log('[PlayState] Rendering level "${level.name}", rendering songs ${[for (song in levelData.songs) song.name].cleanDisplayList()} under difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}"${variant == 'normal' ? '.' : ' in variant "$variant".'}', SystemMessage);
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
		renderChart(setSong = song, curDifficulty = difficulty, curVariant = variant);
		_log('[PlayState] Rendering song "$song" under difficulty "${FunkinUtil.getDifficultyDisplay(difficulty)}"${variant == 'normal' ? '.' : ' in variant "$variant".'}', SystemMessage);
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
		try {
			chartData = ParseUtil.chart(loadedChart, diff, varia);
		} catch(error:haxe.Exception)
			try {
				chartData = ParseUtil.chart(loadedChart = 'Test', diff = 'normal', varia = 'normal');
			} catch(error:haxe.Exception)
				chartData = {
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
		chartData.events ??= [];
		var eventsPath = 'content/songs/$loadedChart/events${varia == 'normal' ? '' : '$varia/'}';
		if (Paths.fileExists(eventsPath)) chartData.events.concat(ParseUtil.json(eventsPath));
		_log('[PlayState] Song "$loadedChart" loaded on "${FunkinUtil.getDifficultyDisplay(diff)}", variant "$varia".', DebugMessage);
		PlayState.curDifficulty = diff;
		PlayState.curVariant = varia;
	}
}