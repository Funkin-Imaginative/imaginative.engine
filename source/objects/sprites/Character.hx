package objects.sprites;

typedef CharacterParse = {
	var camera:PositionStruct;
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
	override public function renderData(inputData:TypeSpriteData):Void {
		final incomingData:CharacterSpriteData = cast inputData;
		super.renderData(inputData);

		cameraOffset.copyFrom(incomingData.character.camera);
		healthColor = incomingData.character.color;
		theirIcon = incomingData.character.icon;
		singLength = FunkinUtil.getDefault(incomingData.character.singlength, 4);

		charData = incomingData.character;
	}

	override function loadScript(path:String):Void {
		for (s in ['global', path])
			for (script in Script.create('characters/$s', OBJECT))
				scripts.add(script);

		scripts.load();
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