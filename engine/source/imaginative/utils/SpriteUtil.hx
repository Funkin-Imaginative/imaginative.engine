package imaginative.utils;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawSpriteSetupData = {
	var ?position:Array<Float>;
	var ?flip:Array<Bool>;
	var ?scale:Array<Float>;
}
typedef SpriteSetupData = {
	/**
	 * Position value.
	 */
	var position:Position;
	/**
	 * Flip value.
	 */
	var flip:TypeXY<Bool>;
	/**
	 * Scale value.
	 */
	var scale:Position;
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawAssetTyping = {
	var image:String;
	var ?type:String;
	var ?slots:Array<Int>;
}
@:structInit @:publicFields class AssetTyping {
	/**
	 * The image mod path.
	 */
	var image:ModPath;
	/**
	 * The texture type.
	 * Note: This property is only used internally.
	 */
	var type:TextureType;
	/**
	 * The amount for width and height slots (ex: for icons do [2, 1]).
	 * Note: Only if texture type is "IsGraphic".
	 */
	var slots:TypeXY<Int>;

	/**
	 * Converts the raw object data.
	 * @param raw The object data.
	 * @return AssetTyping
	 */
	static function fromRaw(raw:RawAssetTyping):AssetTyping {
		final modPath:ModPath = raw.image;
		final fullPath:ModPath = Paths.image(modPath);
		final slotData:TypeXY<Int> = TypeXY.fromArray(raw.slots ?? [0, 0]);
		if (raw.slots != null && (slotData.x < 1 || slotData.y < 1)) {
			final path:String = fullPath.isFile ? '$modPath (raw:${fullPath.format()})' : 'No Path';
			_log('[AssetTyping.fromRaw] Asset "$path" has a slot less then 1, ignoring entered slot information.', WarningMessage);
		}
		var type:TextureType = raw.type != null ? raw.type : TextureType.getTypeFromExt(Paths.multExt(fullPath, Paths.spritesheetExts));
		return {
			image: modPath,
			type: type,
			slots: slotData.x < 1 || slotData.y < 1 ? null : slotData
		}
	}
	/**
	 * Converts the object data.
	 * @param data The object data.
	 * @return RawAssetTyping
	 */
	static function toRaw(data:AssetTyping):RawAssetTyping {
		var raw:Dynamic = {image: data.image}
		if (data.slots != null) // prevents it from stringify-ing as containing null
			raw._set('slots', data.slots.toArray());
		return raw;
	}

	inline private function toString():String {
		final fullPath:ModPath = Paths.image(image);
		return FunkinUtil.toDebugString([
			'Image Path' => fullPath.isFile ? '$image (raw path:${fullPath.format()})' : 'No Path (entered path:$image)',
			'Texture Type' => type,
			'Width and Height Slots' => slots == null ? 'No Slots' : slots
		]);
	}
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawAnimationTyping = {
	var ?asset:RawAssetTyping;
	var name:String;
	var ?tag:String;
	var ?indices:Array<Int>;
	var ?offset:Array<Float>;
	var ?swapKey:String;
	var ?flipKey:String;
	var ?flip:Array<Bool>;
	var ?loop:Bool;
	var ?fps:Int;
}
@:structInit @:publicFields class AnimationTyping {
	/**
	 * The asset typing for the animation respectively.
	 */
	var asset:AssetTyping;

	/**
	 * The name of the animation.
	 */
	var name:String;
	/**
	 * The animation key within the data method.
	 * Note: Goes unused if the asset type is "IsGraphic".
	 */
	var tag:String;

	/**
	 * The specified frames to use in the animation.
	 */
	var indices:Array<Int>;

	/**
	 * The position offset for the animation.
	 */
	var offset:Position;

	/**
	 * The swapped name for the animation.
	 * Note: Is used to help with animation swapping when the flipped in the x axis (ex: "singLEFT" to "singRIGHT").
	 */
	var swapKey:String;
	/**
	 * The flipped name for the animation.
	 * Useful for characters that may off design when flipped!
	 * Basically it's good for asymmetrical characters.
	 */
	var flipKey:String;

	/**
	 * The flipped states for the animation.
	 */
	var flip:TypeXY<Bool>;

	/**
	 * States whether the animation loops.
	 */
	var loop:Bool;
	/**
	 * The framerate of the animation.
	 */
	var fps:Int;

	/**
	 * Converts the raw object data.
	 * @param raw The object data.
	 * @return AnimationTyping
	 */
	static function fromRaw(raw:RawAnimationTyping):AnimationTyping {
		return {
			asset: raw.asset == null ? null : AssetTyping.fromRaw(raw.asset),
			name: raw.name,
			tag: raw.tag,
			indices: raw.indices,
			offset: Position.fromArray(raw.offset ?? [0, 0]),
			swapKey: raw.swapKey,
			flipKey: raw.flipKey,
			flip: TypeXY.fromArray(raw.flip ?? [false, false]),
			loop: raw.loop ?? false,
			fps: raw.fps ?? 24
		}
	}
	/**
	 * Converts the object data.
	 * @param data The object data.
	 * @return RawAnimationTyping
	 */
	static function toRaw(data:AnimationTyping):RawAnimationTyping {
		var raw:Dynamic = {name: data.name}
		// prevents it from stringify-ing as containing null
		if (data.asset != null) raw._set('asset', AssetTyping.toRaw(data.asset));
		if (data.tag != null) raw._set('tag', data.tag);
		if (data.indices != null) if (data.indices.length != 0) raw._set('indices', data.indices);
		if (data.offset != null || !(data.offset.x == 0 && data.offset.y == 0)) raw._set('offset', data.offset.toArray());
		if (data.swapKey != null) raw._set('swapKey', data.swapKey);
		if (data.flipKey != null) raw._set('flipKey', data.flipKey);
		if (data.flip != null || !(!data.flip.x && !data.flip.y)) raw._set('flip', data.flip.toArray());
		if (data.loop) raw._set('loop', data.loop);
		if (data.fps != 24) raw._set('fps', data.fps);
		return raw;
	}

	inline private function toString():String {
		return FunkinUtil.toDebugString([
			'Animation Specific Asset Typing' => asset,
			'Animation Name' => name,
			'Animation Tag' => tag,
			'Animation Indices' => indices,
			'Animation Offset' => offset,
			'Animation Swap Key' => swapKey,
			'Animation Flip Key' => flipKey,
			'Animation Flip States' => flip,
			'Animation Loops' => loop,
			'Animation Framerate' => fps
		]);
	}
}

/**
 * A helper abstract that can return either a mod path or object data for sprites.
 * Note: This abstract only exists because multi-typing in source is a bitch.
 */
abstract DynamicSpriteData(Dynamic) {
	/**
	 * Note: If all are provided then the path or raw will be used.
	 * @param path The potential mod path.
	 * @param data The potential object data.
	 * @param raw The potential raw object data.
	 * @return DynamicSpriteData
	 */
	public function new(?path:ModPath, ?data:SpriteData, ?raw:RawSpriteData)
		this = path == null ? (raw == null ? data : raw) : path;

	/**
	 * Checks wether or not the held data is null/empty.
	 * @return Bool
	 */
	inline public function isNull():Bool
		return this == null;
	/**
	 * Checks wether or not the held data is a directory.
	 * @return Bool
	 */
	inline public function isDirectory():Bool
		return this is String;
	/**
	 * Checks wether or not the held data is raw.
	 * @return Bool
	 */
	inline public function isRaw():Bool {
		if (isNull() || isDirectory()) return false;
		return !this is SpriteData;
	}

	/**
	 * Can return a mod path if that's whats being held.
	 * @return Null<ModPath>
	 */
	public function getPath():Null<ModPath> {
		if (isDirectory())
			return this;
		return null;
	}
	/**
	 * Can return object data if that's whats being held.
	 * @param force Forces the data to be returned, only works if the data potentially is raw.
	 * @param type The sprite type. Only used when "force" is true.
	 * @return SpriteData
	 */
	public function getData(force:Bool = false, type:SpriteType = IsBaseSprite):SpriteData {
		if (isDirectory()) return null;
		if (!isRaw()) return this;
		else if (isRaw() && force)
			return SpriteData.fromRaw(this, type);
		return null;
	}
	/**
	 * Can return raw object data if that's whats being held.
	 * @param force Forces the data to be returned, only works if the data potentially isn't raw.
	 * @return RawSpriteData
	 */
	public function getRawData(force:Bool = false):RawSpriteData {
		if (isDirectory()) return null;
		if (isRaw()) return this;
		else if (!isRaw() && force)
			return SpriteData.toRaw(this);
		return null;
	}

	/**
	 * You'd think ModPath already having from String functionally would make this redundant, but *noo*! Source can be stubborn asf man.
	 * @param path The path to use.
	 * @return DynamicSpriteData
	 */
	@:from inline public static function fromString(path:String):DynamicSpriteData
		return fromModPath(path);
	/**
	 * @param path The mod path to use.
	 * @return DynamicSpriteData
	 */
	@:from inline public static function fromModPath(path:ModPath):DynamicSpriteData
		return new DynamicSpriteData(path);
	/**
	 * @param data The object data to use.
	 * @return DynamicSpriteData
	 */
	@:from inline public static function fromSpriteData(data:SpriteData):DynamicSpriteData
		return new DynamicSpriteData(data);
	/**
	 * @param raw The raw object data to use.
	 * @return DynamicSpriteData
	 */
	@:from inline public static function fromRawSpriteData(raw:RawSpriteData):DynamicSpriteData
		return new DynamicSpriteData(raw);
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawSpriteData = {
	var ?character:RawCharacterData;
	var ?beat:BeatData;
	var ?offsets:RawSpriteSetupData;
	var asset:RawAssetTyping;
	var animations:Array<RawAnimationTyping>;
	var ?starting:RawSpriteSetupData;
	var ?swapTriggers:Bool;
	var ?flipTrigger:Bool;
	var ?antialiasing:Bool;
	var ?extra:Dynamic<Dynamic>;
}
@:structInit @:publicFields class SpriteData {
	/**
	 * The character data.
	 */
	var character:CharacterData;
	/**
	 * The beat data.
	 */
	var beat:BeatData;

	/**
	 * The offset data.
	 */
	var offsets:SpriteSetupData;

	/**
	 * The asset typing.
	 */
	var asset:AssetTyping;
	/**
	 * The animations for a given sprite.
	 */
	var animations:Array<AnimationTyping>;

	/**
	 * Start values.
	 */
	var starting:SpriteSetupData;

	/**
	 * If true the swap anim var can go off.
	 * For characters and icons it always on.
	 */
	var swapAnimTriggers:Bool;
	/**
	 * States which flipX state the sprite must be in to trigger the flip anim var.
	 */
	var flipAnimTrigger:Bool;

	/**
	 * Should antialiasing be enabled?
	 */
	var antialiasing:Bool;

	/**
	 * Extra data that can be stored.
	 */
	var extra:Map<String, Dynamic>;

	/**
	 * Converts the raw object data.
	 * @param raw The object data.
	 * @param type The sprite type.
	 * @return SpriteData
	 */
	static function fromRaw(raw:RawSpriteData, type:SpriteType = IsBaseSprite):SpriteData {
		final charData:CharacterData = if (type == IsCharacterSprite) {
			camera: Position.fromArray(raw?.character?.camera ?? [0, 0]),
			color: raw?.character?.color == null ? FlxColor.GRAY : FlxColor.fromString(raw.character.color),
			icon: raw?.character?.icon,
			singlength: raw?.character?.singlength ?? 4,
			vocals: raw?.character?.vocals
		} else null;
		final beatData:BeatData = if (type.isBeatType) {
			interval: raw?.beat?.interval ?? 0,
			skipnegative: raw?.beat?.skipnegative ?? false
		} else null;

		return {
			character: charData,
			beat: beatData,
			offsets: {
				position: Position.fromArray(raw?.offsets?.position ?? [0, 0]),
				flip: TypeXY.fromArray(raw?.offsets?.flip ?? [false, false]),
				scale: Position.fromArray(raw?.offsets?.scale ?? [1, 1])
			},
			asset: AssetTyping.fromRaw(raw.asset),
			animations: [for (anim in raw.animations) AnimationTyping.fromRaw(anim)],
			starting: raw.starting == null ? null : {
				position: Position.fromArray(raw.starting.position),
				flip: TypeXY.fromArray(raw.starting.flip),
				scale: Position.fromArray(raw.starting.scale)
			},
			swapAnimTriggers: raw.swapTriggers ?? false,
			flipAnimTrigger: raw.flipTrigger ?? true,
			antialiasing: raw.antialiasing ?? true,
			extra: raw.extra == null ? null : FunkinUtil.objectToMap(raw.extra)
		}
	}
	/**
	 * Converts the object data.
	 * @param data The object data.
	 * @param clearFlip Whether to clear the flip.
	 * @param clearCheer Whether to clear the cheer.
	 * @return RawBasicSpriteTyping
	 */
	static function toRaw(data:SpriteData):RawSpriteData {
		var raw:Dynamic = {}
		return cast raw;
	}

	inline private function toString():String {
		return FunkinUtil.toDebugString([
			'Character Specific Data' => character,
			'Beat Specific Data' => beat,
			'Offsets' => offsets,
			'Asset Typing' => asset,
			'Animations' => animations,
			'Starting Values' => starting,
			'Swap Anim Triggers' => swapAnimTriggers,
			'Flip Anim Trigger State' => flipAnimTrigger,
			'Antialiasing' => antialiasing,
			'Extra Data' => extra
		]);
	}
}

enum abstract SpriteType(String) from String to String {
	// Special Types
	/**
	 * States that this is a character.
	 */
	var IsCharacterSprite = 'Character';
	/**
	 * States that this is a health icon.
	 */
	var IsHealthIcon = 'Icon';

	// Base Types
	/**
	 * States that this is the a sprite that can bop to the beat. A bit limiting without the help of the "isBeatType" property.
	 */
	var IsBeatSprite = 'Beat';
	/**
	 * States that this is the engines base sprite.
	 */
	var IsBaseSprite = 'Base';

	/**
	 * States that this sprite is unidentified and can't be figured out.
	 */
	var IsUnidentified = 'Unidentified';

	/**
	 * States that this is the a sprite that can bop to the beat. Even when not set as the 'IsBeatSprite' type.
	 */
	public var isBeatType(get, never):Bool;
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function get_isBeatType():Bool
		return this == IsBeatSprite || this == IsCharacterSprite || this == IsHealthIcon;
}

class SpriteUtil {
	/**
	 * Loads a sheet or graphic texture for the sprite to use based on checks.
	 * @param sprite The sprite to affect.
	 * @param newTexture The mod path.
	 * @return FlxSprite ~ Current instance for chaining.
	 */
	public static function loadTexture<T:FlxSprite>(sprite:T, newTexture:ModPath):T {
		if (sprite is ITexture)
			cast(sprite, ITexture<Dynamic>).loadTexture(newTexture);
		else if (sprite is FlxSprite) {
			var sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
			var textureType:TextureType = TextureType.getTypeFromExt(sheetPath);
			if (Paths.image(newTexture).isFile)
				try {
					if (Paths.spriteSheetExists(newTexture)) return loadSheet(sprite, newTexture);
					/* #if ANIMATE_SUPPORT
					else if (sprite is FlxAnimate && Paths.image(Paths.json('${newTexture.type}:${newTexture.path}/Animation')).isFile)
						return loadAtlas(cast(sprite, FlxAnimate), newTexture);
					#end */
					else return loadImage(sprite, newTexture);
				} catch(error:haxe.Exception)
					log('Couldn\'t find asset "${newTexture.format()}", type "$textureType"', WarningMessage);
		}
		return sprite;
	}
	/**
	 * Loads a graphic texture for the sprite to use.
	 * @param sprite The sprite to affect.
	 * @param newTexture The mod path.
	 * @param animated Whether the graphic should be the sprite cut into a grid.
	 * @param width Grid width.
	 * @param height Grid height.
	 * @return FlxSprite ~ Current instance for chaining.
	 */
	public static function loadImage<T:FlxSprite>(sprite:T, newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):T {
		if (sprite is ITexture)
			cast(sprite, ITexture<Dynamic>).loadImage(newTexture, animated, width, height);
		else if (sprite is FlxSprite)
			if (Paths.image(newTexture).isFile)
				try {
					sprite.loadGraphic(Assets.image(newTexture), width < 1 || height < 1 ? false : animated, width, height);
				} catch(error:haxe.Exception)
					log('Couldn\'t find asset "${newTexture.format()}", type "${TextureType.IsGraphic}"', WarningMessage);
		return sprite;
	}
	/**
	 * Loads a sheet for the sprite to use.
	 * @param sprite The sprite to affect.
	 * @param newTexture The mod path.
	 * @return FlxSprite ~ Current instance for chaining.
	 */
	public static function loadSheet<T:FlxSprite>(sprite:T, newTexture:ModPath):T {
		if (sprite is ITexture)
			cast(sprite, ITexture<Dynamic>).loadSheet(newTexture);
		else if (sprite is FlxSprite) {
			var sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
			var textureType:TextureType = TextureType.getTypeFromExt(sheetPath, true);
			if (Paths.image(newTexture).isFile)
				if (Paths.spriteSheetExists(newTexture))
					try {
						sprite.frames = Assets.frames(newTexture, textureType);
					} catch(error:haxe.Exception)
						try {
							loadImage(sprite, newTexture); // failsafe for if the pack data ins't found
						} catch(error:haxe.Exception)
							log('Couldn\'t find asset "${newTexture.format()}", type "$textureType"', WarningMessage);
				else return loadImage(sprite, newTexture);
		}
		return sprite;
	}
	#if ANIMATE_SUPPORT
	/**
	 * Loads an animate atlas for the sprite to use.
	 * @param sprite The sprite to affect.
	 * @param newTexture The mod path.
	 * @return FlxAnimate ~ Current instance for chaining.
	 */
	public static function loadAtlas<T:FlxAnimate>(sprite:T, newTexture:ModPath):T {
		if (sprite is ITexture)
			cast(sprite, ITexture<Dynamic>).loadAtlas(newTexture);
		else if (sprite is FlxAnimate) {
			var atlasPath:ModPath = Paths.image(Paths.json(newTexture));
			var jsonPath:ModPath = '${atlasPath.type}:${FilePath.directory(atlasPath.path)}/Animation${atlasPath.extension}';
			var textureType:TextureType = TextureType.getTypeFromExt(atlasPath, true);
			if (jsonPath.isFile) {
				try {
					sprite.frames = Assets.frames(atlasPath, textureType);
				} catch(error:haxe.Exception)
					try {
						loadImage(sprite, '${newTexture.type}:${newTexture.path}/spritemap1'); // failsafe for if the pack data ins't found
					} catch(error:haxe.Exception)
						log('Couldn\'t find asset "${newTexture.format()}", type "$textureType"', WarningMessage);
			}
		}
		return sprite;
	}
	#end

	/**
	 * Allows you to set a graphic size (ex: 150x150), with proper hitbox without a stretched sprite.
	 * @param sprite Sprite to apply the new graphic size to
	 * @param width Width
	 * @param height Height
	 * @param fill Whenever the sprite should fill instead of shrinking (true).
	 * @param maxScale Maximum scale (0 / none).
	 * @author @CodenameCrew
	 */
	inline public static function setUnstretchedGraphicSize(sprite:FlxSprite, width:Int = 0, height:Int = 0, fill:Bool = true, maxScale:Float = 0):Void {
		sprite.setGraphicSize(width, height);
		sprite.updateHitbox();
		var nScale = (fill ? Math.max : Math.min)(sprite.scale.x, sprite.scale.y);
		if (maxScale > 0 && nScale > maxScale) nScale = maxScale;
		sprite.scale.set(nScale, nScale);
	}

	/**
	 * It's makeGraphic but sets the scale to size the graphic.
	 * @param sprite THe sprite to do this too.
	 * @param width The wanted width.
	 * @param height The wanted height.
	 * @param color The wanted color.
	 * @param unique If it should be unique.
	 * @param key Custom key.
	 * @return FlxSprite ~ Current instance for chaining.
	 */
	inline public static function makeSolid<T:FlxSprite>(sprite:T, width:Float, height:Float, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String):T {
		sprite.makeGraphic(1, 1, color, unique, key);
		sprite.scale.set(width, height);
		sprite.updateHitbox();
		#if FLX_TRACK_GRAPHICS
		sprite.graphic.trackingInfo = '${sprite.ID}.makeSolid($width, $height, ${color.toHexString()}, $unique, $key)';
		#end
		return sprite;
	}

	/**
	 * Gets the dominant color of a sprite.
	 * @param sprite The sprite to check.
	 * @return FlxColor ~ The dominant color.
	 */
	inline public static function getDominantColor(sprite:FlxSprite):FlxColor {
		var countByColor:Map<Int, Int> = new Map<Int, Int>();
		for (col in 0...sprite.frameWidth) {
			for (row in 0...sprite.frameHeight) {
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0) {
					if (countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for (key in countByColor.keys()) {
			if (countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor.clear();
		return FlxColor.fromInt(maxKey);
	}

	/**
	 * Is kinda just basically-ish FlxTypedGroup.resolveGroup().
	 * @param obj The object to check.
	 * @return FlxTypedGroup<Dynamic>
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	inline public static function getGroup(obj:FlxBasic):FlxTypedGroup<Dynamic> {
		return FlxTypedGroup.resolveGroup(obj) ?? (FlxG.state.persistentUpdate ? FlxG.state : FlxG.state.subState ?? cast FlxG.state);
	}

	/**
	 * Adds an object in front of another.
	 * @param obj The object to insert.
	 * @param from The object to be placed in front of.
	 * @param into Specified group.
	 * @return FlxBasic ~ Current instance for chaining.
	 */
	inline public static function addInfrontOf(obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>):FlxBasic {
		var group:FlxTypedGroup<Dynamic> = into ?? obj.getGroup();
		return group.insert(group.members.indexOf(from) + 1, obj);
	}
	/**
	 * Adds an object behind of another.
	 * @param obj The object to insert.
	 * @param from The object to be placed behind of.
	 * @param into Specified group.
	 * @return FlxBasic ~ Current instance for chaining.
	 */
	inline public static function addBehind(obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>):FlxBasic {
		var group:FlxTypedGroup<Dynamic> = into ?? obj.getGroup();
		return group.insert(group.members.indexOf(from), obj);
	}

	// TODO: There's literally already a function for this.
	/**
	 * Gets the name of a class.
	 * @param instance The class to get it's name of.
	 * @param provideFullPath If true this will return the full class path, else, just the name.
	 * @return String ~ The class name.
	 */
	inline public static function getClassName(instance:Dynamic, provideFullPath:Bool = false):String {
		final fullPath:String = Type.getClassName(Type.getClass(instance) ?? instance) ?? 'NO NAME';
		return provideFullPath ? fullPath : fullPath.split('.').last();
	}
}