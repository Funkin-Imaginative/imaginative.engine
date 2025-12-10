package imaginative.backend.system;

import hxhardware.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * @author @Zyflx & @rodney528
 */
class EngineInfoText extends Sprite {
	// TODO: Remove bg once I get a proper text border working.
	var background:Bitmap;
	var text:TextField;

	var framesPerSecond:Int = 0;

	var times:Array<Float> = [];

	var boxDistanceOffset:Float = 5;

	override public function new() {
		super();
		addChild(background = new Bitmap(new BitmapData(1, 1, true, 0x99000000)));
		addChild(text = new TextField());

		text.x = text.y = boxDistanceOffset;
		text.autoSize = LEFT;
		text.selectable = text.mouseEnabled = false;
		text.defaultTextFormat = new TextFormat(Paths.font('lead:vcr.ttf').format(), 20, FlxColor.WHITE);
	}

	override function __enterFrame(elapsed:Float):Void {
		var time:Float = haxe.Timer.stamp() * 1000;
		times.push(time);

		while (times[0] < time - 1000)
			times.shift();

		text.text = [
			'Framerate: ${framesPerSecond = times.length}${Settings.setup.fpsType == Unlimited ? '' : ' / ${Main.getFPS()}'}',
			'Memory: ${Memory.getProcessPhysicalMemoryUsage().formatBytes()} / ${Memory.getProcessPeakPhysicalMemoryUsage().formatBytes()}',
			'CPU: ${FlxMath.roundDecimal(CPU.getProcessCPUUsage(), 2)}% / ${FlxMath.roundDecimal(CPU.getProcessPeakCPUUsage(), 2)}%',
			'State: ${FlxG.state.getClassName(FlxG.state.getClassName() != 'ScriptedState')}${FlxG.state.getClassName() == 'ScriptedState' ? '(${imaginative.backend.scripting.states.ScriptedState.prevName})' : ''}'
		].join('\n');
		text.textColor = framesPerSecond < (Settings.setup.fpsType == Unlimited ? FlxWindow.instance.self.displayMode.refreshRate : Main.getFPS()) * 0.5 ? FlxColor.RED : FlxColor.WHITE;

		background.x = text.x;
		background.y = text.y;
		background.width = text.width + boxDistanceOffset;
		background.height = text.height + boxDistanceOffset;
	}
}