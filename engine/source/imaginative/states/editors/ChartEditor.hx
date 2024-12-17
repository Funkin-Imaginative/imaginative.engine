package imaginative.states.editors;

typedef ChartNote = {
	/**
	 * The note direction id.
	 */
	var id:Int;
	/**
	 * NOTE: As of rn this is actually in milliseconds!!!!!
	 * The length of a sustain in steps.
	 */
	@:default(0) var length:Float;
	/**
	 * NOTE: As of rn this is actually in milliseconds!!!!!
	 * The note position in steps.
	 */
	var time:Float;
	/**
	 * Characters this note will mess with instead of the fields main ones.
	 */
	var ?characters:Array<String>;
	/**
	 * The note type.
	 */
	var type:String;
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
}

typedef ChartCharacter = {
	/**
	 * The character tag name.
	 */
	var tag:String;
	/**
	 * The character to load.
	 */
	@:default('boyfriend') var name:String;
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
	var enemy:String;
	/**
	 * The player field.
	 */
	var player:String;
}

typedef ChartEvent = {
	/**
	 * The event name.
	 */
	var name:String;
	/**
	 * The event parameters.
	 */
	var params:Array<OneOfFour<Int, Float, Bool, String>>;
	/**
	 * NOTE: As of rn this is actually in milliseconds!!!!!
	 * The event position in steps.
	 */
	var time:Float;
	/**
	 * This is used for event stacking detection.
	 */
	@:default(0) var ?sub:Int;
}

typedef ChartData = {
	/**
	 * The song scroll speed.
	 */
	@:default(2.6) var speed:Float;
	/**
	 * The stage this song will take place.
	 */
	@:default('void') var stage:String;
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
	 * Chart specific events.
	 */
	var ?events:Array<ChartEvent>;
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