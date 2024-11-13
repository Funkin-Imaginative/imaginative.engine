package objects;

import flixel.addons.effects.FlxSkewedSprite;

/**
 * Tells you what a sprites current animation is supposed to mean.
 * Idea from Codename Engine.
 * @author Original by @FNF-CNE-Devs, done kinda differenly by @rodney528.
 */
enum abstract AnimContext(String) from String to String {
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

typedef AnimMapping = {
	/**
	 * Offsets for that set animation.
	 */
	@:default({x: 0, y: 0}) var offset:Position;
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
}

/**
 * This class is a verison of FlxSkewedSprite but with animation support among other things.
 */
class BaseSprite extends FlxSkewedSprite implements ITexture<BaseSprite> implements ISelfGroup {
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
	@:unreflective inline function resetTextures(newTexture:ModPath, textureType:TextureType):ModPath {
		textures = [];
		textures.push(new TextureData(FilePath.withoutExtension(newTexture), textureType));
		return newTexture;
	}

	/**
	 * Load's a sheet for the sprite to use.
	 * @param newTexture The mod path.
	 * @return `BaseSprite` ~ Current instance for chaining.
	 */
	public function loadTexture(newTexture:ModPath):BaseSprite {
		final sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
		final textureType:TextureType = TextureType.getTypeFromExt(sheetPath);
		if (Paths.fileExists(Paths.image(newTexture)))
			try {
				if (Paths.spriteSheetExists(newTexture)) return loadSheet(newTexture);
				else return loadImage(newTexture);
			} catch(error:haxe.Exception)
				trace('Couldn\'t find asset "${newTexture.format()}", type "$textureType"');
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
				loadGraphic(resetTextures(Paths.image(newTexture), IsGraphic).format(), animated, width, height);
			} catch(error:haxe.Exception)
				trace('Couldn\'t find asset "${newTexture.format()}", type "${TextureType.IsGraphic}"');
		return this;
	}
	/**
	 * Load's a sheet or graphic texture for the sprite to use based on checks.
	 * @param newTexture The mod path.
	 * @return `BaseSprite` ~ Current instance for chaining.
	 */
	public function loadSheet(newTexture:ModPath):BaseSprite {
		final sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
		final textureType:TextureType = TextureType.getTypeFromExt(sheetPath, true);
		if (Paths.fileExists(Paths.image(newTexture)))
			if (Paths.spriteSheetExists(newTexture))
				try {
					frames = Paths.frames(newTexture, textureType);
					resetTextures(Paths.image(newTexture), textureType);
				} catch(error:haxe.Exception)
				try {
					loadImage(newTexture);
				} catch(error:haxe.Exception)
					trace('Couldn\'t find asset "${newTexture.format()}", type "$textureType"');
			else return loadImage(newTexture);
		return this;
	}

	@SuppressWarnings('checkstyle:FieldDocComment')
	/**
	 * Literally just so
	 * ```haxe
	 * var sprite:BaseSprite = new BaseSprite().makeSolid();
	 * ```
	 * would work.
	 */
	inline public function makeBox<T:BaseSprite>(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String):T
		return cast makeSolid(width, height, color, unique, key);

	// ISelfGroup shenanigans!
	/**
	 * The group inside the sprite.
	 */
	public var group(default, null):BeatSpriteGroup = new BeatSpriteGroup();
	/**
	 * Iterates through every member.
	 * @param filter For filtering.
	 * @return `FlxTypedGroupIterator<FlxSprite>` ~ An iterator.
	 */
	public function iterator(?filter:FlxSprite->Bool):FlxTypedGroupIterator<FlxSprite> return group.iterator(filter);

