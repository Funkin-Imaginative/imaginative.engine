typedef TJsonCharacterSection = {
	var position:PositionMeta;
	var camera:PositionMeta;
	var color:String;
	var icon:String;
	@:optional var singlength:Float;
}
typedef TJsonSpriteSection = {}
typedef TJsonBopperSection = {
	@:optional var invertal:Int;
	@:optional var skipnegative:Bool;
}