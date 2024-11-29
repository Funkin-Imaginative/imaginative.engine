package states.editors;

typedef ChartNote = {
	var id:Int;
	@:default(0) var length:Float;
	var time:Float;
	var ?characters:Array<String>;
	var ?type:String;
}

typedef ChartField = {
	var tag:String;
	var characters:Array<String>;
	var notes:Array<ChartNote>;
	@:default(0) var speed:Float;
}

typedef ChartCharacter = {
	var tag:String;
	@:default('boyfriend') var name:String;
	var position:String;
}

typedef FieldSettings = {
	var order:Array<String>;
	var enemy:String;
	var player:String;
}

typedef ChartEvent = {
	var name:String;
	// @:jignored var params:Array<Dynamic>;
	var time:Float;
	@:default(0) var ?sub:Int;
}

typedef ChartData = {
	@:default(2.6) var speed:Float;
	@:default('void') var stage:String;
	var fields:ChartField;
	var characters:Array<ChartCharacter>;
	var fieldSettings:FieldSettings;
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