	/**
	 * Adds a new `FlxSprite` to the group.
	 * @param sprite The sprite or sprite group you want to add to the group.
	 * @return `FlxSprite`
	 */
	public function add(sprite:FlxSprite):FlxSprite return group.add(sprite);
	/**
	 * Adds a new `FlxSprite` behind the main member.
	 * @param sprite The sprite or sprite group you want to add to the group.
	 * @return `FlxSprite`
	 */
	public function addBehind(sprite:FlxSprite):FlxSprite return SpriteUtil.addBehind(sprite, this, cast group);
	/**
	 * Inserts a new `FlxSprite` subclass to the group at the specified position.
	 * @param position The position that the new sprite or sprite group should be inserted at.
	 * @param sprite The sprite or sprite group you want to insert into the group.
	 * @return `FlxSprite` ~ The same object that was passed in.
	 */
	public function insert(position:Int, sprite:FlxSprite):FlxSprite return group.insert(position, sprite);
	/**
	 * Removes the specified sprite from the group.
	 * @param sprite The `FlxSprite` you want to remove.
	 * @param splice Whether the object should be cut from the array entirely or not.
	 * @return `FlxSprite` ~ The removed sprite.
	 */
	public function remove(sprite:FlxSprite, splice:Bool = false):FlxSprite return group.remove(sprite, splice);

	override public function update(elapsed:Float):Void
		group.update(elapsed);
	override public function draw():Void
		group.draw();

