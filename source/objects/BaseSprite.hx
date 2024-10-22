package objects;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.math.FlxRect;

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

/**
 * The texture typing of a spritesheet.
 */
enum abstract TextureType(String) from String to String {
	/**
	 * States that this sprite uses a sparrow sheet method.
	 */
	var isSparrow = 'Sparrow';
	/**
	 * States that this sprite uses a packer sheet method.
	 */
	var isPacker = 'Packer';
	/**
	 * States that this sprite uses a single image, grid system method.
	 */
	var isGraphic = 'Graphic';
	/**
	 * States that this sprite uses an sheet made in the aseprite pixel art software.
	 */
	var isAseprite = 'Aseprite';
	/**
	 * States that this sprite method is unknown.
	 */
	var isUnknown = 'Unknown';

	/**
	 * Get's the file extension from texture type.
	 * @param type The texture type.
	 * @return `String` ~ File extension.
	 */
	inline public static function getExtFromType(type:TextureType):String {
		return switch (type) {
			case isSparrow: 'xml';
			case isPacker: 'txt';
			case isAseprite: 'json';
			case isGraphic: 'png';
			default: isUnknown;
		}
	}
	/**
	 * Get's the method based on file extension.
	 * @param sheetPath The path of the sheet data type.
	 * @param defaultIsUnknown If default should be recognized as unknown instead of a graphic.
	 * @return `TextureType`
	 */
	inline public static function getTypeFromExt(sheetPath:String, defaultIsUnknown:Bool = false):TextureType {
		return switch (FilePath.extension(sheetPath)) {
			case 'xml': isSparrow;
			case 'txt': isPacker;
			case 'json': isAseprite;
			case 'png': isGraphic;
			default: defaultIsUnknown ? isUnknown : isGraphic;
		}
	}
}

/**
 * Gives details about a texture a sprite uses.
 */
class TextureData {
	/**
	 * The root path of the image.
	 */
	public var image(default, null):String;
	/**
	 * The sheet method used.
	 */
	public var type(default, null):TextureType;
	/**
	 * The mod path type.
	 */
	public var path(get, never):FunkinPath;
	inline function get_path():FunkinPath
		return FunkinPath.typeFromPath(image);

	public function new(image:String, type:TextureType) {
		this.image = image;
		this.type = type;
	}

	public function toString():String
		return '{image => $image, type => $type, path => $path}';
}

typedef OffsetsData = {
	/**
	 * Offset position.
	 */
	@:optional var position:PositionStruct;
	/**
	 * Offset flip, is applied through the animations flip values.
	 */
	@:optional var flip:TypeXY<Bool>;
	/**
	 * Size multiplier.
	 */
	@:optional var scale:PositionStruct;
}

typedef AssetTyping = {
	/**
	 * Root image path.
	 */
	var image:String;
	/**
	 * Texture type.
	 */
	var type:TextureType;
}
typedef AnimationTyping = {
	/**
	 * The asset typing.
	 */
	@:optional var asset:AssetTyping;
	/**
	 * Name of the animation.
	 */
	var name:String;
	/**
	 * Animation key on data method.
	 */
	@:optional var tag:String;
	/**
	 * Height and width dimensions.
	 * Only if texture type is a graphic.
	 */
	@:optional @:default({x: 1, y: 1}) var dimensions:TypeXY<Int>;
	/**
	 * The specified frames to use in the animation.
	 * For graphic's this is the specified as the frames array in the add function.
	 */
	@:default([]) var indices:Array<Int>;
	/**
	 * The offset for the set animation.
	 */
	@:default({x: 0, y: 0}) var offset:PositionStruct;
	/**
	 * The flip offset for the set animation.
	 */
	@:default({x: false, y: false}) var flip:TypeXY<Bool>;
	/**
	 * If true, the animation loops.
	 */
	@:default(false) var loop:Bool;
	/**
	 * The framerate of the animation.
	 */
	@:default(24) var fps:Int;
}

