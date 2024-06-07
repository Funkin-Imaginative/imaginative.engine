package fnf.objects;

import flixel.ui.FlxBar;

typedef BarColors = {
	var left:FlxColor;
	var right:FlxColor;
}

class FunkinBar extends FlxBar {
	public var colors:BarColors = {left: 0xff005100, right: 0xff00F400} // lol
    public function new(x:Float = 0, y:Float = 0, ?direction:FlxBarFillDirection, width:Int = 100, height:Int = 10, ?parentRef:Dynamic, variable:String = '', min:Float = 0, max:Float = 100, showBorder:Bool = false) super(x, y, direction, width, height, parentRef, variable, min, max, showBorder);
	override public function createColoredFilledBar(fill:FlxColor, showBorder:Bool = false, border:FlxColor = FlxColor.WHITE):FlxBar return super.createColoredFilledBar(colors.left = fill, showBorder, border);
	override public function createColoredEmptyBar(empty:FlxColor, showBorder:Bool = false, border:FlxColor = FlxColor.WHITE):FlxBar return super.createColoredEmptyBar(colors.right = empty, showBorder, border);
}