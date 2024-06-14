package fnf.objects;

import flixel.ui.FlxBar;

class BarColors {
	public var parent:BetterBar;
	public var isBlank:Bool = false;
	public var enemy(default, set):FlxColor = 0xff005100;
	public var player(default, set):FlxColor = 0xff00F400;

	inline function set_enemy(value:FlxColor):FlxColor {
		value.alphaFloat = 1;
		if (parent != null && !isBlank) parent.createFilledBar(value, player);
		return enemy = value;
	}
	inline function set_player(value:FlxColor):FlxColor {
		value.alphaFloat = 1;
		if (parent != null && !isBlank) parent.createFilledBar(enemy, value);
		return player = value;
	}

	public function new(?parent:BetterBar, ?enemy:FlxColor, ?player:FlxColor) {
		if (parent != null) this.parent = parent;
		if (enemy != null) this.enemy = enemy;
		if (player != null) this.player = player;
	}
}

enum abstract BetterBarFillDirection(String) from String to String {
	var LEFT_RIGHT = 'left to right';
	var RIGHT_LEFT = 'right to left';
	var TOP_BOTTOM = 'top to bottom';
	var BOTTOM_TOP = 'bottom to top';
	var HORI_INSIDE_OUT = 'horizontal, inside-out';
	var HORI_OUTSIDE_IN = 'horizontal, outside-in';
	var VERT_INSIDE_OUT = 'vertical, inside-out';
	var VERT_OUTSIDE_IN = 'vertical, outside-in';

	// realized after making this function that you probably can't use it in hscript... well shi-
	public function toFlxVersion():FlxBarFillDirection {
		return switch (this) {
			case LEFT_RIGHT: LEFT_TO_RIGHT;
			case RIGHT_LEFT: RIGHT_TO_LEFT;
			case TOP_BOTTOM: TOP_TO_BOTTOM;
			case BOTTOM_TOP: BOTTOM_TO_TOP;
			case HORI_INSIDE_OUT: HORIZONTAL_INSIDE_OUT;
			case HORI_OUTSIDE_IN: HORIZONTAL_OUTSIDE_IN;
			case VERT_INSIDE_OUT: VERTICAL_INSIDE_OUT;
			case VERT_OUTSIDE_IN: VERTICAL_OUTSIDE_IN;
			default: null; // ಠ_ಠ wtf
		}
	}

	public static function getFlxVersion(fillDir:BetterBarFillDirection):FlxBarFillDirection {
		return switch (fillDir) {
			case LEFT_RIGHT: LEFT_TO_RIGHT;
			case RIGHT_LEFT: RIGHT_TO_LEFT;
			case TOP_BOTTOM: TOP_TO_BOTTOM;
			case BOTTOM_TOP: BOTTOM_TO_TOP;
			case HORI_INSIDE_OUT: HORIZONTAL_INSIDE_OUT;
			case HORI_OUTSIDE_IN: HORIZONTAL_OUTSIDE_IN;
			case VERT_INSIDE_OUT: VERTICAL_INSIDE_OUT;
			case VERT_OUTSIDE_IN: VERTICAL_OUTSIDE_IN;
		}
	}
}

class BetterBar extends FlxBar {
	public var midPoint:PositionMeta = new PositionMeta();
	public var colors:BarColors; // lol
	public var blankColors:BarColors; // jic
	public function new(x:Float = 0, y:Float = 0, ?direction:BetterBarFillDirection, width:Int = 100, height:Int = 10, ?parentRef:Dynamic, variable:String = '', min:Float = 0, max:Float = 100, showBorder:Bool = false) {
		super(x, y, direction.toFlxVersion(), width, height, parentRef, variable, min, max, showBorder);
		colors = blankColors = new BarColors(this);
		blankColors.isBlank = true;
		changeColors();
	}

	override function updateBar() {
		super.updateBar();
		switch (fillDirection) {
			case LEFT_TO_RIGHT: midPoint.set(x + width * FlxMath.remapToRange(percent, 100, 0, 1, 0), y + (height / 2));
			case RIGHT_TO_LEFT: midPoint.set(x + width * FlxMath.remapToRange(percent, 0, 100, 1, 0), y + (height / 2));
			case TOP_TO_BOTTOM: midPoint.set(x + (width / 2), y + height * FlxMath.remapToRange(percent, 100, 0, 1, 0));
			case BOTTOM_TO_TOP: midPoint.set(x + (width / 2), y + height * FlxMath.remapToRange(percent, 0, 100, 1, 0));
			default: midPoint.set(x + (width / 2), y + (height / 2));
		}
	}

	public function setFillDirection(newFillDirection:BetterBarFillDirection):BetterBar {
		fillDirection = newFillDirection.toFlxVersion();
		return this;
	}

	public function changeColors(?enemy:FlxColor, ?player:FlxColor, isBlankColors:Bool = false):BarColors {
		var setColors:BarColors = isBlankColors ? blankColors : colors;
		if (enemy != null) setColors.enemy = enemy;
		if (player != null) setColors.player = player;
		return setColors;
	}
	public function changeColorsUnsafe(?enemy:FlxColor, ?player:FlxColor, isBlankColors:Bool = false):BarColors {
		var setColors:BarColors = isBlankColors ? blankColors : colors;
		setColors.enemy = enemy == null ? blankColors.enemy : enemy;
		setColors.player = player == null ? blankColors.player : player;
		return setColors;
	}
}