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
	 * @param funkinColor It true, when using FlxColor YELLOW, BLUE, MAGENTA, or GRAY it will use the menuBG color instead.
	 * @param imagePathType The mod path type.
	 */
	override public function new(x:Float = 0, y:Float = 0, color:FlxColor = FlxColor.YELLOW, funkinColor:Bool = true, imagePathType:ModType = ANY) {
		super(x, y);

		lineArt = new FlxSprite().loadImage('$imagePathType:menus/bgs/menuArt');
		blankBg = new FlxSprite().makeGraphic(Math.floor(lineArt.width), Math.floor(lineArt.height));

		changeColor(color, funkinColor);

		add(blankBg);
		add(lineArt);
	}

	inline public function changeColor(color:FlxColor = FlxColor.YELLOW, funkinColor:Bool = true):FlxColor {
		lineArt.color = (funkinColor && lineArtColors.exists(color)) ? lineArtColors.get(color) : color - 0xFF646464;
		return blankBg.color = (funkinColor && blankBgColors.exists(color)) ? blankBgColors.get(color) : color;
	}

	inline public function updateScale(x:Float = 1, ?y:Float, updateHitbox:Bool = true):Void {
		for (obj in [blankBg, lineArt]) {
			obj.scale.set(x, y ?? x);
			if (updateHitbox)
				obj.updateHitbox();
		}
	}
	inline public function updateSize(width:Int = 0, height:Int = 0, updateHitbox:Bool = true):Void {
		for (obj in [blankBg, lineArt]) {
			obj.setGraphicSize(width, height);
			if (updateHitbox)
				obj.updateHitbox();
		}
	}
	inline public function updateSizeUnstretched(width:Int = 0, height:Int = 0, fill:Bool = true, maxScale:Float = 0, updateHitbox:Bool = true):Void {
		for (obj in [blankBg, lineArt]) {
			obj.setUnstretchedGraphicSize(width, height, fill, maxScale);
			if (updateHitbox)
				obj.updateHitbox();
		}
	}
}