	/* override function set_x(value:Float):Float {
		return super.set_x(value);
	}
	override function set_y(value:Float):Float {
		return super.set_y(value);
	}
	override function set_angle(value:Float):Float {
		return super.set_angle(value);
	} */

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
				loadTexture(modPath);
			} catch(error:haxe.Exception)
				trace('Couldn\'t load image "${modPath.format()}", type "${inputData.asset.type}".');

			if (Reflect.hasField(inputData, 'offsets')) {
				spriteOffsets.position.copyFrom(inputData.offsets.position);
				spriteOffsets.flip.copyFrom(inputData.offsets.flip);
				spriteOffsets.scale.copyFrom(inputData.offsets.scale);

				setPosition(spriteOffsets.position.x, spriteOffsets.position.y);
				scale.set(spriteOffsets.scale.x, spriteOffsets.scale.y);
			}

			try {
				for (i => anim in inputData.animations) {
					var subModPath:ModPath = null;
					try {
						var flipping:TypeXY<Bool> = new TypeXY<Bool>(anim.flip.x, anim.flip.y);
						if (spriteOffsets.flip.x) flipping.x = !flipping.x;
						if (spriteOffsets.flip.y) flipping.y = !flipping.y;
						subModPath = anim.asset.image;
						switch (anim.asset.type) {
							case IsUnknown:
								trace('The asset type was unknown! Tip: "${subModPath.format()}"');
							case IsGraphic:
								animation.add(anim.name, anim.indices, anim.fps, anim.loop, flipping.x, flipping.y);
							default:
								if (anim.indices.getDefault([]).length > 0) animation.addByIndices(anim.name, anim.tag, anim.indices, '', anim.fps, anim.loop, flipping.x, flipping.y);
								else animation.addByPrefix(anim.name, anim.tag, anim.fps, anim.loop, flipping.x, flipping.y);
						}
						anims.set(anim.name, {
							offset: new Position(anim.offset.x, anim.offset.y),
							swapName: anim.swapKey.getDefault(''),
							flipName: anim.flipKey.getDefault('')
						});
						if (i == 0) {
							playAnim(anim.name);
							finishAnim();
						}
					} catch(error:haxe.Exception)
						trace('Couldn\'t load animation "${anim.name}", maybe the tag "${anim.tag}" is invaild? The asset is "${subModPath.format()}", type "${anim.asset.type}".');
				}
			} catch(error:haxe.Exception)
				trace('Couldn\'t add the animations.');

			if (applyStartValues) {
				if (Reflect.hasField(inputData, 'starting')) {
					group.setPosition(inputData.starting.position.x, inputData.starting.position.y);
					group.flipX = inputData.starting.flip.x;
					group.flipY = inputData.starting.flip.y;
					group.scale.set(inputData.starting.scale.x, inputData.starting.scale.y);
					group.updateHitbox();
				}
			}

			swapAnimTriggers = inputData.swapAnimTriggers;
			flipAnimTrigger = inputData.flipAnimTrigger;
			antialiasing = inputData.antialiasing;

			if (Reflect.hasField(inputData, 'extra') && inputData.extra != null) {
				try {
					if (inputData.extra.length > 1)
						for (extraData in inputData.extra)
							extra.set(extraData.name, extraData.data);
				} catch(error:haxe.Exception) trace('Invaild information in extra array or the null check failed.');
			}
		} catch(error:haxe.Exception) {
			try {
				trace('Something went wrong. All try statements were bypassed! Tip: "${modPath.format()}"');
			} catch(error:haxe.Exception) trace('Something went wrong. All try statements were bypassed! Tip: "null"');
		}
	}

	/**
	 * A map holding data for each animation.
	 */
	public var anims:Map<String, AnimMapping> = new Map<String, AnimMapping>();
	/**
	 * The current animation context.
	 */
	public var animContext:AnimContext;
	/**
	 * Global offsets
	 */
	public var spriteOffsets:ObjectData = {
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
	public function loadScript(file:ModPath):Void {
		scripts = new ScriptGroup(this);

		var bruh:Array<ModPath> = ['global', file];
		for (sprite in bruh)
			for (script in Script.create('${sprite.type}:content/objects/${sprite.path}'))
				scripts.add(script);

		scripts.load();
	}

	/* override function initVars():Void {
		super.initVars();

		flixelType = SPRITEGROUP;

		@:privateAccess {
			offset = new FlxCallbackPoint(group.offsetCallback);
			origin = new FlxCallbackPoint(group.originCallback);
			scale = new FlxCallbackPoint(group.scaleCallback);
			scrollFactor = new FlxCallbackPoint(group.scrollFactorCallback);
		}

		scale.set(1, 1);
		scrollFactor.set(1, 1);

		initMotionVars();
	} */

	override public function new(x:Float = 0, y:Float = 0, ?sprite:OneOfTwo<String, SpriteData>, ?script:ModPath, applyStartValues:Bool = false) {
		super();

		if (sprite is String) {
			var file:ModPath = ModPath.fromString(sprite);
			if (Paths.fileExists(Paths.object(file))) {
				loadScript(script != null ? file.format() : '${file.type}:${script.path}');
				renderData(ParseUtil.object(file, type), applyStartValues);
			} else loadTexture(file);
		} else renderData(sprite, applyStartValues);

		if (scripts == null)
			loadScript(script != null ? script : '');
		scripts.call('create');

		add(this);
		setPosition(x + spriteOffsets.position.x, y + spriteOffsets.position.y);
		group.setPosition(x, y);

		if (this is BaseSprite || this is BeatSprite)
			scripts.call('createPost');
	}

	/**
	 * Used to help with `ISelfGroup` updating conflicts.
	 * This will be used to update the sprite itself.
	 * While update now updates the group instead.
	 * @param elapsed Time inbetween frames.
	 */
	public function selfUpdate(elapsed:Float):Void {
		if (!(this is IBeat)) scripts.call('update', [elapsed]);
		super.update(elapsed);
		scripts.call('updatePost', [elapsed]);
		if (_update != null) _update(elapsed);
	}

	/**
	 * The general animation suffix.
	 * Though this is the global one and always will be overwritten by the local one.
	 */
	public var animSuffix(default, set):String = '';
	inline function set_animSuffix(value:String):String
		return animSuffix = value.trim();

	inline function invaildSuffixCheck(name:String, suffix:String):Bool
		return doesAnimExist('$name-${suffix.trim()}', true);

	function generalSuffixCheck(context:AnimContext):String {
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
	inline public function playAnim(name:String, force:Bool = true, context:AnimContext = Unclear, ?suffix:String, reverse:Bool = false, frame:Int = 0):Void {
		var theName:String = name;
		theName = ((swapAnimTriggers && flipX) && doesAnimExist(getAnimInfo(theName).swapName, true)) ? getAnimInfo(theName).swapName : theName;
		theName = (flipAnimTrigger == flipX && doesAnimExist(getAnimInfo(theName).flipName, true)) ? getAnimInfo(theName).flipName : theName;

		final suffixResult:String = suffix == null ? '' : (invaildSuffixCheck(theName, suffix.trim()) ? '-${suffix.trim()}' : (invaildSuffixCheck(theName, generalSuffixCheck(context)) ? '-${generalSuffixCheck(context)}' : ''));
		theName = '$theName${suffixResult.trim()}';
		if (doesAnimExist(theName, true)) {
			final animInfo:AnimMapping = getAnimInfo(theName);
			animation.play(theName, force, reverse, frame);
			frameOffset.set(animInfo.offset.x, animInfo.offset.y);
			animContext = context;
		}
	}
	/**
	 * Get's the name of the currently playing animation.
	 * The arguments are to reverse the name.
	 * @param ignoreSwap If true, it won't use the swap name.
	 * @param ignoreFlip If true, it won't use the flip name.
	 * @return `Null<String>` The animation name.
	 */
	inline public function getAnimName(ignoreSwap:Bool = true, ignoreFlip:Bool = false):Null<String> {
		if (animation.name != null) {
			var targetAnim:String = animation.name;
			if (!ignoreSwap) targetAnim = ((swapAnimTriggers && flipX) && doesAnimExist(targetAnim, true)) ? (getAnimInfo(targetAnim).swapName == '' ? targetAnim : getAnimInfo(targetAnim).swapName) : targetAnim;
			if (!ignoreFlip) targetAnim = (flipAnimTrigger == flipX && doesAnimExist(targetAnim, true)) ? (getAnimInfo(targetAnim).flipName == '' ? targetAnim : getAnimInfo(targetAnim).flipName) : targetAnim;
			return targetAnim;
		}
		return null;
	}
	/**
	 * Get's information on a set animation of your choosing.
	 * This way you won't have to worry about certain things.
	 * @param name The animation name.
	 * @return `AnimMapping` ~ The animation information.
	 */
	inline public function getAnimInfo(name:String):AnimMapping {
		var data:AnimMapping;
		if (doesAnimExist(name, true))
			if (anims.exists(name))
				data = anims.get(name);
			else
				data = {offset: new Position(), swapName: '', flipName: ''}
		else
			data = {offset: new Position(), swapName: '', flipName: ''}
		return data;
	}
	/**
	 * Tells you if the animation has finished playing.
	 * @return `Bool`
	 */
	inline public function isAnimFinished():Bool return (animation == null || animation.curAnim == null) ? false : animation.curAnim.finished;
	/**
	 * When run, it forces the animation to finish.
	 */
	inline public function finishAnim():Void
		if (animation.curAnim != null)
			animation.curAnim.finish();
	/**
	 * Check's if the animation exists.
	 * @param name The animation name to check.
	 * @param inGeneral If false, it only checks if the animation is listed in the map.
	 * @return `Bool`
	 */
	inline public function doesAnimExist(name:String, inGeneral:Bool = false):Bool {
		return inGeneral ? animation.exists(name) : (animation.exists(name) && anims.exists(name));
	}

	// make offset flipping look not broken, and yes cne also does this
	var __offsetFlip:Bool = false;

	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__offsetFlip) {
			scale.x *= -1;
			final bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
	}

	/**
	 * Used to help with `ISelfGroup` drawing conflicts.
	 * This will be used to draw the sprite itself.
	 * While draw now draws the group instead.
	 */
	public function selfDraw():Void {
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

	override public function destroy():Void {
		scripts.end();
		super.destroy();
	}
}