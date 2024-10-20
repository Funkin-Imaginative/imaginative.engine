package utils;

typedef TypeSpriteData = OneOfThree<SpriteData, BeatSpriteData, CharacterSpriteData>;

typedef CharacterSpriteData = BeatSpriteData & {
	/**
	 * The character sprite data.
	 */
	var character:CharacterData;
}
typedef BeatSpriteData = SpriteData & {
	/**
	 * The beat sprite data.
	 */
	var beat:BeatData;
}
typedef SpriteData = ObjectData & {
	/**
	 * The sprite offset data.
	 */
	@:optional var offsets:OffsetsData;
	/**
	 * Extra data for the sprite.
	 */
	@:optional var extra:Array<ExtraData>;
}

typedef AnimMapping = {
	/**
	 * Offsets for that set animation.
	 */
	@:default({x: 0, y: 0}) var offset:PositionStruct;
	/**
	 * Swapped name for that set animation.
	 * Ex: singLEFT to singRIGHT
	 */
	@:default('') var swappedAnim:String;
	/**
	 * Flipped name for that set animation.
	 * Useful for characters that may off design when flipped!
	 * Basically it's good for asymmetrical characters.
	 */
	@:default('') var flippedAnim:String;
}

enum abstract SpriteType(String) from String to String {
	// Special Types
	/**
	 * States that this is a character.
	 */
	var isCharacterSprite = 'Character';
	/**
	 * States that this is a health icon.
	 */
	var isHealthIcon = 'Icon';

	// Base Types
	/**
	 * States that this is the a sprite that can bop to the beat. A bit limiting without the help of the `isBeatType` property.
	 */
	var isBeatSprite = 'Beat';
	/**
	 * States that this is the engine's base sprite.
	 */
	var isBaseSprite = 'Base';

	/**
	 * States that this sprite is unidentified and can't be figured out.
	 */
	var isUnidentified = 'Unidentified';

	/**
	 * States that this is the a sprite that can bop to the beat. Even when not set as the `isBeatSprite` type.
	 */
	public var isBeatType(get, never):Bool;
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function get_isBeatType():Bool
		return this == isBeatSprite || this == isCharacterSprite || this == isHealthIcon;
}

class SpriteUtil {
	/**
	 * Load's a sheet for the sprite to use.
	 * @param sprite The sprite to affect.
	 * @param newTexture The texture mod path.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	inline public static function loadTexture<T:FlxSprite>(sprite:T, newTexture:String):T {
		if (sprite is BaseSprite)
			cast(sprite, BaseSprite).loadTexture(newTexture);
		else if (sprite is FlxSprite) {
			final sheetPath:String = Paths.multExst('images/$newTexture', Paths.atlasFrameExts);
			final textureType:TextureType = TextureType.getTypeFromExt(sheetPath);
			if (Paths.fileExists('images/$newTexture.png'))
				try {
					if (Paths.spriteSheetExists(newTexture)) loadSheet(sprite, newTexture);
					else loadImage(sprite, newTexture);
				} catch(error:haxe.Exception) trace('Couldn\'t find asset "$newTexture", type "$textureType"');
		}
		return sprite;
	}
	/**
	 * Load's a graphic texture for the sprite to use.
	 * @param sprite The sprite to affect.
	 * @param newTexture The texture mod path.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	inline public static function loadImage<T:FlxSprite>(sprite:T, newTexture:String):T {
		if (sprite is BaseSprite)
			cast(sprite, BaseSprite).loadImage(newTexture);
		else if (sprite is FlxSprite)
			if (Paths.fileExists('images/$newTexture.png'))
				try {
					cast(sprite, FlxSprite).loadGraphic(Paths.image(newTexture));
				} catch(error:haxe.Exception) trace('Couldn\'t find asset "$newTexture", type "${TextureType.isGraphic}"');

		return sprite;
	}
	/**
	 * Load's a sheet or graphic texture for the sprite to use based on checks.
	 * @param sprite The sprite to affect.
	 * @param newTexture The texture mod path.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	inline public static function loadSheet<T:FlxSprite>(sprite:T, newTexture:String):T {
		if (sprite is BaseSprite)
			cast(sprite, BaseSprite).loadSheet(newTexture);
		else if (sprite is FlxSprite)
			if (Paths.fileExists('images/$newTexture.png')) {
				final sheetPath:String = Paths.multExst('images/$newTexture', Paths.atlasFrameExts);
				final textureType:TextureType = TextureType.getTypeFromExt(sheetPath, true);
				if (Paths.spriteSheetExists(newTexture))
					try {
						cast(sprite, FlxSprite).frames = Paths.frames(newTexture);
					} catch(error:haxe.Exception) trace('Couldn\'t find asset "$newTexture", type "$textureType"');
				else loadImage(sprite, newTexture);
			}
		return sprite;
	}

	/**
	 * Get's the dominant color of a sprite.
	 * @param sprite The sprite to check.
	 * @return `FlxColor` ~ The dominant color.
	 */
	inline public static function getDominantColor<T:FlxSprite>(sprite:T):FlxColor {
		var countByColor:Map<Int, Int> = [];
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
		countByColor = [];
		return FlxColor.fromInt(maxKey);
	}

	/**
	 * Is kinda just basically-ish FlxTypedGroup.resolveGroup().
	 * @param obj The object to check.
	 * @return `FlxTypedGroup<Dynamic>`
	 */
	inline public static function getGroup<T:FlxBasic>(obj:T):FlxTypedGroup<Dynamic>
		return @:privateAccess FlxTypedGroup.resolveGroup(obj).getDefault(FlxG.state.persistentUpdate ? FlxG.state : FlxG.state.subState.getDefault(cast FlxG.state));

	/**
	 * Add's an object in front of another.
	 * @param obj The object to insert.
	 * @param fromThis The object to be mooned. /j
	 * @param into Specified group.
	 * @return `T` ~ Current instance for chaining.
	 */
	inline public static function addInfrontOf<T:FlxBasic>(obj:T, fromThis:T, ?into:FlxTypedGroup<Dynamic>):T {
		final group:FlxTypedGroup<Dynamic> = into.getDefault(obj.getGroup());
		return group.insert(group.members.indexOf(fromThis) + 1, obj);
	}
	/**
	 * Add's an object behind of another.
	 * @param obj The object to insert.
	 * @param fromThis The object to be mooning. /j
	 * @param into Specified group.
	 * @return `T` ~ Current instance for chaining.
	 */
	inline public static function addBehind<T:FlxBasic>(obj:T, fromThis:T, ?into:FlxTypedGroup<Dynamic>):T {
		final group:FlxTypedGroup<Dynamic> = into.getDefault(obj.getGroup());
		return group.insert(group.members.indexOf(fromThis), obj);
	}

	/**
	 * Get's the name of a class.
	 * @param direct The class to get it's name of.
	 * @param provideFullPath If true, this will return the full class path, else, just the name.
	 * @return `String` ~ The class name.
	 */
	inline public static function getClassName(direct:Dynamic, provideFullPath:Bool = false):String {
		if (provideFullPath)
			return Type.getClassName(Type.getClass(direct));
		else {
			var path:Array<String> = Type.getClassName(Type.getClass(direct)).split('.');
			return path[path.length - 1];
		}
	}
}