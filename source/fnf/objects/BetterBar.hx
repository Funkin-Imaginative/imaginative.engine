package fnf.objects;

import flixel.ui.FlxBar;

typedef BarColors = {
	var enemy:FlxColor;
	var player:FlxColor;
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
	public function toFlxVersion():FlxBarFillDirection
		return switch (this) {
			case LEFT_RIGHT: LEFT_TO_RIGHT;
			case RIGHT_LEFT: RIGHT_TO_LEFT;
			case TOP_BOTTOM: TOP_TO_BOTTOM;
			case BOTTOM_TOP: BOTTOM_TO_TOP;
			case HORI_INSIDE_OUT: HORIZONTAL_INSIDE_OUT;
			case HORI_OUTSIDE_IN: HORIZONTAL_OUTSIDE_IN;
			case VERT_INSIDE_OUT: VERTICAL_INSIDE_OUT;
			case VERT_OUTSIDE_IN: VERTICAL_OUTSIDE_IN;
			default: null; // ಠ_ಠ why tf
		}

	public static function getFlxVersion(fillDir:BetterBarFillDirection):FlxBarFillDirection
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

	public static function getBetterFromFlx(fillDir:FlxBarFillDirection):BetterBarFillDirection
		return switch (fillDir) {
			case LEFT_TO_RIGHT: LEFT_RIGHT;
			case RIGHT_TO_LEFT: RIGHT_LEFT;
			case TOP_TO_BOTTOM: TOP_BOTTOM;
			case BOTTOM_TO_TOP: BOTTOM_TOP;
			case HORIZONTAL_INSIDE_OUT: HORI_INSIDE_OUT;
			case HORIZONTAL_OUTSIDE_IN: HORI_OUTSIDE_IN;
			case VERTICAL_INSIDE_OUT: VERT_INSIDE_OUT;
			case VERTICAL_OUTSIDE_IN: VERT_OUTSIDE_IN;
		}
}

class BetterBar extends FlxBar {
	public var centerPoint:PositionMeta = new PositionMeta();
	public var colors(default, set):BarColors = {enemy: 0xff005100, player: 0xff00F400} // lol
	inline function set_colors(value:BarColors):BarColors {
		createFilledBar(value.enemy, value.player);
		return colors = value;
	}
	public var blankColors(default, set):BarColors = {enemy: 0xff005100, player: 0xff00F400} // jic
	inline function set_blankColors(value:BarColors):BarColors {
		if (colors.enemy == blankColors.enemy) colors.enemy = value.enemy;
		if (colors.player == blankColors.player) colors.player = value.player;
		return blankColors = value;
	}

	public function new(x:Float = 0, y:Float = 0, ?direction:BetterBarFillDirection, width:Int = 100, height:Int = 10, ?parentRef:Dynamic, variable:String = '', min:Float = 0, max:Float = 100, showBorder:Bool = false) {
		super(x, y, direction.toFlxVersion(), width, height, parentRef, variable, min, max, showBorder);
	}

	override public function updateBar() {
		super.updateBar();
		switch (fillDirection) {
			case LEFT_TO_RIGHT: centerPoint.set(x + width * FlxMath.remapToRange(percent, 100, 0, 1, 0), y + (height / 2));
			case RIGHT_TO_LEFT: centerPoint.set(x + width * FlxMath.remapToRange(percent, 0, 100, 1, 0), y + (height / 2));
			case TOP_TO_BOTTOM: centerPoint.set(x + (width / 2), y + height * FlxMath.remapToRange(percent, 100, 0, 1, 0));
			case BOTTOM_TO_TOP: centerPoint.set(x + (width / 2), y + height * FlxMath.remapToRange(percent, 0, 100, 1, 0));
			default: centerPoint.set(x + (width / 2), y + (height / 2));
		}
	}

	public function setFillDirection(newFillDirection:BetterBarFillDirection):BetterBar {
		fillDirection = newFillDirection.toFlxVersion();
		return this;
	}

	public function changeBlankColors(?enemy:FlxColor, ?player:FlxColor):BarColors {
		if (enemy != null) blankColors.enemy = enemy;
		if (player != null) blankColors.player = player;
		return blankColors;
	}
	public function changeColors(?enemy:FlxColor, ?player:FlxColor):BarColors {
		colors.enemy = enemy == null ? blankColors.enemy : enemy;
		colors.player = player == null ? blankColors.player : player;
		return colors;
	}
}