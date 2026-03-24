package imaginative.states.editors;

typedef ChartNote = {
	/**
	 * The note direction id.
	 */
	var id:Int;
	// NOTE: As of rn this is actually in milliseconds!!!!!
	/**
	 * The length of a sustain in steps.
	 */
	var length:Float;
	// NOTE: As of rn this is actually in milliseconds!!!!!
	/**
	 * The note position in steps.
	 */
	var time:Float;
	/**
	 * Characters this note will mess with instead of the fields main ones.
	 */
	var characters:Array<String>;
	/**
	 * The note type.
	 */
	var ?type:String;
}

typedef ChartField = {
	/**
	 * The arrow field tag name.
	 */
	var tag:String;
	/**
	 * Characters to be assigned as singers for this field.
	 */
	var characters:Array<String>;
	/**
	 * Array of notes to load.
	 */
	var notes:Array<ChartNote>;
	/**
	 * The independent field scroll speed.
	 */
	var ?speed:Float;
	/**
	 * The starting strum count of the field.
	 */
	var ?startCount:Int;
}

typedef ChartCharacter = {
	/**
	 * The character tag name.
	 */
	var tag:String;
	/**
	 * The character to load.
	 */
	var name:String;
	/**
	 * The location the character will be placed.
	 */
	var position:String;
	/**
	 * The character's vocal suffix override.
	 */
	var ?vocals:String;
}

typedef FieldSettings = {
	/**
	 * The starting camera target
	 */
	var ?cameraTarget:String;
	/**
	 * The arrow field order.
	 */
	var order:Array<String>;
	/**
	 * The enemy field.
	 */
	var ?enemy:String;
	/**
	 * The player field.
	 */
	var ?player:String;
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawChartEvent = {
	var time:Float;
	var data:Array<RawChartSubEvent>;
}
@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawChartSubEvent = {
	var name:String;
	var params:Dynamic<Dynamic>;
}

@:structInit @:publicFields class ChartEvent {
	// NOTE: As of rn this is actually in milliseconds!!!!!
	/**
	 * The event position in steps.
	 */
	var time:Float;
	/**
	 * Each event to trigger.
	 */
	var data:Array<ChartSubEvent>;

	/**
	 * Converts the raw object data.
	 * @param raw The object data.
	 * @return ChartEvent
	 */
	static function fromRaw(raw:RawChartEvent):ChartEvent {
		return {
			time: raw.time,
			data: [
				for (data in raw.data) {
					name: data.name,
					params: FunkinUtil.objectToMap(data.params)
				}
			]
		}
	}
	/**
	 * Converts the object data.
	 * @param data The object data.
	 * @return RawChartEvent
	 */
	static function toRaw(data:ChartEvent):RawChartEvent {
		return {
			time: data.time,
			data: [
				for (data in data.data) {
					name: data.name,
					params: FunkinUtil.mapToObject(data.params)
				}
			]
		}
	}
}
typedef ChartSubEvent = {
	/**
	 * The event name.
	 */
	var name:String;
	/**
	 * The event parameters.
	 */
	var params:Map<String, Dynamic>;
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawChartData = {
	var ?speed:Float;
	var ?stage:String;
	var fields:Array<ChartField>;
	var ?characters:Array<ChartCharacter>;
	var fieldSettings:FieldSettings;
	var ?hud:String;
	var ?events:Array<RawChartEvent>;
}
@:structInit @:publicFields class ChartData {
	/**
	 * The song scroll speed.
	 */
	var speed:Float;
	/**
	 * The stage this song will take place.
	 */
	var stage:String;
	/**
	 * Array of arrow fields to load.
	 */
	var fields:Array<ChartField>;
	/**
	 * Array of characters to load.
	 */
	var characters:Array<ChartCharacter>;
	/**
	 * Field settings.
	 */
	var fieldSettings:FieldSettings;
	/**
	 * The song hud.
	 */
	var hud:String;
	/**
	 * Chart specific events.
	 */
	var events:Array<ChartEvent>;

	/**
	 * Converts the raw object data.
	 * @param raw The object data.
	 * @return ChartData
	 */
	static function fromRaw(raw:RawChartData):ChartData {
		return {
			speed: raw.speed ?? 2.6,
			stage: raw.stage ?? 'void',
			fields: [
				for (field in raw.fields) {
					tag: field.tag,
					characters: field.characters,
					notes: field.notes,
					speed: field.speed,
					startCount: field.startCount ?? 4
				}
			],
			characters: raw.characters ?? [],
			fieldSettings: raw.fieldSettings,
			hud: raw.hud ?? 'default',
			events: [for (event in raw.events ?? []) ChartEvent.fromRaw(event)]
		}
	}
	/**
	 * Converts the object data.
	 * @param data The object data.
	 * @return RawChartData
	 */
	static function toRaw(data:ChartData):RawChartData {
		return {
			speed: data.speed,
			stage: data.stage,
			fields: data.fields,
			characters: data.characters,
			fieldSettings: data.fieldSettings,
			hud: data.hud,
			events: [for (event in data.events) ChartEvent.toRaw(event)]
		}
	}
}

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