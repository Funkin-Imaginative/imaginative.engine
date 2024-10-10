package objects.sprites;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.math.FlxRect;

enum abstract AnimType(String) from String to String {
	/**
	 * States that the sprite was/is dancing.
	 */
	var DANCE;

	/**
	 * States that the character was/is singing.
	 */
	var SING;
	/**
	 * States that the character is/had missed a note.
	 */
	var MISS;

	/**
	 * Prevent's the idle animation.
	 */
	var LOCK;

	/**
	 * Play's the idle after the animation has finished.
	 */
	var NONE;
}

enum abstract TextureType(String) from String to String {
	var SPARROW;
	var PACKER;
	var GRAPHIC;
	var UNKNOWN;

	inline public static function getTypeFromPath(sheetPath:String, defaultIsUnknown:Bool = false):TextureType {
		return switch (HaxePath.extension(sheetPath)) {
			case 'xml': SPARROW;
			case 'txt': PACKER;
			default: defaultIsUnknown ? UNKNOWN : GRAPHIC;
		}
	}
}

class TextureData {
	public var image(default, null):String;
	public var type(default, null):TextureType;
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
	@:optional var position:PositionStruct;
	@:optional var flip:TypeXY<Bool>;
	@:optional var scale:PositionStruct;
}

typedef AssetTyping = {
	var image:String;
	var type:TextureType;
}
typedef AnimationTyping = {
	@:optional var asset:AssetTyping;
	var name:String;
	@:optional var tag:String;
	@:optional var dimensions:TypeXY<Int>;
	@:default([]) var indices:Array<Int>;
	@:default({x: 0, y: 0}) var offset:PositionStruct;
	@:default({x: false, y: false}) var flip:TypeXY<Bool>;
	@:default(false) var loop:Bool;
	@:default(24) var fps:Int;
}

typedef ObjectData = {
	> OffsetsData,
	var asset:AssetTyping;
	var animations:Array<AnimationTyping>;
	@:default(true) var antialiasing:Bool;
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
	@:unreflective inline function resetTextures(newTexture:String, spriteType:TextureType):String {
		textures = [];
		textures.push(new TextureData(HaxePath.withoutExtension(newTexture), spriteType));
		return newTexture;
	}

	inline public function loadTexture<T:BaseSprite>(newTexture:String):T {
		final sheetPath:String = Paths.multExst('images/$newTexture', Paths.atlasFrameExts);
		final hasSheet:Bool = Paths.spriteSheetExists(newTexture);
		final textureType:TextureType = TextureType.getTypeFromPath(sheetPath);

		if (Paths.fileExists('images/$newTexture.png'))
			try {
				if (hasSheet) loadSheet(newTexture);
				else loadImage(newTexture);
			} catch(e) trace('Couldn\'t find asset "$newTexture", type "$textureType"');
		return cast this;
	}

	inline public function loadImage<T:BaseSprite>(newTexture:String):T {
		if (Paths.fileExists('images/$newTexture.png'))
			try {
				loadGraphic(resetTextures(Paths.image(newTexture), 'graphic'));
			} catch(e) trace('Couldn\'t find asset "$newTexture", type "${TextureType.GRAPHIC}"');
		return cast this;
	}

	inline public function loadSheet<T:BaseSprite>(newTexture:String):T {
		final sheetPath:String = Paths.multExst('images/$newTexture', Paths.atlasFrameExts);
		final hasSheet:Bool = Paths.spriteSheetExists(newTexture);
		final textureType:TextureType = TextureType.getTypeFromPath(sheetPath, true);

		if (Paths.fileExists('images/$newTexture.png')) {
			if (hasSheet)
				try {
					frames = Paths.frames(newTexture);
					resetTextures(Paths.applyRoot('images/$newTexture.png'), textureType);
				} catch(e) trace('Couldn\'t find asset "$newTexture", type "$textureType"');
			else loadImage(newTexture);
		}
		return cast this;
	}

	/**
	 * Literally just so
	 * ```hx
	 * var sprite:BaseSprite = new BaseSprite().makeSolid();
	 * ```
	 * would work.
	 */
	inline public function loadSolid<T:BaseSprite>(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String):T
		return cast makeSolid(width, height, color, unique, key);

	// Where the BaseSprite class really begins.
	public var data:SpriteData = null;
	public static function makeSprite(x:Float = 0, y:Float = 0, path:String, pathType:FunkinPath = ANY):BaseSprite {
		return new BaseSprite(x, y, cast ParseUtil.object(path, BASE, pathType));
	}
	public var objType(get, never):ObjectType;
	function get_objType():ObjectType {
		return BASE;
	}
	public function renderData(inputData:TypeSpriteData):Void {
		final incomingData:SpriteData = cast inputData;
		try {
			try {
				loadTexture(incomingData.asset.image);
			} catch(e) trace('Couldn\'t load image "${incomingData.asset.image}", type "${incomingData.asset.type}".');

			try {
				for (anim in incomingData.animations)
					try {
						switch (anim.asset.type) {
							case UNKNOWN:
							case GRAPHIC:
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
					} catch(e) trace('Couldn\'t load animation "${anim.name}", maybe the tag "${anim.tag}" is invaild? The asset is "${anim.asset.image}", type "${anim.asset.type}" btw.');
			} catch(e) trace('Couldn\'t add the animations.');

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
				antialiasing = FunkinUtil.reflectDefault(incomingData, 'antialiasing', true);
			} catch(e) trace('The antialiasing null check failed.');

			if (Reflect.hasField(incomingData, 'extra'))
				try {
					if (incomingData.extra != null || incomingData.extra.length > 1)
						for (extraData in incomingData.extra)
							extra.set(extraData.name, extraData.data);
				} catch(e) trace('Invaild information in extra array or the null check failed.');

			try {
				data = incomingData;
			} catch(e) trace('Couldn\'t set the data variable.');
		} catch(e)
			try {
				trace('Something went very wrong! What could bypass all the try\'s??? Tip: "${incomingData.asset.image}"');
			} catch(e) trace('Something went very wrong! What could bypass all the try\'s??? Tip: "null"');
	}

	public var anims:Map<String, AnimMapping> = new Map<String, AnimMapping>();
	public var animType:AnimType;

	public var scripts:ScriptGroup;
	var _scripts:ScriptGroup;
	// function get_scripts():ScriptGroup {
	// 	if (_scripts == null)
	// 		_scripts = new ScriptGroup(this);
	// 	return _scripts;
	// }
	public function loadScript(path:String):Void {
		scripts = new ScriptGroup(this);

		for (s in ['global', path])
			for (script in Script.create(s, OBJECT))
				scripts.add(script);

		scripts.load();
	}

	public function new(x:Float = 0, y:Float = 0, ?sprite:OneOfTwo<TypeSpriteData, String>, script:String = '') {
		super(x, y);

		if (sprite is String) {
			if (Paths.fileExists(Paths.object(sprite), false)) {
				loadScript(sprite);
				renderData(ParseUtil.object(sprite, objType));
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

	inline public function getAnimInfo(name:String):AnimMapping return doesAnimExist(name) ? anims.get(name) : {offset: new PositionStruct(), swappedAnim: '', flippedAnim: ''}
	public function playAnim(name:String, force:Bool = false, type:AnimType = NONE, reverse:Bool = false, frame:Int = 0):Void {
		if (doesAnimExist(name, true)) {
			final animInfo:AnimMapping = getAnimInfo(name);
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