package objects;

import backend.scripting.events.PointEvent;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef CharacterParse = {
	@:default({x: 0, y: 0}) var camera:Position;
	@:optional var color:String;
	@:default('face') var icon:String;
	@:default(2) var singlength:Float;
}
typedef CharacterData = {
	/**
	 * The camera offset position.
	 */
	var camera:Position;
	/**
	 * The character's health bar color.
	 */
	var color:Null<FlxColor>;
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
final class Character extends BeatSprite {
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
	public var cameraOffset(default, null):Position = new Position();
	/**
	 * Get's the characters camera position.
	 * @param pos An optional Position to apply it to.
	 *            If you put a Position it won't create a new one.
	 * @return `Position` ~ The camera position.
	 */
	public function getCamPos(?pos:Position):Position {
		var point:FlxPoint = getMidpoint();
		var event:PointEvent = new PointEvent(
			point.x + cameraOffset.x,
			point.y + cameraOffset.y
		);
		point.put();
		scripts.call('onGetCamPos', [event]);

		event.x *= scrollFactor.x;
		event.y *= scrollFactor.y;
		return pos == null ? new Position(event.x, event.y) : pos.set(event.x, event.y);
	}

	/**
	 * The character's health bar color.
	 */
	public var healthColor(default, null):FlxColor = FlxColor.GRAY;

	override public function renderData(inputData:SpriteData, applyStartValues:Bool = false):Void {
		try {
			if (inputData.character != null) {
				cameraOffset.copyFrom(inputData.character.camera);
				healthColor = inputData.character.color;
				theirIcon = inputData.character.icon;
				singLength = inputData.character.singlength;
			}
		} catch(error:haxe.Exception)
			try {
				trace('Something went wrong. All try statements were bypassed! Tip: "${inputData.asset.image}"');
			} catch(error:haxe.Exception) trace('Something went wrong. All try statements were bypassed! Tip: "null"');
		super.renderData(inputData, false);
	}

	override function get_swapAnimTriggers():Bool
		return true;

	override function loadScript(path:String):Void {
		scripts = new ScriptGroup(this);

		for (char in ['global', 'characters/global', 'characters/$path'])
			for (script in Script.create('content/objects/$char'))
				scripts.add(script);

		scripts.load();
	}

	override public function new(x:Float = 0, y:Float = 0, name:String = 'boyfriend', faceLeft:Bool = false) {
		super(x, y, 'characters/${theirName = (Paths.fileExists('content/objects/characters/$name.json') ? name : 'boyfriend')}');
		if (faceLeft) flipX = !flipX;
		scripts.call('createPost');
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

	override public function destroy():Void {
		super.destroy();
	}
}