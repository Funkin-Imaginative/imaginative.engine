package utils;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RGB<T> = {
	var red:T;
	var green:T;
	var blue:T;
	@:optional var alpha:T;
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef CMYK = {
	var cyan:Float;
	var magenta:Float;
	var yellow:Float;
	var black:Float;
	@:optional var alpha:Float;
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef HSB = {
	var hue:Float;
	var saturation:Float;
	var brightness:Float;
	@:optional var alpha:Float;
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef HSL = {
	var hue:Float;
	var saturation:Float;
	var lightness:Float;
	@:optional var alpha:Float;
}

/**
 * Note: This class only really does the functions in `FlxColor` that WEREN'T `static`!
 * For all your scripting needs!
 * `inline` is still called because it just felt right to me.
 * You could also actually do `using` for this class if you wanted to I guess?
 * And before you ask "where's the documenttaion??????", everything here is self-explanatory.
 */
@SuppressWarnings('checkstyle:FieldDocComment')
@:noUsing class FlxColorUtil {
	// RGB
	inline public static function getRed(color:FlxColor):Int
		return color.red;
	inline public static function setRed(color:FlxColor, value:Int):FlxColor {
		color.red = value;
		return color;
	}

	inline public static function getGreen(color:FlxColor):Int
		return color.green;
	inline public static function setGreen(color:FlxColor, value:Int):FlxColor {
		color.green = value;
		return color;
	}

	inline public static function getBlue(color:FlxColor):Int
		return color.blue;
	inline public static function setBlue(color:FlxColor, value:Int):FlxColor {
		color.blue = value;
		return color;
	}

	// Float
	inline public static function getRedFloat(color:FlxColor):Float
		return color.redFloat;
	inline public static function setRedFloat(color:FlxColor, value:Float):FlxColor {
		color.redFloat = value;
		return color;
	}

	inline public static function getGreenFloat(color:FlxColor):Float
		return color.greenFloat;
	inline public static function setGreenFloat(color:FlxColor, value:Float):FlxColor {
		color.greenFloat = value;
		return color;
	}

	inline public static function getBlueFloat(color:FlxColor):Float
		return color.blueFloat;
	inline public static function setBlueFloat(color:FlxColor, value:Float):FlxColor {
		color.blueFloat = value;
		return color;
	}

	// Alpha
	inline public static function getAlpha(color:FlxColor):Int
		return color.alpha;
	inline public static function setAlpha(color:FlxColor, value:Int):FlxColor {
		color.alpha = value;
		return color;
	}

	// Float
	inline public static function getAlphaFloat(color:FlxColor):Float
		return color.alphaFloat;
	inline public static function setAlphaFloat(color:FlxColor, value:Float):FlxColor {
		color.alphaFloat = value;
		return color;
	}

	// CMYK
	inline public static function getCyan(color:FlxColor):Float
		return color.cyan;
	inline public static function setCyan(color:FlxColor, value:Float):FlxColor {
		color.cyan = value;
		return color;
	}

	inline public static function getMagenta(color:FlxColor):Float
		return color.magenta;
	inline public static function setMagenta(color:FlxColor, value:Float):FlxColor {
		color.magenta = value;
		return color;
	}

	inline public static function getYellow(color:FlxColor):Float
		return color.yellow;
	inline public static function setYellow(color:FlxColor, value:Float):FlxColor {
		color.yellow = value;
		return color;
	}

	inline public static function getBlack(color:FlxColor):Float
		return color.black;
	inline public static function setBlack(color:FlxColor, value:Float):FlxColor {
		color.black = value;
		return color;
	}

	// HSB and don't forget HSL!
	inline public static function getHue(color:FlxColor):Float
		return color.hue;
	inline public static function setHue(color:FlxColor, value:Float):FlxColor {
		color.hue = value;
		return color;
	}

	inline public static function getSaturation(color:FlxColor):Float
		return color.saturation;
	inline public static function setSaturation(color:FlxColor, value:Float):FlxColor {
		color.saturation = value;
		return color;
	}

	inline public static function getBrightness(color:FlxColor):Float
		return color.brightness;
	inline public static function setBrightness(color:FlxColor, value:Float):FlxColor {
		color.brightness = value;
		return color;
	}

	inline public static function getLightness(color:FlxColor):Float
		return color.lightness;
	inline public static function setLightness(color:FlxColor, value:Float):FlxColor {
		color.lightness = value;
		return color;
	}

	// Harmonies
	inline public static function getComplementHarmony(color:FlxColor):FlxColor
		return color.getComplementHarmony();

	inline public static function getAnalogousHarmony(color:FlxColor, threshold:Int = 30):Harmony
		return color.getAnalogousHarmony(threshold);

	inline public static function getSplitComplementHarmony(color:FlxColor, threshold:Int = 30):Harmony
		return color.getSplitComplementHarmony(threshold);

	inline public static function getTriadicHarmony(color:FlxColor):TriadicHarmony
		return color.getTriadicHarmony();

	// Formatters
	inline public static function to24Bit(color:FlxColor):FlxColor
		return color.to24Bit();

	inline public static function toHexString(color:FlxColor, alpha:Bool = true, prefix:Bool = true):String
		return color.toHexString(alpha, prefix);

	inline public static function toWebString(color:FlxColor):String
		return color.toWebString();

	inline public static function getColorInfo(color:FlxColor):String
		return color.getColorInfo();

	// Effectors
	inline public static function getDarkened(color:FlxColor, factor:Float = 0.2):FlxColor
		return color.getDarkened(factor);

	inline public static function getLightened(color:FlxColor, factor:Float = 0.2):FlxColor
		return color.getLightened(factor);

	inline public static function getInverted(color:FlxColor):FlxColor
		return color.getInverted();

	// Group Setters
	inline public static function setRGB(color:FlxColor, red:Int, green:Int, blue:Int, alpha:Int = 255):FlxColor
		return color.setRGB(red, green, blue, alpha);
	inline public static function setRGBFloat(color:FlxColor, red:Float, green:Float, blue:Float, alpha:Float = 1):FlxColor
		return color.setRGBFloat(red, green, blue, alpha);

	inline public static function setCMYK(color:FlxColor, cyan:Float, magenta:Float, yellow:Float, black:Float, alpha:Float = 1):FlxColor
		return color.setCMYK(cyan, magenta, yellow, black, alpha);

	inline public static function setHSB(color:FlxColor, hue:Float, saturation:Float, brightness:Float, alpha:Float):FlxColor
		return color.setHSB(hue, saturation, brightness, alpha);

	inline public static function setHSL(color:FlxColor, hue:Float, saturation:Float, lightness:Float, alpha:Float):FlxColor
		return color.setHSL(hue, saturation, lightness, alpha);

	// Custom Extras
	inline public static function getRGB(color:FlxColor):RGB<Int>
		return {
			red: color.red,
			green: color.green,
			blue: color.blue,
			alpha: color.alpha
		}
	inline public static function getRGBFloat(color:FlxColor):RGB<Float>
		return {
			red: color.redFloat,
			green: color.greenFloat,
			blue: color.blueFloat,
			alpha: color.alphaFloat
		}

	inline public static function getCMYK(color:FlxColor):CMYK
		return {
			cyan: color.cyan,
			magenta: color.magenta,
			yellow: color.yellow,
			black: color.black,
			alpha: color.alphaFloat
		}

	inline public static function getHSB(color:FlxColor):HSB
		return {
			hue: color.hue,
			saturation: color.saturation,
			brightness: color.brightness,
			alpha: color.alphaFloat
		}

	inline public static function getHSL(color:FlxColor):HSL
		return {
			hue: color.hue,
			saturation: color.saturation,
			lightness: color.lightness,
			alpha: color.alphaFloat
		}
}