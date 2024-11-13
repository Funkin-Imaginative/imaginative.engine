package utils;

typedef ObjectData = {
	/**
	 * Position value.
	 */
	@:default({x: 0, y: 0}) var position:Position;
	/**
	 * Flip value.
	 */
	@:default({x: false, y: false}) var flip:TypeXY<Bool>;
	/**
	 * Scale value.
	 */
	@:default({x: 1, y: 1}) var scale:Position;
}

typedef AssetTyping = {
	/**
	 * Root image path.
	 */
	var image:String;
	/**
	 * Texture type.
	 */
	@:enum @:default(IsUnknown) var type:TextureType;
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
	@:optional @:default({x: 150, y: 150}) var dimensions:TypeXY<Int>;
	/**
	 * The specified frames to use in the animation.
	 * For graphic's this is the specified as the frames array in the add function.
	 */
	@:default([]) var indices:Array<Int>;
	/**
	 * The offset for the set animation.
	 */
	@:default({x: 0, y: 0}) var offset:Position;
	/**
	 * Swapped name for that set animation.
	 * Ex: singLEFT to singRIGHT
	 */
	@:default('') var swapKey:String;
	/**
	 * Flipped name for that set animation.
	 * Useful for characters that may off design when flipped!
	 * Basically it's good for asymmetrical characters.
	 */
	@:default('') var flipKey:String;
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

typedef SpriteData = {
	/**
	 * The character data.
	 */
	@:optional var character:CharacterData;
	/**
	 * The beat data.
	 */
	@:optional var beat:BeatData;
	/**
	 * The offset data.
	 */
	@:optional var offsets:ObjectData;
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
	@:optional var starting:ObjectData;
	/**
	 * If true, the swap anim var can go off.
	 * For characters and icons it always on.
	 */
	@:default(false) var swapAnimTriggers:Bool;
	/**
	 * States which flipX state the sprite must be in to trigger the flip anim var.
	 */
	@:default(true) var flipAnimTrigger:Bool;
	/**
	 * Should antialiasing be enabled?
	 */
	@:default(true) var antialiasing:Bool;
	/**
	 * Extra data for the sprite.
	 */
	@:jignored @:optional var extra:Array<ExtraData>;
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
	 * States that this is the a sprite that can bop to the beat. A bit limiting without the help of the `isBeatType` property.
	 */
	var IsBeatSprite = 'Beat';
	/**
	 * States that this is the engine's base sprite.
	 */
	var IsBaseSprite = 'Base';

	/**
	 * States that this sprite is unidentified and can't be figured out.
	 */
	var IsUnidentified = 'Unidentified';

	/**
	 * States that this is the a sprite that can bop to the beat. Even when not set as the `IsBeatSprite` type.
	 */
	public var isBeatType(get, never):Bool;
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function get_isBeatType():Bool
		return this == IsBeatSprite || this == IsCharacterSprite || this == IsHealthIcon;
}

class SpriteUtil {
	/**
	 * Load's a sheet for the sprite to use.
	 * @param sprite The sprite to affect.
	 * @param newTexture The mod path.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	inline public static function loadTexture<T:FlxSprite>(sprite:T, newTexture:ModPath):T {
		if (sprite is ITexture)
			cast(sprite, ITexture<Dynamic>).loadTexture(newTexture);
		else if (sprite is FlxSprite) {
			final sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
			final textureType:TextureType = TextureType.getTypeFromExt(sheetPath);
			if (Paths.fileExists(Paths.image(newTexture)))
				try {
					if (Paths.spriteSheetExists(newTexture)) loadSheet(sprite, newTexture);
					else loadImage(sprite, newTexture);
				} catch(error:haxe.Exception)
					trace('Couldn\'t find asset "${newTexture.format()}", type "$textureType"');
		}
		return sprite;
	}
	/**
	 * Load's a graphic texture for the sprite to use.
	 * @param sprite The sprite to affect.
	 * @param newTexture The mod path.
	 * @param animated Whether the graphic should be the sprite cut into a grid.
	 * @param width Grid width.
	 * @param height Grid height.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	inline public static function loadImage<T:FlxSprite>(sprite:T, newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):T {
		if (sprite is ITexture)
			cast(sprite, ITexture<Dynamic>).loadImage(newTexture, animated, width, height);
		else if (sprite is FlxSprite)
			if (Paths.fileExists(Paths.image(newTexture)))
				try {
					sprite.loadGraphic(Paths.image(newTexture).format(), animated, width, height);
				} catch(error:haxe.Exception)
					trace('Couldn\'t find asset "${newTexture.format()}", type "${TextureType.IsGraphic}"');
		return sprite;
	}
	/**
	 * Load's a sheet or graphic texture for the sprite to use based on checks.
	 * @param sprite The sprite to affect.
	 * @param newTexture The mod path.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	inline public static function loadSheet<T:FlxSprite>(sprite:T, newTexture:ModPath):T {
		if (sprite is ITexture)
			cast(sprite, ITexture<Dynamic>).loadSheet(newTexture);
		else if (sprite is FlxSprite) {
			final sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
			final textureType:TextureType = TextureType.getTypeFromExt(sheetPath, true);
			if (Paths.fileExists(Paths.image(newTexture)))
				if (Paths.spriteSheetExists(newTexture))
					try {
						sprite.frames = Paths.frames(newTexture, textureType);
					} catch(error:haxe.Exception)
						try {
							loadImage(sprite, newTexture);
						} catch(error:haxe.Exception)
							trace('Couldn\'t find asset "${newTexture.format()}", type "$textureType"');
				else loadImage(sprite, newTexture);
		}
		return sprite;
	}

	/**
	 * Returns a fnf bg sprite.
	 * @param sprite The sprite to affect.
	 * @param color FlxColor input.
	 * @param funkinColor It true, when using FlxColor YELLOW, BLUE, MAGENTA, or GRAY, it will use the menuBG color instead.
	 * @param mod The mod type.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	inline public static function getBGSprite<T:FlxSprite>(sprite:T, color:FlxColor = FlxColor.YELLOW, funkinColor:Bool = true, mod:ModType = ANY):T {
		sprite.loadImage('$mod:menus/menuBackground');
		// sprite.makeGraphic(Math.floor(sprite.width), Math.floor(sprite.height));
		sprite.color = funkinColor ? switch (color) {
			case FlxColor.YELLOW: 0xFFFAE868;
			case FlxColor.BLUE: 0xFF9272FF;
			case FlxColor.MAGENTA: 0xFFF4709B;
			case FlxColor.GRAY: 0xFFE1E1E1;
			default: color;
		} : color;
		return sprite;
	}

	/**
	 * Get's the dominant color of a sprite.
	 * @param sprite The sprite to check.
	 * @return `FlxColor` ~ The dominant color.
	 */
	inline public static function getDominantColor<T:FlxSprite>(sprite:T):FlxColor {
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
	 * @return `FlxTypedGroup<Dynamic>`
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	inline public static function getGroup<T:FlxBasic>(obj:T):FlxTypedGroup<Dynamic>
		return FlxTypedGroup.resolveGroup(obj).getDefault(FlxG.state.persistentUpdate ? FlxG.state : FlxG.state.subState.getDefault(cast FlxG.state));

	/**
	 * Add's an object in front of another.
	 * @param obj The object to insert.
	 * @param fromThis The object to be placed in front of.
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
	 * @param fromThis The object to be placed behind of.
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