typedef ObjectData = {
	> OffsetsData,
	/**
	 * The asset typing.
	 */
	var asset:AssetTyping;
	/**
	 * The animations for a given sprite.
	 */
	var animations:Array<AnimationTyping>;
	/**
	 * Should antialiasing be enabled?
	 */
	@:default(true) var antialiasing:Bool;
}

/**
 * This class is a verison of FlxSkewedSprite but with animation support among other things.
 */
class BaseSprite extends FlxSkewedSprite #if IGROUP_INTERFACE implements IGroup #end {
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
	 * Used for editors to prevent the sprites natural functions
	 */
	public var debugMode:Bool = false;

	// Texture related stuff.
	/**
	 * The main texture the sprite is using.
	 */
	public var texture(get, never):TextureData;
	inline function get_texture():TextureData return textures[0];
	/**
	 * All textures the sprite is using.
	 */
	public var textures(default, null):Array<TextureData>;
	@:unreflective inline function resetTextures(newTexture:String, spriteType:TextureType):String {
		textures = [];
		textures.push(new TextureData(FilePath.withoutExtension(newTexture), spriteType));
		return newTexture;
	}

	/**
	 * Load's a sheet for the sprite to use.
	 * @param newTexture The texture mod path.
	 * @return `BaseSprite` ~ Current instance for chaining.
	 */
	inline public function loadTexture<T:BaseSprite>(newTexture:String):T {
		final sheetPath:String = Paths.multExst('images/$newTexture', Paths.atlasFrameExts);
		final textureType:TextureType = TextureType.getTypeFromExt(sheetPath);
		if (Paths.fileExists('images/$newTexture.png'))
			try {
				if (Paths.spriteSheetExists(newTexture)) loadSheet(newTexture);
				else loadImage(newTexture);
			} catch(error:haxe.Exception) trace('Couldn\'t find asset "$newTexture", type "$textureType"');
		return cast this;
	}
	/**
	 * Load's a graphic texture for the sprite to use.
	 * @param newTexture The texture mod path.
	 * @return `BaseSprite` ~ Current instance for chaining.
	 */
	inline public function loadImage<T:BaseSprite>(newTexture:String):T {
		if (Paths.fileExists('images/$newTexture.png'))
			try {
				loadGraphic(resetTextures(Paths.image(newTexture), 'graphic'));
			} catch(error:haxe.Exception) trace('Couldn\'t find asset "$newTexture", type "${TextureType.isGraphic}"');
		return cast this;
	}
	/**
	 * Load's a sheet or graphic texture for the sprite to use based on checks.
	 * @param newTexture The texture mod path.
	 * @return `BaseSprite` ~ Current instance for chaining.
	 */
	inline public function loadSheet<T:BaseSprite>(newTexture:String):T {
		final sheetPath:String = Paths.multExst('images/$newTexture', Paths.atlasFrameExts);
		final textureType:TextureType = TextureType.getTypeFromExt(sheetPath, true);
		if (Paths.fileExists('images/$newTexture.png')) {
			if (Paths.spriteSheetExists(newTexture))
				try {
					frames = Paths.frames(newTexture);
					resetTextures(Paths.applyRoot('images/$newTexture.png'), textureType);
				} catch(error:haxe.Exception) trace('Couldn\'t find asset "$newTexture", type "$textureType"');
			else loadImage(newTexture);
		}
		return cast this;
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

	#if IGROUP_INTERFACE
	// IGroup shenanigans!
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

	override function set_x(value:Float):Float {
		try {
			return super.set_x(value + data.offsets.position.x.getDefault(0));
		} catch(error:haxe.Exception)
			return super.set_x(value);
	}
	override function set_y(value:Float):Float {
		try {
			return super.set_y(value + data.offsets.position.y.getDefault(0));
		} catch(error:haxe.Exception)
			return super.set_y(value);
	}
	/* override function set_angle(value:Float):Float {
		return super.set_angle(value);
	} */
	#end

	// Where the BaseSprite class really begins.
	/**
	 * The sprite data.
	 */
	public var data:SpriteData = null;
	/**
	 * Another way to create a BaseSprite. But you can set the root this time.
	 * @param x Starting x position.
	 * @param y Starting y position.
	 * @param path The mod path.
	 * @param pathType The path type.
	 * @return `BaseSprite`
	 */
	public static function makeSprite(x:Float = 0, y:Float = 0, path:String, pathType:FunkinPath = ANY):BaseSprite {
		return new BaseSprite(x, y, ParseUtil.object(path, isBaseSprite, pathType), Paths.script(path, pathType));
	}
	/**
	 * States the type of sprite this is.
	 */
	public var type(get, never):SpriteType;
	function get_type():SpriteType {
		return switch (this.getClassName()) {
			case 'Character':  	isCharacterSprite;
			case 'HealthIcon': 	isHealthIcon;
			case 'BeatSprite': 	isBeatSprite;
			case 'BaseSprite': 	isBaseSprite;
			default:          	isUnidentified;
		}
	}
	/**
	 * Renders the sprites data variables.
	 * @param inputData The data input.
	 */
	public function renderData(inputData:TypeSpriteData):Void {
		final incomingData:SpriteData = cast inputData;
		try {
			try {
				loadTexture(incomingData.asset.image);
			} catch(error:haxe.Exception) trace('Couldn\'t load image "${incomingData.asset.image}", type "${incomingData.asset.type}".');

			try {
				for (anim in incomingData.animations)
					try {
						switch (anim.asset.type) {
							case isUnknown:
								trace('The asset type was unknown! Tip: "${incomingData.asset.image}"');
							case isGraphic:
								animation.add(anim.name, anim.indices, anim.fps, anim.loop, anim.flip.x, anim.flip.y);
							default:
								if (anim.indices != null && anim.indices.length > 0) animation.addByIndices(anim.name, anim.tag, anim.indices, '', anim.fps, anim.loop, anim.flip.x, anim.flip.y);
								else animation.addByPrefix(anim.name, anim.tag, anim.fps, anim.loop, anim.flip.x, anim.flip.y);
						}
						anims.set(anim.name, {
							offset: new PositionStruct(anim.offset.x, anim.offset.y),
							swappedAnim: '',
							flippedAnim: ''
						});
					} catch(error:haxe.Exception) trace('Couldn\'t load animation "${anim.name}", maybe the tag "${anim.tag}" is invaild? The asset is "${anim.asset.image}", type "${anim.asset.type}" btw.');
			} catch(error:haxe.Exception) trace('Couldn\'t add the animations.');

			if (Reflect.hasField(incomingData, 'position')) {
				try {
					setPosition(incomingData.position.x, incomingData.position.y);
				}
			}
			if (Reflect.hasField(incomingData, 'flip')) {
				try {
					flipX = incomingData.flip.x;
					flipY = incomingData.flip.y;
				}
			}
			if (Reflect.hasField(incomingData, 'scale')) {
				try {
					scale.set(incomingData.scale.x, incomingData.scale.y);
				}
			}

			try {
				antialiasing = incomingData.reflectDefault('antialiasing', true);
			} catch(error:haxe.Exception) trace('The antialiasing null check failed.');

			if (Reflect.hasField(incomingData, 'extra'))
				try {
					if (incomingData.extra != null || incomingData.extra.length > 1)
						for (extraData in incomingData.extra)
							extra.set(extraData.name, extraData.data);
				} catch(error:haxe.Exception) trace('Invaild information in extra array or the null check failed.');

			try {
				data = incomingData;
			} catch(error:haxe.Exception) trace('Couldn\'t set the data variable.');
		} catch(error:haxe.Exception)
			try {
				trace('Something went very wrong! What could bypass all the try\'s??? Tip: "${incomingData.asset.image}"');
			} catch(error:haxe.Exception) trace('Something went very wrong! What could bypass all the try\'s??? Tip: "null"');
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
	 * The sprites internal scripts.
	 */
	public var scripts:ScriptGroup;
	/**
	 * Loads the internal sprite scripts.
	 * @param path The mod path.
	 */
	public function loadScript(path:String):Void {
		scripts = new ScriptGroup(this);

		for (sprite in ['global', path])
			for (script in Script.create('content/objects/$sprite'))
				scripts.add(script);

		scripts.load();
	}

	public function new(x:Float = 0, y:Float = 0, ?sprite:OneOfTwo<TypeSpriteData, String>, script:String = '') {
		super(x, y);
		#if IGROUP_INTERFACE
		add(this);
		#end

		if (sprite is String) {
			if (Paths.fileExists(Paths.object(sprite), false)) {
				loadScript(sprite);
				renderData(ParseUtil.object(sprite, type));
			}
			else loadTexture(sprite);
		} else renderData(sprite);
		if (scripts == null) loadScript(script);
	}

	override public function update(elapsed:Float):Void {
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
	 * Plays an animation.
	 * @param name The animation name.
	 * @param force If true, the game won't care if another one is already playing.
	 * @param context The wanted animation context.
	 * @param suffix The animation suffix.
	 * @param reverse If true, the animation will play backwards.
	 * @param frame The starting frame. By default it's 0.
	 * 				Although if reversed it will use the last frame instead.
	 */
	inline public function playAnim(name:String, force:Bool = false, context:AnimContext = Unclear, suffix:String = '', reverse:Bool = false, frame:Int = 0):Void {
		final suffixResult:String = invaildSuffixCheck(name, suffix) ? '-$suffix' : (invaildSuffixCheck(name, generalSuffixCheck(context)) ? '-${generalSuffixCheck(context)}' : '');
		final theName:String = '$name${suffixResult.trim()}';
		if (doesAnimExist(theName, true)) {
			final animInfo:AnimMapping = getAnimInfo(theName);
			animation.play(theName, force, reverse, frame);
			frameOffset.set(animInfo.offset.x, animInfo.offset.y);
			animContext = context;
		}
	}
	/**
	 * Get's the name of the currently playing animation.
	 * @param ignoreSwap If true, it won't use the swap name.
	 * @param ignoreFlip If true, it won't use the flip name.
	 * @return `String` The animation name.
	 */
	inline public function getAnimName(ignoreSwap:Bool = true, ignoreFlip:Bool = false):String {
		if (animation.name != null) {
			var targetAnim:String = animation.name;
			targetAnim = (!ignoreSwap && doesAnimExist(targetAnim)) ? anims.get(targetAnim).swappedAnim : targetAnim;
			targetAnim = (!ignoreFlip && doesAnimExist(targetAnim)) ? anims.get(targetAnim).flippedAnim : targetAnim;
			return targetAnim;
		}
		return animation.name;
	}
	/**
	 * Get's information on a set animation of your choosing.
	 * @param name The animation name.
	 * @return `AnimMapping` ~ The animation information.
	 */
	inline public function getAnimInfo(name:String):AnimMapping return doesAnimExist(name) ? anims.get(name) : {offset: new PositionStruct(), swappedAnim: '', flippedAnim: ''}
	/**
	 * Tells you if the animation has finished playing.
	 * @return `Bool`
	 */
	inline public function isAnimFinished():Bool return (animation == null || animation.curAnim == null) ? false : animation.curAnim.finished;
	/**
	 * When run, it forces the animation to finish.
	 */
	inline public function finishAnim():Void if (animation.curAnim != null) animation.curAnim.finish();
	/**
	 * Check's if the animation exists.
	 * @param name The animation name to check.
	 * @param inGeneral If false, it only checks if the animation is listed in the map.
	 * @return `Bool`
	 */
	inline public function doesAnimExist(name:String, inGeneral:Bool = false):Bool return inGeneral ? animation.exists(name) : (animation.exists(name) && anims.exists(name));

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

	/* override public function draw():Void {
		if (isFacing == rightFace) {
			__offsetFlip = true;

			flipX = !flipX;
			scale.x *= -1;
			super.draw();
			flipX = !flipX;
			scale.x *= -1;

			__offsetFlip = false;
		} else super.draw();
	} */
}