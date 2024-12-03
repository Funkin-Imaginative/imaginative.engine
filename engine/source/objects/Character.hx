package objects;

import backend.scripting.events.PointEvent;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef CharacterParse = {
	@:default({x: 0, y: 0}) var camera:Position;
	var ?color:String;
	@:default('face') var icon:String;
	@:default(0.5) var holdlength:Float;
}
typedef CharacterData = {
	/**
	 * The camera offset position.
	 */
	var camera:Position;
	/**
	 * The character's health bar color.
	 */
	var ?color:FlxColor;
	/**
	 * The character's icon.
	 */
	var icon:String;
	/**
	 * The amount of time in seconds the animation can be forced to last.
	 * If set to 0, the animation that is played, plays out normally.
	 */
	var holdlength:Float;
}

/**
 * This is the character class, used for the funny beep boop guys!
 */
final class Character extends BeatSprite implements ITexture<Character> {
	// Texture related stuff.
	override public function loadTexture(newTexture:ModPath):Character
		return cast super.loadTexture(newTexture);
	override public function loadImage(newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):Character
		return cast super.loadImage(newTexture, animated, width, height);
	override public function loadSheet(newTexture:ModPath):Character
		return cast super.loadSheet(newTexture);

	/**
	 * The character key name.
	 */
	public var theirName(default, null):String;
	/**
	 * The character icon.
	 */
	public var theirIcon(default, null):String = 'face';

	/**
	 * Used to help `holdLength`.
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The amount of time in seconds the animation can be forced to last.
	 * If set to 0, the animation that is played, plays out normally.
	 */
	public var holdLength:Float = 0.5;

	/**
	 * The camera offset position.
	 */
	public var cameraOffset(default, null):Position = new Position();
	/**
	 * Get's the characters camera position.
	 * @param point An optional Position to apply it to.
	 *              If you put a Position it won't create a new one.
	 * @return `Position` ~ The camera position.
	 */
	public function getCamPos(?point:Position):Position {
		var midpoint:FlxPoint = getMidpoint();
		var event:PointEvent = new PointEvent(
			midpoint.x + spriteOffsets.position.x + cameraOffset.x,
			midpoint.y + spriteOffsets.position.y + cameraOffset.y
		);
		midpoint.put();
		scripts.call('onGetCamPos', [event]);

		event.x *= scrollFactor.x;
		event.y *= scrollFactor.y;
		return point == null ? new Position(event.x, event.y) : point.set(event.x, event.y);
	}

	/**
	 * The character's health bar color.
	 */
	public var healthColor(default, null):FlxColor = FlxColor.GRAY;

	override public function renderData(inputData:SpriteData, applyStartValues:Bool = false):Void {
		var modPath:ModPath = null;
		try {
			modPath = inputData.asset.image;
			if (inputData.character != null) {
				cameraOffset.copyFrom(inputData.character.camera);
				healthColor = inputData.character.color;
				theirIcon = inputData.character.icon;
				holdLength = inputData.character.holdlength;
			}
		} catch(error:haxe.Exception)
			try {
				log('Something went wrong. All try statements were bypassed! Tip: "${modPath.format()}"', ErrorMessage);
			} catch(error:haxe.Exception)
				log('Something went wrong. All try statements were bypassed! Tip: "null"', ErrorMessage);
		super.renderData(inputData, false);
	}

	override function get_swapAnimTriggers():Bool
		return true;

	override function loadScript(file:ModPath):Void {
		scripts = new ScriptGroup(this);

		var bruh:Array<ModPath> = ['lead:global', 'lead:characters/global'];
		if (file != null && file.path != null && file.path.trim() != '')
			bruh.push('${file.type}:characters/${file.path}');

		log([for (file in bruh) file.format()], DebugMessage);

		for (char in bruh)
			for (script in Script.create('${char.type}content/objects/${char.path}'))
				scripts.add(script);

		scripts.load();
	}

	override public function new(x:Float = 0, y:Float = 0, name:String = 'boyfriend', faceLeft:Bool = false) {
		super(x, y, 'characters/${theirName = (Paths.fileExists(Paths.character(name)) ? name : 'boyfriend')}');
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
				if (holdLength > 0 ? (lastHit + (holdLength * 1000) < Conductor.song.songPosition) : (getAnimName() == null || isAnimFinished()))
					dance();
			default:
				super.tryDance();
		}
	}

	override function generalSuffixCheck(context:AnimationContext):String {
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