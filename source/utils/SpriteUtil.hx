package utils;

import flixel.graphics.frames.FlxAtlasFrames;

typedef TypeSprite = OneOfThree<FlxSprite, BaseSprite, BeatSprite>;
typedef TypeSpriteData = OneOfThree<SpriteData, BeatSpriteData, CharacterSpriteData>;

typedef CharacterSpriteData = {
	> BeatSpriteData,
	var character:Character.CharacterData;
}
typedef BeatSpriteData = {
	> SpriteData,
	var beat:BeatSprite.BeatData;
}
typedef SpriteData = {
	> BaseSprite.ObjectData,
	@:optional var offsets:BaseSprite.OffsetsData;
	@:optional var extra:Array<utils.ParseUtil.ExtraData>;
}

typedef AnimMapping = {
	var offset:PositionStruct;
	var swappedAnim:String;
	var flippedAnim:String;
}

enum abstract ObjectType(String) from String to String {
	var CHARACTER = 'character';
	var BEAT = 'beat';
	var BASE = null;
}

class SpriteUtil {
	inline public static function loadTexture(sprite:TypeSprite, newTexture:String):TypeSprite {
		if (sprite is BaseSprite) {
			cast(sprite, BaseSprite).loadTexture(newTexture);
			return sprite;
		}
		var hasSheet:Bool = Paths.multExst('images/$newTexture', Paths.atlasFrameExts) != '';
		if (Paths.fileExists('images/$newTexture.png'))
			if (hasSheet) loadSheet(sprite, newTexture);
			else loadImage(sprite, newTexture);
		return sprite;
	}

	inline public static function loadImage(sprite:TypeSprite, newTexture:String):TypeSprite {
		if (sprite is BaseSprite) {
			cast(sprite, BaseSprite).loadImage(newTexture);
			return sprite;
		}
		if (sprite is FlxSprite) {
			if (Paths.fileExists('images/$newTexture.png'))
				try {
					cast(sprite, FlxSprite).loadGraphic(Paths.image(newTexture));
				}
			return sprite;
		}
		return sprite;
	}

	inline public static function loadSheet(sprite:TypeSprite, newTexture:String):TypeSprite {
		if (sprite is BaseSprite) {
			cast(sprite, BaseSprite).loadSheet(newTexture);
			return sprite;
		}
		if (sprite is FlxSprite) {
			var hasSheet:Bool = Paths.multExst('images/$newTexture', Paths.atlasFrameExts) != '';
			if (Paths.fileExists('images/$newTexture.png') && hasSheet)
				try {
					cast(sprite, FlxSprite).frames = Paths.frames(newTexture);
				}
			return sprite;
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
}