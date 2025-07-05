package imaginative.objects;

import flixel.addons.effects.FlxSkewedSprite;
import imaginative.animation.BetterAnimation;
import imaginative.animation.BetterAnimationController;

/**
 * Tells you what a sprites current animation is supposed to mean.
 * Idea from Codename Engine.
 * @author Original by @CodenameCrew, done kinda differently by @rodney528.
 */
enum abstract AnimationContext(String) from String to String {
	/**
	 * States that the object animation is related to dancing.
	 */
	var IsDancing;

	/**
	 * States that the object animation is related to singing.
	 */
	var IsSinging;
	/**
	 * States that the object animation is related to missing a note.
	 */
	var HasMissed;

	/**
	 * States that the object animation can't go back to dancing.
	 */
	var NoDancing;
	/**
	 * States that the object animation can't go back to singing.
	 */
	var NoSinging;

	/**
	 * States that the object animation is unclear.
	 */
	var Unclear;
}

typedef AnimationMapping = {
	/**
	 * Swapped name for that set animation.
	 * Ex: singLEFT to singRIGHT
	 */
	@:default('') var swapName:String;
	/**
	 * Flipped name for that set animation.
	 * Useful for characters that may off design when flipped!
	 * Basically it's good for asymmetrical characters.
	 */
	@:default('') var flipName:String;
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	var extra:Map<String, Dynamic>;
}

/**
 * This class is a version of FlxSkewedSprite but with animation support among other things.
 */
class BaseSprite extends FlxSkewedSprite implements ITexture<BaseSprite> {
	// Cool variables.
	/**
	 * Custom update function.
	 */
	public var _update:Float->Void;
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
	/**
	 * Used for editors to prevent the sprites natural functions.
	 * Mostly used for editors.
	 */
	public var debugMode:Bool = false;

	// Texture related stuff.
	/**
	 * The main texture the sprite is using.
	 */
	public var texture(get, never):TextureData;
	inline function get_texture():TextureData
		return textures[0];
	/**
	 * All textures the sprite is using.
	 */
	public var textures(default, null):Array<TextureData> = [];
	@:unreflective inline function resetTextures(newTexture:ModPath, textureType:TextureType):Void {
		textures = [];
		textures.push(new TextureData(FilePath.withoutExtension(newTexture), textureType));
	}

	/**
	 * Load's a sheet for the sprite to use.
	 * @param newTexture The mod path.
	 * @return `BaseSprite` ~ Current instance for chaining.
	 */
	public function loadTexture(newTexture:ModPath):BaseSprite {
		var sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
		var textureType:TextureType = TextureType.getTypeFromExt(sheetPath);
		if (Paths.fileExists(Paths.image(newTexture)))
			try {
				if (Paths.spriteSheetExists(newTexture)) return loadSheet(newTexture);
				else return loadImage(newTexture);
			} catch(error:haxe.Exception)
				log('Couldn\'t find asset "${newTexture.format()}", type "$textureType"', WarningMessage);
		return this;
	}
	/**
	 * Load's a graphic texture for the sprite to use.
	 * @param newTexture The mod path.
	 * @param animated Whether the graphic should be the sprite cut into a grid.
	 * @param width Grid width.
	 * @param height Grid height.
	 * @return `BaseSprite` ~ Current instance for chaining.
	 */
	public function loadImage(newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):BaseSprite {
		if (Paths.fileExists(Paths.image(newTexture)))
			try {
				loadGraphic(Assets.image(newTexture), width < 1 || height < 1 ? false : animated, width, height);
				resetTextures(Paths.image(newTexture), IsGraphic);
			} catch(error:haxe.Exception)
				log('Couldn\'t find asset "${newTexture.format()}", type "${TextureType.IsGraphic}"', WarningMessage);
		return this;
	}
	/**
	 * Load's a sheet or graphic texture for the sprite to use based on checks.
	 * @param newTexture The mod path.
	 * @return `BaseSprite` ~ Current instance for chaining.
	 */
	public function loadSheet(newTexture:ModPath):BaseSprite {
		var sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
		var textureType:TextureType = TextureType.getTypeFromExt(sheetPath, true);
		if (Paths.fileExists(Paths.image(newTexture)))
			if (Paths.spriteSheetExists(newTexture))
				try {
					frames = Assets.frames(newTexture, textureType);
					resetTextures(Paths.image(newTexture), textureType);
				} catch(error:haxe.Exception)
					try {
						loadImage(newTexture);
					} catch(error:haxe.Exception)
						log('Couldn\'t find asset "${newTexture.format()}", type "$textureType"', WarningMessage);
			else return loadImage(newTexture);
		return this;
	}

