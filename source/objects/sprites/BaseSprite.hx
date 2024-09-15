package objects.sprites;

import utils.SpriteUtil.TypeSpriteData;
import utils.SpriteUtil.AnimMapping;
import utils.SpriteUtil.SpriteData;
import backend.structures.PositionStruct.TypeXY;
import flixel.math.FlxRect;
import flixel.addons.effects.FlxSkewedSprite;

enum abstract AnimType(String) from String to String {
	/**
	 * States that the sprite was/is dancing.
	 */
	var DANCE = 'dance';

	/**
	 * States that the character was/is singing.
	 */
	var SING = 'sing';
	/**
	 * States that the character is/had missed a note.
	 */
	var MISS = 'miss';

	/**
	 * Prevent's the idle animation.
	 */
	var LOCK = 'lock';

	/**
	 * Play's the idle after the animation has finished.
	 */
	var NONE = null;

	/* public function toString():String
		return switch (this) {
			case DANCE: 'DANCE';
			case SING: 'SING';
			case MISS: 'MISS';
			case LOCK: 'LOCK';
			case NONE: 'NONE';
			default: '';
		} */
}

@:structInit class TextureData {
	public var image(default, null):String;
	public var type(default, null):String;
	public var path(get, never):FunkinPath;
	inline function get_path():FunkinPath
		return FunkinPath.typeFromPath(image);

	public function toString():String
		return '{image => $image, type => $type, path => $path}';
}

typedef OffsetsData = {
	@:optional var position:PositionStruct;
	@:optional var flip:TypeXY<Bool>;
	@:optional var scale:PositionStruct;
}

typedef AssetTyping = {
	var image:String;
	var type:String;
}
typedef AnimationTyping = {
	@:optional var asset:AssetTyping;
	var name:String;
	@:optional var tag:String;
	@:optional var dimensions:TypeXY<Int>;
	var indices:Array<Int>;
	var offset:PositionStruct;
	var flip:TypeXY<Bool>;
	var loop:Bool;
	var fps:Int;
}

typedef ObjectData = {
	> OffsetsData,
	var asset:AssetTyping;
	var animations:Array<AnimationTyping>;
	var antialiasing:Bool;
}

class BaseSprite extends FlxSkewedSprite {
	// Cool variables.
	public var _update:Float->Void;
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var debugMode:Bool = false; // for editors

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
	@:unreflective inline function resetTextures(newTexture:String, spriteType:String):String {
		textures = [];
		textures.push({
			image: HaxePath.withoutExtension(newTexture),
			type: spriteType
		});
		return newTexture;
	}

	inline public function loadTexture(newTexture:String):TypeSprite {
		var hasSheet:Bool = Paths.multExst('images/$newTexture', Paths.atlasFrameExts) != '';
		if (Paths.fileExists('images/$newTexture.png'))
			if (hasSheet) loadSheet(newTexture);
			else loadImage(newTexture);
		return this;
	}

	inline public function loadImage(newTexture:String):TypeSprite {
		if (Paths.fileExists('images/$newTexture.png'))
			loadGraphic(resetTextures(Paths.image(newTexture), 'graphic'));
		return this;
	}

	inline public function loadSheet(newTexture:String):TypeSprite {
		var hasSheet:Bool = Paths.multExst('images/$newTexture', Paths.atlasFrameExts) != '';
		if (Paths.fileExists('images/$newTexture.png') && hasSheet) {
			frames = Paths.frames(newTexture);
			resetTextures(Paths.applyRoot('images/$newTexture.png'), switch (HaxePath.extension(Paths.multExst('images/$newTexture', Paths.atlasFrameExts))) {
				case 'xml': 'sparrow';
				case 'txt': 'packer';
				default: 'unknown';
			});
		}
		return this;
	}

	/**
	 * Literally just so
	 * ```hx
	 * var sprite:BaseSprite = new BaseSprite().makeSolid();
	 * ```
	 * would work.
	 */
	inline public function loadSolid(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):TypeSprite
		return makeSolid(Width, Height, Color, Unique, Key);

	// Where the BaseSprite class really begins.
	public var data:SpriteData = null;
	public static function makeSprite(x:Float = 0, y:Float = 0, path:String, pathType:FunkinPath = ANY):BaseSprite
		return new BaseSprite(x, y, cast ParseUtil.object(path, pathType));

