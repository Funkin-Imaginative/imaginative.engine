package moonchart.formats.fnf;

import haxe.io.Path;
import flixel.util.FlxColor;
import moonchart.backend.FormatData;
import moonchart.backend.Optimizer;
import moonchart.backend.Timing;
import moonchart.backend.Util;
import moonchart.formats.BasicFormat;
import moonchart.formats.fnf.FNFGlobal;
import moonchart.formats.fnf.legacy.FNFLegacy;

// Chart
typedef FNFImaginativeNote = {
	var id:Int;
	var length:Float;
	var time:Float;
	var ?characters:Array<String>;
	var ?type:String;
}

typedef FNFImaginativeArrowField = {
	var tag:String;
	var characters:Array<String>;
	var notes:Array<FNFImaginativeNote>;
	var ?speed:Float;
	var ?startCount:Int;
}

typedef FNFImaginativeCharacter = {
	var tag:String;
	var name:String;
	var position:String;
	var ?vocals:String;
}

typedef FNFImaginativeFieldSettings = {
	var ?cameraTarget:String;
	var order:Array<String>;
	var enemy:String;
	var player:String;
}

typedef FNFImaginativeEvent = {
	var time:Float;
	var data:Array<FNFImaginativeSubEvent>;
}
typedef FNFImaginativeSubEvent = {
	var name:String;
	var params:JsonMap<Dynamic>;
}

typedef FNFImaginativeChart = {
	var ?speed:Float;
	var ?stage:String;
	var fields:Array<FNFImaginativeArrowField>;
	var ?characters:Array<FNFImaginativeCharacter>;
	var fieldSettings:FNFImaginativeFieldSettings;
	var ?hud:String;
	var ?events:Array<FNFImaginativeEvent>;
}

// Meta
typedef FNFImaginativeCheckpoint = { // used for bpm changes
	var time:Float;
	var bpm:Float;
	var signature:Array<Int>;
}

typedef FNFImaginativeAllowedModes = {
	var playAsEnemy:Bool;
	var p2AsEnemy:Bool;
}

typedef FNFImaginativeAudioMeta = {
	var artist:String;
	var name:String;
	var bpm:Float;
	var signature:Array<Int>;
	var ?offset:Float;
	var checkpoints:Array<FNFImaginativeCheckpoint>;
}

typedef FNFImaginativeSongMeta = {
	var name:String;
	var folder:String;
	var icon:String;
	var startingDiff:Int;
	var difficulties:Array<String>;
	var variants:Array<String>;
	var ?color:FlxColor;
	var allowedModes:FNFImaginativeAllowedModes;
}

enum abstract FNFImaginativeNoteType(String) from String to String {
	var IMAG_ALT_ANIM = 'Alt Animation';
	var IMAG_NO_ANIM = 'No Animation';
}

class FNFImaginative extends BasicJsonFormat<FNFImaginativeChart, FNFImaginativeAudioMeta> {
	public static function __getFormat():FormatData {
		@:privateAccess FNFGlobal.get_camFocus(); // jic

		FNFGlobal.camFocus.set('Focus Camera To Custom Position', (e) -> return BF);
		FNFGlobal.camFocus.set('Focus Camera To Character', e -> {
			final map:JsonMap<Dynamic> = e.data;
			if (!map.keys().contains('target')) return BF;
			return switch (map.get('target')) {
				case 'enemy': DAD;
				case 'spectator': GF;
				default: BF;
			};
		});

		return {
			ID: FNF_IMAGINATIVE,
			name: 'FNF (Imaginative)',
			description: 'The chart format for Imaginative Engine.',
			extension: 'json',
			hasMetaFile: TRUE,
			metaFileExtension: 'json',
			specialValues: ['"speed":', '?"stage":', '_"fields":', '_"characters":', '_"fieldSettings":', '?"hud":', '?"events":'],
			formatFile: FNFMaru.formatFile,
			handler: FNFImaginative
		}
	}

	public var noteTypeResolver(default, null):FNFNoteTypeResolver;

