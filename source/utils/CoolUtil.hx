package utils;

enum abstract MenuSFX(String) to String from String {
	var CONFIRM = 'confirm';
	var CANCEL = 'cancel';
	var SCROLL = 'scroll';
}

class CoolUtil {
	inline public static function getAsset(path:String, type:String = 'image', ?pathType:FunkinPath):String {
		return switch (type) {
			case 'txt': Paths.txt(path, pathType);
			case 'xml': Paths.xml(path, pathType);
			case 'json': Paths.json(path, pathType);
			default: Paths.image(path, pathType);
		}
	}

	inline public static function playMenuSFX(sound:MenuSFX, volume:Float = 1, ?onComplete:Void->Void):FlxSound {
		var menuSound:FlxSound = FlxG.sound.play(Paths.sound('menu/' + switch (sound) {
			case CONFIRM: 'confirm';
			case CANCEL: 'cancel';
			case SCROLL: 'scroll';
		}), volume, false, null, true, onComplete == null ?() -> {} : onComplete);
		return menuSound;
	}

	inline public static function mouseJustMoved(relativeToScreen:Bool = true):Bool {
		if (relativeToScreen)
			@:privateAccess return FlxG.mouse._prevScreenX != FlxG.mouse.screenX || FlxG.mouse._prevScreenY != FlxG.mouse.screenY;
		else
			return FlxG.mouse.justMoved;
	}

	inline public static function trimSplit(text:String):Array<String> {
		var daList:Array<String> = text.split('\n');
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
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

	inline public static function getClassName(direct:Dynamic, provideFullPath:Bool = false):String {
		if (provideFullPath)
			return cast Type.getClassName(Type.getClass(direct));
		else {
			var path:Array<String> = Type.getClassName(Type.getClass(direct)).split('.');
			return cast path[path.length - 1];
		}
	}

	/**
	 * Is basically FlxTypedGroup.resolveGroup().
	 * @param obj
	 * @return FlxGroup
	 */
	inline public static function getGroup(obj:FlxBasic):FlxGroup {
		var resolvedGroup:FlxGroup = @:privateAccess FlxTypedGroup.resolveGroup(obj);
		if (resolvedGroup == null)
			resolvedGroup = FlxG.state;
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