	// Where the BaseSprite class really begins.
	/**
	 * States the type of sprite this is.
	 */
	public var type(get, never):SpriteType;
	function get_type():SpriteType {
		return switch (this.getClassName()) {
			case 'Character':  	IsCharacterSprite;
			case 'HealthIcon': 	IsHealthIcon;
			case 'BeatSprite': 	IsBeatSprite;
			case 'BaseSprite': 	IsBaseSprite;
			default:          	IsUnidentified;
		}
	}
	/**
	 * Renders the sprites data variables.
	 * @param inputData The data input.
	 * @param applyStartValues Whether or not to apply the start values.
	 */
	public function renderData(inputData:SpriteData, applyStartValues:Bool = false):Void {
		var modPath:ModPath = null;
		try {
			modPath = inputData.asset.image;
			try {
				if (inputData.asset.type == IsGraphic)
					loadImage(modPath, true, inputData.asset.dimensions.x, inputData.asset.dimensions.y);
				else loadTexture(modPath);
			} catch(error:haxe.Exception)
				log('Couldn\'t load image "${modPath.format()}", type "${inputData.asset.type}".', ErrorMessage);

			if (Reflect.hasField(inputData, 'offsets')) {
				spriteOffsets.position.copyFrom(inputData.offsets.position);
				spriteOffsets.flip.copyFrom(inputData.offsets.flip);
				spriteOffsets.scale.copyFrom(inputData.offsets.scale);

				offset.set(spriteOffsets.position.x, spriteOffsets.position.y);
				scale.set(spriteOffsets.scale.x, spriteOffsets.scale.y);
				updateHitbox();
			}

			try {
				for (i => anim in inputData.animations) {
					try {
						var flipping:TypeXY<Bool> = new TypeXY<Bool>(anim.flip.x, anim.flip.y);
						if (spriteOffsets.flip.x) flipping.x = !flipping.x;
						if (spriteOffsets.flip.y) flipping.y = !flipping.y;
						switch (inputData.asset.type) {
							case IsGraphic:
								animation.add(anim.name, anim.indices, anim.fps, anim.loop, flipping.x, flipping.y);
							case IsSparrow | IsPacker | IsAseprite:
								if ((anim.indices ?? []).length > 0) animation.addByIndices(anim.name, anim.tag, anim.indices, '', anim.fps, anim.loop, flipping.x, flipping.y);
								else animation.addByPrefix(anim.name, anim.tag, anim.fps, anim.loop, flipping.x, flipping.y);
							default:
								log('The asset type was unknown! Tip: "${modPath.format()}"', WarningMessage);
						}
						setAnimationOffset(anim.name, anim.offset.x, anim.offset.y);
						anims.set(anim.name, {
							swapName: anim.swapKey ?? '',
							flipName: anim.flipKey ?? '',
							extra: new Map<String, Dynamic>()
						});
						if (i == 0) {
							playAnim(anim.name);
							finishAnim();
						}
					} catch(error:haxe.Exception)
						log('Couldn\'t load animation "${anim.name}", maybe the tag "${anim.tag}" is invalid? The asset is "${modPath.format()}", type "${inputData.asset.type}".', ErrorMessage);
				}
			} catch(error:haxe.Exception)
				log('Couldn\'t add the animations.', WarningMessage);

			if (applyStartValues) {
				if (Reflect.hasField(inputData, 'starting')) {
					setPosition(inputData.starting.position.x, inputData.starting.position.y);
					flipX = inputData.starting.flip.x;
					flipY = inputData.starting.flip.y;
					scale.set(spriteOffsets.scale.x, spriteOffsets.scale.y);
					scale.scale(inputData.starting.scale.x, inputData.starting.scale.y);
					updateHitbox();
				}
			}

			swapAnimTriggers = inputData.swapAnimTriggers;
			flipAnimTrigger = inputData.flipAnimTrigger;
			antialiasing = inputData.antialiasing;

			if (Reflect.hasField(inputData, 'extra') && inputData.extra != null) {
				try {
					if (!inputData.extra.empty())
						for (extraData in inputData.extra)
							extra.set(extraData.name, extraData.data);
				} catch(error:haxe.Exception)
					log('Invalid information in extra array or the null check failed.', ErrorMessage);
			}
		} catch(error:haxe.Exception) {
			try {
				log('Something went wrong. All try statements were bypassed! Tip: "${modPath.format()}"', ErrorMessage);
			} catch(error:haxe.Exception)
				log('Something went wrong. All try statements were bypassed! Tip: "null"', ErrorMessage);
		}
	}

