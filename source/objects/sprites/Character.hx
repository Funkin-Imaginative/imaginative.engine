package objects.sprites;

import utils.SpriteUtil.TypeSpriteData;
import utils.SpriteUtil.CharacterSpriteData;

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
	public var cameraOffset:PositionStruct = new PositionStruct();

	public var singLength:Float = 0;
	public var lastHit:Float = Math.NEGATIVE_INFINITY;

	public var healthColor:FlxColor = FlxColor.GRAY;

	public var theirName:String;
	public var theirIcon(get, default):String;
	inline function get_theirIcon():String {
		return theirIcon;
	}

	public var charData:CharacterData = null;

	override public function renderData(inputData:TypeSpriteData):Void {
		var newData:CharacterSpriteData = inputData;
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

		if (scripts.length < 1)
			scripts.add(new Script());

		scripts.load();
	}

	public function new(x:Float = 0, y:Float = 0, name:String = 'boyfriend', faceLeft:Bool = false) {
		super(x, y, ParseUtil.object('characters/${theirName = name}', CHARACTER));
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