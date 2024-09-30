package utils;

import objects.sprites.BaseSprite.TextureType;

typedef TypeSprite = OneOfThree<FlxSprite, BaseSprite, BeatSprite>;
typedef TypeSpriteData = OneOfThree<SpriteData, BeatSpriteData, CharacterSpriteData>;

typedef CharacterSpriteData = BeatSpriteData & {
	var character:Character.CharacterData;
}
typedef BeatSpriteData = SpriteData & {
	var beat:BeatSprite.BeatData;
}
typedef SpriteData = BaseSprite.ObjectData & {
	@:optional var offsets:BaseSprite.OffsetsData;
	@:optional var extra:Array<utils.ParseUtil.ExtraData>;
}

typedef AnimMapping = {
	var offset:PositionStruct;
	var swappedAnim:String;
	var flippedAnim:String;
}

class SpriteUtil {
	inline public static function loadTexture(sprite:TypeSprite, newTexture:String):TypeSprite {
		if (sprite is BaseSprite)
			cast(sprite, BaseSprite).loadTexture(newTexture);

		if (sprite is FlxSprite) {
			final sheetPath:String = Paths.multExst('images/$newTexture', Paths.atlasFrameExts);
			final hasSheet:Bool = sheetPath != '';
			final textureType:TextureType = TextureType.getTypeFromPath(sheetPath);

			if (Paths.fileExists('images/$newTexture.png'))
				try {
					if (hasSheet) loadSheet(sprite, newTexture);
					else loadImage(sprite, newTexture);
				} catch(e) trace('Couldn\'t find asset "$newTexture", type "$textureType"');
		}
		return sprite;
	}

	inline public static function loadImage(sprite:TypeSprite, newTexture:String):TypeSprite {
		if (sprite is BaseSprite)
			cast(sprite, BaseSprite).loadImage(newTexture);

		if (sprite is FlxSprite)
			if (Paths.fileExists('images/$newTexture.png'))
				try {
					cast(sprite, FlxSprite).loadGraphic(Paths.image(newTexture));
				} catch(e) trace('Couldn\'t find asset "$newTexture", type "${TextureType.GRAPHIC}"');

		return sprite;
	}

	inline public static function loadSheet(sprite:TypeSprite, newTexture:String):TypeSprite {
		if (sprite is BaseSprite)
			cast(sprite, BaseSprite).loadSheet(newTexture);

		if (sprite is FlxSprite) {
			final sheetPath:String = Paths.multExst('images/$newTexture', Paths.atlasFrameExts);
			final hasSheet:Bool = sheetPath != '';
			final textureType:TextureType = TextureType.getTypeFromPath(sheetPath, true);

			if (Paths.fileExists('images/$newTexture.png')) {
				if (hasSheet)
					try {
						cast(sprite, FlxSprite).frames = Paths.frames(newTexture);
					} catch(e) trace('Couldn\'t find asset "$newTexture", type "$textureType"');
				else loadImage(sprite, newTexture);
			}
		}
		return sprite;
	}

	inline public static function getDominantColor(sprite:FlxSprite):FlxColor {
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

	inline public static function setGraphicSizeUnstretched(sprite:FlxSprite, width:Int, height:Int):Void {
		sprite.setGraphicSize(width, height);
		if (sprite.width > sprite.height)
			sprite.scale.y = sprite.scale.x;
		else
			sprite.scale.x = sprite.scale.y;
	}

	/**
	 * Is basically FlxTypedGroup.resolveGroup().
	 * @param obj
	 * @return FlxGroup
	 */
	inline public static function getGroup(obj:FlxBasic):FlxGroup {
		var resolvedGroup:FlxGroup = @:privateAccess FlxTypedGroup.resolveGroup(obj);
		if (resolvedGroup == null) resolvedGroup = FlxG.state.persistentUpdate ? FlxG.state : (FlxG.state.subState == null ? FlxG.state : FlxG.state.subState);
		return resolvedGroup;
	}

	inline public static function addInfrontOf(obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup):Void {
		final group:FlxGroup = into == null ? getGroup(obj) : into;
		group.insert(group.members.indexOf(fromThis) + 1, obj);
	}

	inline public static function addBehind(obj:FlxBasic, fromThis:FlxBasic, ?into:FlxGroup):Void {
		final group:FlxGroup = into == null ? getGroup(obj) : into;
		group.insert(group.members.indexOf(fromThis), obj);
	}

	inline public static function getClassName(direct:Dynamic, provideFullPath:Bool = false):String {
		if (provideFullPath)
			return cast Type.getClassName(Type.getClass(direct));
		else {
			var path:Array<String> = Type.getClassName(Type.getClass(direct)).split('.');
			return cast path[path.length - 1];
		}
	}
}