	public function new(?data:FNFImaginativeChart, ?meta:FNFImaginativeAudioMeta) {
		// NOTE: will be in STEPS but idk how to fully do that as of rn
		super({timeFormat: MILLISECONDS, supportsDiffs: false, supportsEvents: true});
		this.data = data;
		this.meta = meta;
		beautify = true;

		noteTypeResolver = FNFGlobal.createNoteTypeResolver();
		noteTypeResolver.register(FNFImaginativeNoteType.IMAG_ALT_ANIM, BasicFNFNoteType.ALT_ANIM);
		noteTypeResolver.register(FNFImaginativeNoteType.IMAG_NO_ANIM, BasicFNFNoteType.NO_ANIM);
	}

	public static function formatTitle(title:String):String
		return Path.normalize(title);

	inline static var _UNKNOWN_:String = '[unknown]';
	override function fromBasicFormat(chart:BasicChart, ?diff:FormatDifficulty):FNFImaginative {
		var chartResolve:DiffNotesOutput = resolveDiffsNotes(chart, diff);
		var diffId:String = chartResolve.diffs[0];
		var basicMeta:BasicMetaData = chart.meta;

		var characters:Array<FNFImaginativeCharacter> = Util.makeArray(0);
		var charCap:Int = basicMeta.extraData.exists(FNFLegacyMetaValues.PLAYER_3) ? 3 : (basicMeta.extraData.get(FNFLegacyMetaValues.PLAYER_3) == null ? 2 : 3);
		for (i in 0...charCap) {
			characters.push({
				tag: switch (i) {
					case 0: 'enemy';
					case 1: 'player';
					case 2: 'spectator';
					default: _UNKNOWN_;
				},
				name: switch (i) {
					case 0: basicMeta.extraData.get(FNFLegacyMetaValues.PLAYER_1) ?? 'dad';
					case 1: basicMeta.extraData.get(FNFLegacyMetaValues.PLAYER_2) ?? 'boyfriend';
					case 2: basicMeta.extraData.get(FNFLegacyMetaValues.PLAYER_3) ?? 'gf';
					default: '';
				},
				position: switch (i) {
					case 0: 'enemy';
					case 1: 'player';
					case 2: 'spectator';
					default: _UNKNOWN_;
				},
			});
		}

		var fields:Array<FNFImaginativeArrowField> = Util.makeArray(0);
		for (i in 0...2) {
			fields.push({
				tag: characters[i].tag,
				characters: [characters[i].tag],
				notes: Util.makeArray(0)
			});
		}

		var basicNotes:Array<BasicNote> = Timing.sortNotes(chartResolve.notes.get(diffId));
		for (note in basicNotes) {
			var field:FNFImaginativeArrowField = fields[Std.int(note.lane / 4)];
			if (field == null) continue;
			field.notes.push({
				id: note.lane % 4,
				length: note.length,
				time: note.time,
				type: note.type
			});
		}
		for (field in fields) field.notes.sort((a, b) -> return Util.sortValues(a.time, b.time));

		var events:Array<FNFImaginativeEvent> = Util.makeArray(0);
		var basicEvents:Array<BasicEvent> = Timing.sortEvents(chart.data.events);
		// trace(haxe.Json.stringify(basicEvents, '\t'));
		for (i => event in basicEvents) {
			// helper for event making
			inline function makeEvent(name:String, params:Map<String, Dynamic>):Void {
				// doing psychs event stacking method
				if (i - 1 > -1 && event.time == events[i - 1].time)
					events[i - 1].data.push({name: name, params: params});
				else
					events.push({
						time: event.time,
						data: [
							{name: name, params: params}
						]
					});
			}
			var useMoonchartCamFocusResolver:Bool = true;

			// vslice conversion process
			if (basicMeta.inputFormats.contains(FNF_VSLICE)) {
				switch (event.name) {
					case 'FocusCamera':
						useMoonchartCamFocusResolver = false;
						final target:Int = event.data?.char ?? 0;
						final xy:Array<Float> = [event.data?.x ?? 0, event.data?.y ?? 0];
						final duration:Float = event.data?.duration ?? 4;
						final ease:Array<String> = [
							{
								var type:String = event.data?.ease ?? '[none]'
								if (type == 'INSTANT') type = '[instant]';
								if (type == 'CLASSIC') type = '[none]';
								type;
							},
							event.data?.easeDir ?? 'In'
						];

						if (target == -1)
							makeEvent('Focus Camera To Custom Position', [
								'position' => xy,
								'duration' => duration, 'ease' => ease,
								'displacement-act' => 'disable'
							]);
						else
							makeEvent('Focus Camera To Character', [
								'target' => switch (target) {
									case 0: 'player';
									case 1: 'enemy';
									case 2: 'spectator';
									default: _UNKNOWN_;
								},
								'offset' => xy,
								'duration' => duration, 'ease' => ease,
								// _UNKNOWN_, false, // idr wtf these where 😭
								'displacement-act' => 'disable' // how camera displacement should act when tweening if its enabled
							]);

					case 'PlayAnimation':
						final target:String = {
							var penis:String = event.data?.target ?? 'player';
							penis = switch (penis) {
								case 'boyfriend' | 'bf': 'player';
								case 'dad' | 'opponent': 'enemy';
								case 'girlfriend' | 'gf': 'spectator';
								default: penis;
							}
							penis;
						}
						makeEvent('Play Sprite Animation', [
							'target-type' => target == 'enemy' || target == 'player' || target == 'spectator' ? 'character' : 'sprite',
							'target' => target,
							'animation' => event.data?.anim ?? _UNKNOWN_,
							'context' => 'Unclear', // animation context
							'force' => event.data?.force ?? true,
							'reversed' => false, // reversed
							'frame' => 0 // starting frame
						]);

					case 'ScrollSpeed':
						final target:String = switch (event.data?.strumline) {
							case 'opponent': 'enemy';
							case 'player': 'player';
							default: '[global]';
						}
						final ease:Array<String> = [
							{
								var type:String = event.data?.ease ?? 'linear';
								if (type == 'INSTANT') type = '[instant]';
								type;
							},
							event.data?.easeDir ?? 'In'
						];
						makeEvent('Manage Scroll Speed', [
							'target' => target,
							'speed' => event.data?.scroll ?? 1,
							'duration' => event.data?.duration ?? 4, 'ease' => ease,
							'absolute' => event.data?.absolute ?? false
						]);

					case 'SetCameraBop':
						// TODO: Write this.

					// case 'SetCharacter':
						// TODO: Write this.

					case 'SetHealthIcon':
						var target:Int = event.data?.char ?? 0;
						final iconId:String = event.data?.id ?? 'boyfriend';
						// MAYBE: Write this?

					// case 'SetStage':
						// TODO: Write this.

					case 'ZoomCamera':
						final ease:Array<String> = [
							{
								var type:String = event.data?.ease ?? 'linear';
								if (type == 'INSTANT') type = '[instant]';
								// sets the default zoom and lerps handle the rest
								// if (ease == 'CLASSIC') ease = '[none]';
								type;
							},
							event.data?.easeDir ?? 'In'
						];
						makeEvent('Manage Camera Zoom', [
							'zoom' => event.data?.zoom ?? 1,
							'duration' => event.data?.duration ?? 4, 'ease' => ease,
							'mode' => (event.data?.mode ?? 'stage') == 'stage'
						]);
					default:
						// UNKNOWN
				}
			}

			// psych conversion process
			if (basicMeta.inputFormats.contains(FNF_LEGACY_PSYCH)) {
				switch (event.name) {
					case 'Play Animation':
						/* makeEvent('Play Sprite Animation', [
							//
						]); */
					default:
						// UNKNOWN
				}
				// TODO: Write this.
			}

			// codename conversion process
			if (basicMeta.inputFormats.contains(FNF_CODENAME)) {
				switch (event.name) {
					case FNFCodename.CODENAME_CAM_MOVEMENT:
						// useMoonchartCamFocusResolver = false;
					default:
						// UNKNOWN
				}
			}

			if (basicMeta.inputFormats.contains(FNF_IMAGINATIVE))
				useMoonchartCamFocusResolver = false;

			if (useMoonchartCamFocusResolver && FNFGlobal.isCamFocus(event))
				makeEvent('Focus Camera To Character', [
					'target' => switch (FNFGlobal.resolveCamFocus(event)) {
						case BF: 'player';
						case DAD: 'enemy';
						case GF: 'spectator';
					},
					'offset' => [0, 0],
					'duration' => 4, 'ease' => '[none]',
					// _UNKNOWN_, false, // idr wtf these where 😭
					'displacement-act' => 'disable'
				]);
		}
		events.sort((a, b) -> return Util.sortValues(a.time, b.time));
		trace(haxe.Json.stringify(events, '\t'));

		data = {
			speed: basicMeta.scrollSpeeds.get(diffId) ?? Util.mapFirst(basicMeta.scrollSpeeds) ?? 2.6,
			stage: basicMeta.extraData.get(FNFLegacyMetaValues.STAGE) ?? 'void',
			fields: fields,
			characters: characters,
			fieldSettings: {
				cameraTarget: 'enemy',
				order: ['enemy', 'player'],
				enemy: 'enemy',
				player: 'player'
			},
			events: events
		}

		var bpmChanges:Array<BasicBPMChange> = basicMeta.bpmChanges;
		var initChange:BasicBPMChange = bpmChanges.shift();
		meta = {
			artist: basicMeta.extraData.get(SONG_ARTIST) ?? Moonchart.DEFAULT_ARTIST,
			name: basicMeta.title,
			bpm: initChange.bpm,
			signature: [Std.int(initChange.stepsPerBeat), Std.int(initChange.beatsPerMeasure)],
			offset: basicMeta.offset,
			checkpoints: [
				for (change in bpmChanges) {
					{
						time: change.time,
						bpm: change.bpm,
						signature: [Std.int(change.stepsPerBeat), Std.int(change.beatsPerMeasure)]
					}
				}
			]
		}

		return this;
	}