	/**
	 * A map holding data for each animation.
	 */
	public var anims:Map<String, AnimationMapping> = new Map<String, AnimationMapping>();
	/**
	 * The current animation context.
	 */
	public var animContext:AnimationContext;
	/**
	 * Global offsets
	 */
	public var spriteOffsets:ObjectSetupData = {
		position: new Position(),
		flip: new TypeXY<Bool>(false, false),
		scale: new Position()
	}
	/**
	 * If true, the swap anim var can go off.
	 * For characters and icons it always on.
	 */
	public var swapAnimTriggers(get, null):Bool = false;
	function get_swapAnimTriggers():Bool
		return swapAnimTriggers;
	/**
	 * States which flipX state the sprite must be in to trigger the flip anim var.
	 */
	public var flipAnimTrigger(default, null):Bool = true;

	/**
	 * The sprites internal scripts.
	 */
	public var scripts:ScriptGroup;
	/**
	 * Loads the internal sprite scripts.
	 * @param file The mod path.
	 */
	function loadScript(file:ModPath):Void {
		scripts = new ScriptGroup(this);

		var bruh:Array<ModPath> = ['lead:global'];
		if (file != null && !file.path.isNullOrEmpty())
			bruh.push(file);

		for (sprite in bruh)
			for (script in Script.create('${sprite.type}:content/objects/${sprite.path}'))
				scripts.add(script);

		scripts.load();
	}

	override public function new(x:Float = 0, y:Float = 0, ?sprite:OneOfTwo<String, SpriteData>, ?script:ModPath, applyStartValues:Bool = false) {
		#if TRACY_DEBUGGER
		if (this.getClassName() == 'BaseSprite')
			TracyProfiler.zoneScoped('new BaseSprite($x, $y, $sprite, $script, $applyStartValues)');
		#end

		super(x, y);
		if (sprite is String) {
			var file:ModPath = ModPath.fromString(sprite);
			if (Paths.fileExists(Paths.object(file))) {
				loadScript(script != null ? file : '${file.type}:${script.path}');
				renderData(ParseUtil.object(file, type), applyStartValues);
			} else loadTexture(file);
		} else renderData(sprite, applyStartValues);

		if (scripts == null)
			loadScript(script);

		animation.onFinish.add((name:String) -> {
			if (doesAnimExist('$name-loop', true))
				playAnim('$name-loop');
			if (doesAnimExist('$name-end', true))
				playAnim('$name-end');
		});

		scripts.call('create');
		if (this is BaseSprite || this is BeatSprite)
			scripts.call('createPost');
	}

	override function initVars():Void {
		super.initVars();
		_scaledFrameOffset = new FlxPoint();
		animation = new BetterAnimationController(this);
	}

	function super_update(elapsed:Float):Void
		super.update(elapsed);
	override public function update(elapsed:Float):Void {
		scripts.call('update', [elapsed]);
		super.update(elapsed);
		if (_update != null)
			_update(elapsed);
		scripts.call('updatePost', [elapsed]);
	}

	/**
	 * The general animation suffix.
	 * Though this is the global one and always will be overwritten by the local one.
	 */
	public var animSuffix(default, set):String = '';
	inline function set_animSuffix(value:String):String
		return animSuffix = value.trim();

	inline function invalidSuffixCheck(name:String, suffix:String):Bool
		return doesAnimExist('$name-${suffix.trim()}', true);

	function generalSuffixCheck(context:AnimationContext):String {
		return switch (context) {
			default:
				animSuffix;
		}
	}

