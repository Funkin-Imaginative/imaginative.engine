package objects;

import backend.scripting.events.PointEvent;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef CharacterParse = {
	@:default({x: 0, y: 0}) var camera:PositionStruct;
	@:default('#8000ff') var color:String;
	@:default('face') var icon:String;
	@:default(4) var singlength:Float;
}
typedef CharacterData = {
	/**
	 * The camera offset position.
	 */
	var camera:PositionStruct;
	/**
	 * The character's health bar color.
	 */
	var color:FlxColor;
	/**
	 * The character's icon.
	 */
	var icon:String;
	/**
	 * The sing time the character has.
	 */
	var singlength:Float;
}

/**
 * This is the character class, used for the funny beep boop guys!
 */
class Character extends BeatSprite {
	/**
	 * The character key name.
	 */
	public var theirName(default, null):String;
	/**
	 * The character icon.
	 */
	public var theirIcon(default, null):String = 'face';

	/**
	 * Used to help `singLength`.
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The sing time the character has.
	 */
	public var singLength:Float = 2;

	/**
	 * The camera offset position.
	 */
	public var cameraOffset(default, null):PositionStruct = new PositionStruct();
	/**
	 * Get's the characters camera position.
	 * @param pos An optional PositionStruct to apply it to.
	 * 			  If you put a PositionStruct it won't create a new one.
	 * @return PositionStruct
	 */
	public function getCamPos(?pos:PositionStruct):PositionStruct {
		var point:FlxPoint = getMidpoint();
		var event:PointEvent = new PointEvent(
			point.x + cameraOffset.x,
			point.y + cameraOffset.y
		);
		scripts.call('onGetCamPos', [event]);

		point.put();
		event.x *= scrollFactor.x;
		event.y *= scrollFactor.y;
		return pos == null ? new PositionStruct(event.x, event.y) : pos.set(event.x, event.y);
	}

	/**
	 * The character's health bar color.
	 */
	public var healthColor(default, null):FlxColor = FlxColor.GRAY;

	override public function renderData(inputData:TypeSpriteData):Void {
		final incomingData:CharacterSpriteData = inputData;
		try {
			if (incomingData.character != null) {
				try {
					cameraOffset.copyFrom(incomingData.character.camera.getDefault(new PositionStruct()));
				} catch(error:haxe.Exception) trace('Couldn\'t set camera offsets.');
				try {
					healthColor = incomingData.character.color.getDefault(FlxColor.GRAY);
				} catch(error:haxe.Exception) trace('Couldn\'t set the health bar color.');
				try {
					theirIcon = incomingData.character.icon.getDefault('face');
				} catch(error:haxe.Exception) trace('Couldn\'t set the characters icon.');
				try {
					singLength = incomingData.character.singlength.getDefault(2);
				} catch(error:haxe.Exception) trace('Couldn\'t set the sing length.');
			}
		} catch(error:haxe.Exception)
			try {
				trace('Something went wrong. All try statements were bypassed! Tip: "${incomingData.asset.image}"');
			} catch(error:haxe.Exception) trace('Something went wrong. All try statements were bypassed! Tip: "null"');
		super.renderData(inputData);
	}

	override function loadScript(path:String):Void {
		scripts = new ScriptGroup(this);

		for (char in ['global', 'characters/global', 'characters/$path'])
			for (script in Script.create('content/objects/$char'))
				scripts.add(script);

		scripts.load();
	}

	public function new(x:Float = 0, y:Float = 0, name:String = 'boyfriend', faceLeft:Bool = false) {
		super(x, y, 'characters/${theirName = (Paths.fileExists('content/objects/characters/$name.json') ? name : 'boyfriend')}');
		if (faceLeft) flipX = !flipX;
	}

	/**
	 * The animation suffix for singing.
	 */
	public var singSuffix(default, set):String = '';
	inline function set_singSuffix(value:String):String
		return singSuffix = value.trim();

	override public function tryDance():Void {
		switch (animContext) {
			case IsSinging | HasMissed:
				if (lastHit + (Conductor.song.stepCrochet * singLength) < Conductor.song.songPosition)
					dance();
			default:
				super.tryDance();
		}
	}

	override function generalSuffixCheck(context:AnimContext):String {
		return switch (context) {
			case IsSinging | HasMissed:
				singSuffix;
			default:
				super.generalSuffixCheck(context);
		}
	}
}