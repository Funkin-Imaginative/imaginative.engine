package objects.sprites;

typedef CharacterParse = {
	@:default({x: 0, y: 0}) var camera:PositionStruct;
	var color:String;
	var icon:String;
	var singlength:Float;
}
typedef CharacterData = {
	var camera:PositionStruct;
	var color:FlxColor;
	var icon:String;
	var singlength:Float;
}

class Character extends BeatSprite {
	public var singSuffix:String = '';
	public var theirName:String;
	public var theirIcon(get, default):String;
	inline function get_theirIcon():String {
		return theirIcon;
	}

	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	public var singLength:Float = 0;

	public var cameraOffset:PositionStruct = new PositionStruct();

	public var healthColor:FlxColor = FlxColor.GRAY;

	public var charData:CharacterData = null;
	override function get_objType():ObjectType {
		return CHARACTER;
	}
	override public function renderData(inputData:TypeSpriteData):Void {
		final incomingData:CharacterSpriteData = cast inputData;
		super.renderData(inputData);
		try {
			try {
				cameraOffset.copyFrom(FunkinUtil.getDefault(incomingData.character.camera, new PositionStruct()));
			} catch(error:haxe.Exception) trace('Couldn\'t set camera offsets.');
			try {
				healthColor = incomingData.character.color;
			} catch(error:haxe.Exception) trace('Couldn\'t set the health bar color.');
			try {
				theirIcon = incomingData.character.icon;
			} catch(error:haxe.Exception) trace('Couldn\'t set the characters icon.');
			try {
				singLength = FunkinUtil.getDefault(incomingData.character.singlength, 4);
			} catch(error:haxe.Exception) trace('Couldn\'t set the sing length.');

			try {
				charData = incomingData.character;
			} catch(error:haxe.Exception) trace('Couldn\'t set the character data variable.');
		} catch(error:haxe.Exception)
			try {
				trace('Something went very wrong! What could bypass all the try\'s??? Tip: "${incomingData.asset.image}"');
			} catch(error:haxe.Exception) trace('Something went very wrong! What could bypass all the try\'s??? Tip: "null"');

	}

	override function loadScript(path:String):Void {
		for (s in ['global', path])
			for (script in Script.create('characters/$s', OBJECT))
				scripts.add(script);

		super.loadScript(path);
	}

	public function new(x:Float = 0, y:Float = 0, name:String = 'boyfriend', faceLeft:Bool = false) {
		super(x, y, 'characters/${theirName = name}');
	}

	override public function tryDance():Void {
		switch (animType) {
			case SING | MISS:
				if (lastHit + (Conductor.song.stepCrochet * singLength) < Conductor.song.songPosition)
					dance();
			default:
				super.tryDance();
		}
	}
}