	/**
	 * Play's an animation.
	 * @param name The animation name.
	 * @param force If true, the game won't care if another one is already playing.
	 * @param context The context for the upcoming animation.
	 * @param suffix The animation suffix.
	 * @param reverse If true, the animation will play backwards.
	 * @param frame The starting frame. By default it's 0.
	 *              Although if reversed it will use the last frame instead.
	 */
	public function playAnim(name:String, force:Bool = true, context:AnimationContext = Unclear, ?suffix:String, reverse:Bool = false, frame:Int = 0):Void {
		var theName:String = name;
		if (type == IsCharacterSprite)
			theName = '$theName${context == HasMissed ? 'miss' : ''}';
		theName = ((swapAnimTriggers && flipX) && doesAnimExist(getAnimInfo(theName).swapName, true)) ? getAnimInfo(theName).swapName : theName;
		theName = (flipAnimTrigger == flipX && doesAnimExist(getAnimInfo(theName).flipName, true)) ? getAnimInfo(theName).flipName : theName;

		var suffixResult:String = suffix == null ? '' : (invalidSuffixCheck(theName, suffix.trim()) ? '-${suffix.trim()}' : (invalidSuffixCheck(theName, generalSuffixCheck(context)) ? '-${generalSuffixCheck(context)}' : ''));
		theName = '$theName${suffixResult.trim()}';
		if (doesAnimExist(theName, true)) {
			animation.play(theName, force, reverse, frame);
			animContext = context;
		}
	}
	/**
	 * Get's the name of the currently playing animation.
	 * The arguments are to reverse the name.
	 * @param ignoreSwap If true, it won't use the swap name.
	 * @param ignoreFlip If true, it won't use the flip name.
	 * @return `Null<String>` ~ The animation name.
	 */
	inline public function getAnimName(ignoreSwap:Bool = true, ignoreFlip:Bool = false):Null<String> {
		if (animation.name != null) {
			var targetAnim:String = animation.name;
			if (!ignoreSwap) targetAnim = ((swapAnimTriggers && flipX) && doesAnimExist(targetAnim, true)) ? (getAnimInfo(targetAnim).swapName.isNullOrEmpty() ? targetAnim : getAnimInfo(targetAnim).swapName) : targetAnim;
			if (!ignoreFlip) targetAnim = (flipAnimTrigger == flipX && doesAnimExist(targetAnim, true)) ? (getAnimInfo(targetAnim).flipName.isNullOrEmpty() ? targetAnim : getAnimInfo(targetAnim).flipName) : targetAnim;
			return targetAnim;
		}
		return null;
	}
	/**
	 * Get's information on a set animation of your choosing.
	 * This way you won't have to worry about certain things.
	 * @param name The animation name.
	 * @return `AnimationMapping` ~ The animation information.
	 */
	inline public function getAnimInfo(name:String):AnimationMapping {
		var data:AnimationMapping;
		if (doesAnimExist(name, true))
			if (anims.exists(name))
				data = anims.get(name);
			else
				data = {swapName: '', flipName: '', extra: new Map<String, Dynamic>()}
		else
			data = {swapName: '', flipName: '', extra: new Map<String, Dynamic>()}
		return data;
	}
	/**
	 * Tells you if the animation has finished playing.
	 * @return `Bool`
	 */
	inline public function isAnimFinished():Bool
		return animation.finished;
	/**
	 * When run, it forces the animation to finish.
	 */
	inline public function finishAnim():Void
		animation.finished = true;
	/**
	 * Check's if the animation exists.
	 * @param name The animation name to check.
	 * @param inGeneral If false, it only checks if the animation is listed in the map.
	 * @return `Bool` ~ If true, the animation exists.
	 */
	inline public function doesAnimExist(name:String, inGeneral:Bool = false):Bool {
		return inGeneral ? animation.exists(name) : (animation.exists(name) && anims.exists(name));
	}

	// make offset flipping look not broken, and yes cne also does this
	var __offsetFlip:Bool = false;
	override public function draw():Void {
		if (swapAnimTriggers) {
			var xFlip:Bool = flipX;
			if (xFlip) {
				__offsetFlip = true;

				flipX = !flipX;
				scale.x *= -1;
				super.draw();
				flipX = !flipX;
				scale.x *= -1;

				__offsetFlip = false;
			} else super.draw();
			flipX = xFlip;
		} else super.draw();
	}