	override function getNotes(?diff:String):Array<BasicNote> {
		var notes:Array<BasicNote> = Util.makeArray(0);
		for (field in data.fields)
			for (note in field.notes)
				notes.push({
					time: note.time,
					lane: note.id,
					length: note.length,
					type: note.type
				});
		Timing.sortNotes(notes);
		return notes;
	}

	override function getEvents():Array<BasicEvent> {
		var events:Array<BasicEvent> = Util.makeArray(0);
		for (event in data.events)
			for (data in event.data)
				events.push(Util.makeArrayEvent(event.time, data.name, data.params));
		Timing.sortEvents(events);
		return events;
	}

	function getArrowField(tags:Array<String>):FNFImaginativeArrowField {
		for (field in data.fields)
			if (tags.contains(field.tag))
				return field;
		return null;
	}

	override function getChartMeta():BasicMetaData {
		var bpmChanges:Array<BasicBPMChange> = [
			{
				time: 0,
				bpm: meta.bpm,
				stepsPerBeat: meta.signature[0],
				beatsPerMeasure: meta.signature[1]
			}
		];
		for (checkpoint in meta.checkpoints)
			bpmChanges.push({
				time: checkpoint.time,
				bpm: checkpoint.bpm,
				stepsPerBeat: checkpoint.signature[0],
				beatsPerMeasure: checkpoint.signature[1]
			});
		Timing.sortBPMChanges(bpmChanges);
		return {
			title: meta.name,
			bpmChanges: bpmChanges,
			offset: 0,
			scrollSpeeds: [diffs[0] => data.speed],
			extraData: [
				PLAYER_1 => getArrowField(['player', 'boyfriend', 'bf'])?.characters[0] ?? 'boyfriend',
				PLAYER_2 => getArrowField(['enemy', 'opponent', 'dad'])?.characters[0] ?? 'dad',
				PLAYER_3 => getArrowField(['spectator', 'gf', 'girlfriend'])?.characters[0] ?? 'gf',
				SONG_ARTIST => meta.artist ?? Moonchart.DEFAULT_ARTIST,
				SONG_CHARTER => Moonchart.DEFAULT_CHARTER, // no variable for this yet
				STAGE => data.stage
			]
		}
	}

	override function fromFile(path:String, ?meta:StringInput, ?diff:FormatDifficulty):FNFImaginative {
		return fromJson(Util.getText(path), Util.getText(meta), diff);
	}

	override function fromJson(data:String, ?meta:StringInput, ?diff:FormatDifficulty):FNFImaginative {
		super.fromJson(data, meta, diff);
		Optimizer.addDefaultValues(this.data, {
			fields: [for (i in 0...2) {tag: i == 0 ? 'enemy' : 'player', characters: [i == 0 ? 'enemy' : 'player'], notes: Util.makeArray(0)}],
			characters: [for (i in 0...2) {tag: i == 0 ? 'enemy' : 'player', position: _UNKNOWN_}],
			fieldSettings: {cameraTarget: 'player', order: ['enemy', 'player'], enemy: 'enemy', player: 'player'}
		});
		return this;
	}
}