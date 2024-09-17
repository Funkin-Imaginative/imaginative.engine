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

	override function get_parseType():ObjectType
		return CHARACTER;

	public var charData:CharacterData = null;
	override public function renderData(inputData:TypeSpriteData):Void {
		var newData:CharacterSpriteData = cast inputData;
		super.renderData(inputData);

		cameraOffset.copyFrom(newData.character.camera);
		healthColor = newData.character.color;
		theirIcon = newData.character.icon;
		singLength = FunkinUtil.getDefault(newData.character.singlength, 4);

		charData = newData.character;
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