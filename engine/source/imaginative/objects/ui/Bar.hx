package imaginative.objects.ui;

import flixel.ui.FlxBar;

enum abstract BarFillDirection(String) from String to String {
	var LEFT_RIGHT = 'left to right';
	var RIGHT_LEFT = 'right to left';
	var TOP_BOTTOM = 'top to bottom';
	var BOTTOM_TOP = 'bottom to top';
	var HORI_INSIDE_OUT = 'horizontal, inside-out';
	var HORI_OUTSIDE_IN = 'horizontal, outside-in';
	var VERT_INSIDE_OUT = 'vertical, inside-out';
	var VERT_OUTSIDE_IN = 'vertical, outside-in';

	@:from public static function fromFlxVersion(from:FlxBarFillDirection):BarFillDirection {
		return switch (from) {
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

	@:to public function toFlxVersion():FlxBarFillDirection {
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
	}
}

class BarColors {
	var parent(null, null):Bar;
	public var enemy(default, set):Null<FlxColor>;
	inline function set_enemy(value:Null<FlxColor>):Null<FlxColor> {
		var result:Null<FlxColor> = value ?? (isBlank ? FlxColor.RED : parent.blankColors.enemy);
		parent.createColoredEmptyBar(result); parent.updateBar();
		return enemy = result;
	}
	public var player(default, set):FlxColor;
	inline function set_player(value:Null<FlxColor>):Null<FlxColor> {
		var result:Null<FlxColor> = value ?? (isBlank ? FlxColor.YELLOW : parent.blankColors.player);
		parent.createColoredFilledBar(result);
		return player = result;
	}

	var isBlank(null, null):Bool;
	public function new(parent:Bar, isBlank:Bool = false) {
		this.parent = parent;
		this.isBlank = isBlank;

		enemy = FlxColor.RED;
		player = FlxColor.YELLOW;
	}

	inline public function set(?enemy:FlxColor, ?player:FlxColor):BarColors {
		this.enemy = enemy;
		this.player = player;
		return this;
	}
}

/**
 * WIP
 */
class Bar extends FlxBar {
	/**
	 * The bar's center point.
	 * Used to help position icons.
	 */
	public var centerPoint:Position = new Position();
	/**
	 * When there are no colors, when does it default too?
	 */
	public var blankColors:BarColors;
	/**
	 * The bar colors.
	 */
	public var colors:BarColors;

	/**
	 * Dispatches when the bar updates.
	 * @param elapsed
	 */
	public var onBarUpdate(default, null):FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();

	public function new(x:Float = 0, y:Float = 0, ?direction:BarFillDirection, width:Int = 100, height:Int = 10, ?parentRef:Dynamic, variable:String = '', min:Float = 0, max:Float = 100, showBorder:Bool = false) {
		super(x, y, direction, width, height, parentRef, variable, min, max, showBorder);
		blankColors = new BarColors(this, true);
		colors = new BarColors(this);
		update(0); updateBar();
	}

	override function updateValueFromParent():Void {
		if (parent is IScript) { // script support
			var script:IScript = cast parent;
			value = FlxMath.bound(script.get(parentVariable, value), min, max);
			script.set(parentVariable, value);
		} else {
			value = FlxMath.bound(Reflect.getProperty(parent, parentVariable), min, max);
			Reflect.setProperty(parent, parentVariable, value);
		}
	}

	override public function updateBar():Void {
		super.updateBar();
		switch (fillDirection) {
			case LEFT_TO_RIGHT: centerPoint.set(x + width * FlxMath.remapToRange(percent, 100, 0, 1, 0), y + (height / 2));
			case RIGHT_TO_LEFT: centerPoint.set(x + width * FlxMath.remapToRange(percent, 0, 100, 1, 0), y + (height / 2));
			case TOP_TO_BOTTOM: centerPoint.set(x + (width / 2), y + height * FlxMath.remapToRange(percent, 100, 0, 1, 0));
			case BOTTOM_TO_TOP: centerPoint.set(x + (width / 2), y + height * FlxMath.remapToRange(percent, 0, 100, 1, 0));
			default: centerPoint.set(x + (width / 2), y + (height / 2));
		}
		onBarUpdate.dispatch(FlxG.elapsed);
	}

	inline public function setColors(?enemy:FlxColor, ?player:FlxColor, isBlank:Bool = false):Bar {
		(isBlank ? blankColors : colors).set(enemy, player);
		return this;
	}

	inline public function setFillDirection(newFillDirection:BarFillDirection):Bar {
		fillDirection = newFillDirection;
		return this;
	}
}