	/**
	 * Sets the offsets for an animation.
	 * @param name The animation name.
	 * @param x The x offset.
	 * @param y The y offset.
	 */
	public function setAnimationOffset(name:String, x:Float = 0, y:Float = 0):Void {
		var anim:BetterAnimation = cast animation.getByName(name);
		if (anim != null && anim is BetterAnimation) // jic
			anim.offset.set(x, y);
	}
	/**
	 * Gets the offsets for an animation.
	 * @param name The animation name.
	 * @return `Position` ~ The animation offset.
	 */
	public function getAnimationOffset(?name:String):Position {
		var anim:BetterAnimation = cast animation.getByName(name ?? getAnimName(false));
		if (anim == null || !(anim is BetterAnimation)) return new Position();
		return Position.fromFlxPoint(anim.offset) ?? new Position();
	}

	// for animation offsets
	var _scaledFrameOffset:FlxPoint;
	function _getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		var betterRect:BetterRect = cast newRect ??= FlxRect.get();
		camera ??= FlxG.camera;
		betterRect.setPosition(x, y);
		if (pixelPerfectPosition) betterRect.floor();

		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
		_scaledFrameOffset.set(getAnimationOffset().x * scale.x, getAnimationOffset().y * scale.y);
		betterRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x;
		betterRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y;

		if (isPixelPerfectRender(camera)) betterRect.floor();
		betterRect.setSize(frameWidth * Math.abs(scale.x), frameHeight * Math.abs(scale.y));
		return betterRect.newGetRotatedBounds(angle, _scaledOrigin, betterRect, _scaledFrameOffset);
	}
	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__offsetFlip) {
			scale.x *= -1;
			var bounds = _getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return _getScreenBounds(newRect, camera);
	}

	override function drawComplex(camera:FlxCamera):Void {
		_frame.prepareMatrix(_matrix, flixel.graphics.frames.FlxFrame.FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.translate(-getAnimationOffset().x, -getAnimationOffset().y);
		_matrix.scale(scale.x, scale.y);

		if (matrixExposed)

			_matrix.concat(transformMatrix);

		else {
			if (bakedRotationAngle <= 0) {
				updateTrig();
				if (angle != 0)
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}

			updateSkewMatrix();
			_matrix.concat(_skewMatrix);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera)) {
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	override public function destroy():Void {
		scripts.end();
		_scaledFrameOffset.put();
		super.destroy();
	}
}

class BetterRect extends FlxRect {
	public function newGetRotatedBounds(degrees:Float, ?origin:FlxPoint, ?newRect:FlxRect, ?innerOffset:FlxPoint):FlxRect {
		origin ??= FlxPoint.weak();
		newRect ??= FlxRect.get();
		innerOffset ??= FlxPoint.weak();

		degrees = degrees % 360;
		if (degrees == 0) {
			newRect.set(x - innerOffset.x, y - innerOffset.y, width, height);
			origin.putWeak();
			innerOffset.putWeak();
			return newRect;
		}

		if (degrees < 0)
			degrees += 360;

		var radians = FlxAngle.TO_RAD * degrees;
		var cos = Math.cos(radians);
		var sin = Math.sin(radians);

		var left = -origin.x - innerOffset.x;
		var top = -origin.y - innerOffset.y;
		var right = -origin.x + width - innerOffset.x;
		var bottom = -origin.y + height - innerOffset.y;
		if (degrees < 90) {
			newRect.x = x + origin.x + cos * left - sin * bottom;
			newRect.y = y + origin.y + sin * left + cos * top;
		} else if (degrees < 180) {
			newRect.x = x + origin.x + cos * right - sin * bottom;
			newRect.y = y + origin.y + sin * left + cos * bottom;
		} else if (degrees < 270) {
			newRect.x = x + origin.x + cos * right - sin * top;
			newRect.y = y + origin.y + sin * right + cos * bottom;
		} else {
			newRect.x = x + origin.x + cos * left - sin * top;
			newRect.y = y + origin.y + sin * right + cos * top;
		}
		// temp var, in case input rect is the output rect
		var newHeight = Math.abs(cos * height) + Math.abs(sin * width);
		newRect.width = Math.abs(cos * width) + Math.abs(sin * height);
		newRect.height = newHeight;

		origin.putWeak();
		innerOffset.putWeak();
		return newRect;
	}
}