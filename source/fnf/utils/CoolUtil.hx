package fnf.utils;

using StringTools;

class CoolUtil {
	public static var difficultyArray:Array<String> = ['Easy', 'Normal', 'Hard'];

	inline public static function difficultyString():String return difficultyArray[PlayState.storyDifficulty];

	inline public static function splitTextByLine(path:String):Array<String> {
		var daList:Array<String> = Paths.getContent(path).split('\n');
		for (i in 0...daList.length) daList[i] = daList[i].trim();
		return daList;
	}

	inline public static function dominantColor(sprite:FlxSprite):FlxColor {
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth) {
			for (row in 0...sprite.frameHeight) {
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0) {
					if (countByColor.exists(colorOfThisPixel)) countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2*13520687)) countByColor[colorOfThisPixel] = 1;
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

	inline public static function numberArray(max:Int, ?min = 0):Array<Int> {
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);
		return dumbArray;
	}

	/**
	 * Lerps camera, but accountsfor framerate shit?
	 * Right now it's simply for use to change the followLerp variable of a camera during update
	 * TODO LATER MAYBE:
	 * 	Actually make and modify the scroll and lerp shit in it's own function
	 * 	instead of solely relying on changing the lerp on the fly
	 */
	inline public static function camLerpShit(lerp:Float):Float {return lerp * (FlxG.elapsed / (1 / 60));}

	// just lerp that does camLerpShit for u so u dont have to do it every time
	inline public static function coolLerp(a:Float, b:Float, ratio:Float):Float return FlxMath.lerp(a, b, camLerpShit(ratio));

	inline public static function getClassName(direct:Dynamic, provideFullPath:Bool = false):String {
		if (provideFullPath) return cast Type.getClassName(Type.getClass(direct)); else {
			var path:Array<String> = Type.getClassName(Type.getClass(direct)).split('.');
			return cast path[path.length - 1];
		}
	}
}