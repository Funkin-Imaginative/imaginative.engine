package imaginative.utils;

typedef ObjectSetupData = {
	/**
	 * Position value.
	 */
	@:default(new imaginative.backend.objects.Position()) var position:Position;
	/**
	 * Flip value.
	 */
	@:default(new imaginative.backend.objects.TypeXY<Bool>(false, false)) var flip:TypeXY<Bool>;
	/**
	 * Scale value.
	 */
	@:default(new imaginative.backend.objects.Position(1, 1)) var scale:Position;
}

typedef AssetTyping = {
	/**
	 * Root image path.
	 */
	var image:String;
	/**
	 * Texture type.
	 */
	@:default('Unknown') var type:TextureType;
	/**
	 * Height and width dimensions.
	 * Only if texture type is a graphic.
	 */
	@:default(new imaginative.backend.objects.TypeXY<Int>(150, 150)) var ?dimensions:TypeXY<Int>;
}

typedef AnimationTyping = {
	/**
	 * Name of the animation.
	 */
	var name:String;
	/**
	 * Animation key on data method.
	 */
	var ?tag:String;
	/**
	 * The specified frames to use in the animation.
	 * For graphic's this is the specified as the frames array in the add function.
	 */
	var indices:Array<Int>;
	/**
	 * The offset for the set animation.
	 */
	@:default(new imaginative.backend.objects.Position()) var offset:Position;
	/**
	 * Swapped name for that set animation.
	 * Ex: singLEFT to singRIGHT
	 */
	var swapKey:String;
	/**
	 * Flipped name for that set animation.
	 * Useful for characters that may off design when flipped!
	 * Basically it's good for asymmetrical characters.
	 */
	var flipKey:String;
	/**
	 * The flip offset for the set animation.
	 */
	@:default(new imaginative.backend.objects.TypeXY<Bool>(false, false)) var flip:TypeXY<Bool>;
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
	var ?character:CharacterData;
	/**
	 * The beat data.
	 */
	var ?beat:BeatData;
	/**
	 * The offset data.
	 */
	var ?offsets:ObjectSetupData;
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
	var ?starting:ObjectSetupData;
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
	var ?extra:Array<ExtraData>;
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
			var sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
			var textureType:TextureType = TextureType.getTypeFromExt(sheetPath);
			if (Paths.fileExists(Paths.image(newTexture)))
				try {
					if (Paths.spriteSheetExists(newTexture)) loadSheet(sprite, newTexture);
					else loadImage(sprite, newTexture);
				} catch(error:haxe.Exception)
					log('Couldn\'t find asset "${newTexture.format()}", type "$textureType"', WarningMessage);
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
					sprite.loadGraphic(Assets.image(newTexture), width < 1 || height < 1 ? false : animated, width, height);
				} catch(error:haxe.Exception)
					log('Couldn\'t find asset "${newTexture.format()}", type "${TextureType.IsGraphic}"', WarningMessage);
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
			var sheetPath:ModPath = Paths.multExt('${newTexture.type}:images/${newTexture.path}', Paths.spritesheetExts);
			var textureType:TextureType = TextureType.getTypeFromExt(sheetPath, true);
			if (Paths.fileExists(Paths.image(newTexture)))
				if (Paths.spriteSheetExists(newTexture))
					try {
						sprite.frames = Assets.frames(newTexture, textureType);
					} catch(error:haxe.Exception)
						try {
							loadImage(sprite, newTexture);
						} catch(error:haxe.Exception)
							log('Couldn\'t find asset "${newTexture.format()}", type "$textureType"', WarningMessage);
				else loadImage(sprite, newTexture);
		}
		return sprite;
	}

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
	 * Get's the dominant color of a sprite.
	 * @param sprite The sprite to check.
	 * @return `FlxColor` ~ The dominant color.
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
	 * @return `FlxTypedGroup<Dynamic>`
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
	 * @return `FlxBasic` ~ Current instance for chaining.
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
	 * @return `FlxBasic` ~ Current instance for chaining.
	 */
	inline public static function addBehind(obj:FlxBasic, from:FlxBasic, ?into:FlxTypedGroup<Dynamic>):FlxBasic {
		var group:FlxTypedGroup<Dynamic> = into ?? obj.getGroup();
		return group.insert(group.members.indexOf(from), obj);
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