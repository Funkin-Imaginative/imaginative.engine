package imaginative.backend.system;

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

	var memoryPeakUsage:Float = 0;
	var memoryUsage(get, never):Float;
	inline function get_memoryUsage():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);

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

		if (memoryPeakUsage < memoryUsage)
			memoryPeakUsage = memoryUsage;

		// TODO: Have it say the script file path.
		text.text = [
			'Framerate: ${framesPerSecond = times.length}${Settings.setup.fpsType == Unlimited ? '' : ' / ${Main.getFPS()}'}',
			'Memory: ${memoryUsage.formatBytes()} / ${memoryPeakUsage.formatBytes()}',
			'State: ${FlxG.state.getClassName(FlxG.state.getClassName() != 'ScriptedState')}${FlxG.state.getClassName() == 'ScriptedState' ? '(${imaginative.backend.scripting.states.ScriptedState.prevName})' : ''}'
		].join('\n');
		text.textColor = framesPerSecond < (Settings.setup.fpsType == Unlimited ? FlxWindow.direct.self.displayMode.refreshRate : Main.getFPS()) * 0.5 ? FlxColor.RED : FlxColor.WHITE;

		background.x = text.x;
		background.y = text.y;
		background.width = text.width + boxDistanceOffset;
		background.height = text.height + boxDistanceOffset;
	}
}