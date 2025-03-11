package imaginative.objects;

class MenuSprite extends FlxSpriteGroup {
	public static final lineArtColors:Map<FlxColor, FlxColor> = [
		FlxColor.YELLOW => 0xFFDD7928,
		FlxColor.BLUE => 0xFF2847DD,
		FlxColor.MAGENTA => 0xFFDD28A7,
		FlxColor.GRAY => 0xFF8E8E8E
	];
	public static final blankBgColors:Map<FlxColor, FlxColor> = [
		FlxColor.YELLOW => 0xFFFDE871,
		FlxColor.BLUE => 0xFF9271FD,
		FlxColor.MAGENTA => 0xFFFD719B,
		FlxColor.GRAY => 0xFFE1E1E1
	];

	public var blankBg:FlxSprite;
	public var lineArt:FlxSprite;

	/**
	 * @param x The x position.
	 * @param y The y position.
	 * @param color FlxColor input.
	 * @param funkinColor It true, when using FlxColor YELLOW, BLUE, MAGENTA, or GRAY, it will use the menuBG color instead.
	 * @param mod The mod type.
	 */
	override public function new(x:Float = 0, y:Float = 0, color:FlxColor = FlxColor.YELLOW, funkinColor:Bool = true, mod:ModType = ANY) {
		super(x, y);

		lineArt = new FlxSprite().loadImage('$mod:menus/bgs/menuArt');
		blankBg = new FlxSprite().makeGraphic(Math.floor(lineArt.width), Math.floor(lineArt.height));

		changeColor(color, funkinColor);

		add(blankBg);
		add(lineArt);
	}

	inline public function changeColor(color:FlxColor = FlxColor.YELLOW, funkinColor:Bool = true):Void {
		lineArt.color = (funkinColor && lineArtColors.exists(color)) ? lineArtColors.get(color) : color - 0xFF646464;
		blankBg.color = (funkinColor && blankBgColors.exists(color)) ? blankBgColors.get(color) : color;
	}
}