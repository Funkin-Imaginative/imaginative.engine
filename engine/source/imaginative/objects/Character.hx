package imaginative.objects;

import imaginative.backend.gameplay.CameraDebugCrosshair;
import imaginative.backend.scripting.events.PointEvent;

typedef CharacterData = {
	/**
	 * The camera offset position.
	 */
	@:default(new imaginative.backend.objects.Position()) var camera:Position;
	/**
	 * The characters health bar color.
	 */
	var ?color:ParseColor;
	/**
	 * The characters icon.
	 */
	@:default('face') var icon:String;
	/**
	 * The amount of time in seconds the animation can be forced to last.
	 * If set to 0 the animation that is played plays out normally.
	 */
	@:default(4) var singlength:Float;
	/**
	 * The character's vocal suffix.
	 * Leave blank to use their file name.
	 */
	var ?vocals:String;
}

/**
 * This is the character class, used for the funny beep boop guy!
 */
final class Character extends BeatSprite implements ITexture<Character> {
	// Texture related stuff.
	override public function loadTexture(newTexture:ModPath):Character
		return cast super.loadTexture(newTexture);
	override public function loadImage(newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):Character
		return cast super.loadImage(newTexture, animated, width, height);
	override public function loadSheet(newTexture:ModPath):Character
		return cast super.loadSheet(newTexture);
	#if ANIMATE_SUPPORT
	override public function loadAtlas(newTexture:ModPath):Character
		return cast super.loadAtlas(newTexture);
	#end

	// TODO: Rename to "id".
	/**
	 * The character key name.
	 */
	public var theirName(default, null):String;
	// TODO: Rename to "iconId".
	/**
	 * The character icon.
	 */
	public var theirIcon(default, null):String = 'face';

	/**
	 * The characters vocal suffix.
	 */
	public var vocalSuffix(default, null):String;
	/**
	 * The vocal tracks that the character can interact with.
	 */
	public var assignedTracks:Array<FlxSound> = [];

	/**
	 * Used to help "singLength".
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The amount of time in steps the animation can be forced to last.
	 * If set to 0, the animation that is played, plays out normally.
	 */
	public var singLength:Float = 2;

	/**
	 * The camera offset position.
	 */
	public var cameraOffset(default, null):Position = new Position();
	/**
	 * Gets the characters camera position.
	 * @param point An optional Position to apply it to. If you put a Position it won't create a new one.
	 * @return Position ~ The camera position.
	 */
	public function getCamPos(?point:Position):Position {
		var midpoint:Position = Position.getObjMidpoint(this);
		var event:PointEvent = new PointEvent(
			midpoint.x + (cameraOffset.x * (flipX ? -1 : 1)),
			midpoint.y + cameraOffset.y
		);
		event.x *= scrollFactor.x;
		event.y *= scrollFactor.y;

		scripts.call('onGetCamPos', [event]);
		return point == null ? new Position(event.x, event.y) : point.set(event.x, event.y);
	}
	/**
	 * Simple group used for rendering the camera position debug visuals.
	 */
	public var cameraDebugVisuals(default, null):CameraDebugCrosshair;

	/**
	 * The characters health bar color.
	 */
	public var healthColor(default, null):FlxColor = FlxColor.GRAY;

	override public function renderData(inputData:SpriteData, applyStartValues:Bool = false):Void {
		var modPath:ModPath = null;
		try {
			modPath = inputData.asset.image;
			if (inputData.character != null) {
				cameraOffset.copyFrom(inputData.character.camera);
				healthColor = inputData.character.color;
				theirIcon = (Paths.icon(inputData.character.icon).isFile ? inputData.character.icon : 'face');
				singLength = inputData.character.singlength;
				vocalSuffix = inputData.character.vocals ?? theirName;
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
		if (file != null && !file.path.isNullOrEmpty())
			bruh.push(file);

		// log([for (file in bruh) file.format()], DebugMessage);

		for (sprite in bruh)
			for (script in Script.create('${sprite.type}:content/objects/${sprite.path}'))
				scripts.add(script);

		scripts.load();
	}

	override public function new(x:Float = 0, y:Float = 0, name:String = 'boyfriend', faceLeft:Bool = false) {
		#if TRACY_DEBUGGER
		if (this.getClassName() == 'Character')
			TracyProfiler.zoneScoped('new Character($x, $y, $name, $faceLeft)');
		#end

		super(x, y, 'characters/${theirName = (Paths.character(name).isFile ? name : 'boyfriend')}');
		if (faceLeft) flipX = !flipX;
		scripts.call('createPost');

		// Camera Position Crosshair System
		cameraDebugVisuals = new CameraDebugCrosshair(() -> getCamPos().toArray());
		cameraDebugVisuals.crosshair.color = cameraDebugVisuals.offScreenArrow.color = healthColor; // indicator of who's crosshair it is
		#if !debug cameraDebugVisuals.visible = debugMode; #end // make certain it always appears when compiling a debug build
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (cameraDebugVisuals != null && cameraDebugVisuals.visible)
			cameraDebugVisuals.update(elapsed);
	}

	override public function draw():Void {
		super.draw();
		if (cameraDebugVisuals != null && cameraDebugVisuals.visible)
			cameraDebugVisuals.draw();
	}

	/**
	 * The animation suffix for singing.
	 */
	public var singSuffix(default, set):String = '';
	inline function set_singSuffix(value:String):String
		return singSuffix = value.trim();

	/**
	 * Only really used for making it so holding a note will prevent idle.
	 */
	@:allow(imaginative.objects.gameplay.arrows.ArrowField.characterSing) var controls:Null<Controls>;

	override public function tryDance():Void {
		switch (animContext) {
			case IsSinging | HasMissed:
				if (singLength > 0 ? (lastHit + (Conductor.song.stepTime * singLength) < Conductor.song.time) : (getAnimName() == null || isAnimFinished())) {
					if (controls != null)
						if (controls.noteLeftHeld || controls.noteDownHeld || controls.noteUpHeld || controls.noteRightHeld)
							return;
					controls = null;
					dance();
				}
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
		cameraDebugVisuals.destroy();
		super.destroy();
	}
}