	public function renderData(inputData:TypeSpriteData):Void {
		var baseData:SpriteData = cast inputData;
		try {
			loadTexture(baseData.asset.image);

			for (anim in baseData.animations) {
				switch (anim.asset.type) {
					case 'graphic':
						animation.add(anim.name, anim.indices, anim.fps, anim.loop, anim.flip.x, anim.flip.y);
					default:
						if (anim.indices != null || anim.indices.length > 1) animation.addByIndices(anim.name, anim.tag, anim.indices, '', anim.fps, anim.loop, anim.flip.x, anim.flip.y);
						else animation.addByPrefix(anim.name, anim.tag, anim.fps, anim.loop, anim.flip.x, anim.flip.y);
				}
				anims.set(anim.name, {
					offset: {x: anim.offset.x, y: anim.offset.y},
					swappedAnim: '',
					flippedAnim: ''
				});
			}

			if (Reflect.hasField(baseData, 'position')) {
				var thing:PositionStruct = FunkinUtil.getDefault(baseData.position, {x: x, y: y});
				setPosition(thing.x, thing.y);
			}
			if (Reflect.hasField(baseData, 'flip')) {
				var thing:TypeXY<Bool> = FunkinUtil.getDefault(baseData.flip, {x: flipX, y: flipY});
				flipX = thing.x;
				flipY = thing.y;
			}
			if (Reflect.hasField(baseData, 'scale')) {
				var thing:PositionStruct = FunkinUtil.getDefault(baseData.scale, {x: scale.x, y: scale.y});
				scale.set(thing.x, thing.y);
			}

			antialiasing = FunkinUtil.getDefault(baseData.antialiasing, true);

			if (Reflect.hasField(baseData, 'extra'))
				if (baseData.extra != null || baseData.extra.length > 1)
					for (extraData in baseData.extra)
						extra.set(extraData.name, extraData.data);

			data = baseData;
		} catch(e) trace('Something fucking died!');
	}

	public var anims:Map<String, AnimMapping> = new Map<String, AnimMapping>();
	public var animType:AnimType;

	public var scripts:ScriptGroup;
	public function loadScript(path:String):Void {
		scripts = new ScriptGroup(this);
		for (s in ['global', path])
			for (script in Script.create(s, OBJECT))
				scripts.add(script);

		if (scripts.length < 1)
			scripts.add(new Script());

		scripts.load();
	}

	public function new(x:Float = 0, y:Float = 0, ?sprite:OneOfTwo<TypeSpriteData, String>, script:String = '') {
		super(x, y);

		if (sprite is String) {
			if (Paths.fileExists(Paths.object(sprite), false)) {
				loadScript(sprite);
				renderData(ParseUtil.object(sprite));
			}
			else loadTexture(sprite);
		} else renderData(sprite);
		if (scripts != null) loadScript(script);
	}

	override public function update(elapsed:Float):Void {
		if (!(this is IBeat)) scripts.call('update', [elapsed]);
		super.update(elapsed);
		scripts.call('updatePost', [elapsed]);
		if (_update != null) _update(elapsed);
	}

	inline public function getAnimInfo(name:String):AnimMapping return doesAnimExist(name) ? anims.get(name) : {offset: {x: 0, y: 0}, swappedAnim: '', flippedAnim: ''}
	public function playAnim(name:String, force:Bool = false, type:AnimType = NONE, reverse:Bool = false, frame:Int = 0):Void {
		if (doesAnimExist(name, true)) {
			var animInfo:AnimMapping = getAnimInfo(name);
			animation.play(name, force, reverse, frame);
			frameOffset.set(animInfo.offset.x, animInfo.offset.y);
		}
	}
	inline public function getAnimName(ignoreSwap:Bool = true, ignoreFlip:Bool = false):String {
		if (animation.name != null) {
			var targetAnim:String = animation.name;
			targetAnim = (!ignoreSwap && doesAnimExist(targetAnim)) ? anims.get(targetAnim).swappedAnim : targetAnim;
			targetAnim = (!ignoreFlip && doesAnimExist(targetAnim)) ? anims.get(targetAnim).flippedAnim : targetAnim;
			return targetAnim;
		}
		return animation.name;
	}
	inline public function isAnimFinished():Bool return (animation == null || animation.curAnim == null) ? false : animation.curAnim.finished;
	inline public function finishAnim():Void if (animation.curAnim != null) animation.curAnim.finish();
	inline public function doesAnimExist(name:String, inGeneral:Bool = false):Bool return inGeneral ? animation.exists(name) : (animation.exists(name) && anims.exists(name));

	// make offset flipping look not broken, and yes cne also does this
	var __offsetFlip:Bool = false;

	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__offsetFlip) {
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
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