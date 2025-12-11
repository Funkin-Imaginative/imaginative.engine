package imaginative.backend.system;

import hxhardware.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import imaginative.utils.FunkinUtil;

/**
 * @author @Zyflx & @rodney528
 */
class EngineInfoText extends Sprite {
	// TODO: Remove bg once I get a proper text border working.
	var background:Bitmap;
	var text:TextField;

	var framesPerSecond:Int = 0;

	var boxDistanceOffset:Float = 5;

	override public function new() {
		super();
		addChild(background = new Bitmap(new BitmapData(1, 1, true, 0x99000000)));
		addChild(text = new TextField());

		text.x = text.y = boxDistanceOffset;
		text.autoSize = LEFT;
		text.selectable = text.mouseEnabled = false;
		text.defaultTextFormat = new TextFormat(Paths.font('lead:vcr.ttf').format(), 20, FlxColor.WHITE);

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	// Credits to @Vortex2Oblivion for helping out!
	var _framesPassed:Int = 0;
	var _previousTime:Float = 0;
	var _updateClock:Float = 999999;

	function onEnterFrame(e:Event):Void {
		_framesPassed++;

		final deltaTime:Float = Math.max(FunkinUtil.getTimerPrecise() - _previousTime, 0);
		_updateClock += deltaTime;

		if (_updateClock >= 1000) {
			framesPerSecond = (FlxG.drawFramerate > 0) ? FlxMath.minInt(_framesPassed, FlxG.drawFramerate) : _framesPassed;

			text.text = [
				['Framerate', [Std.string(framesPerSecond), Settings.setup.fpsType == Unlimited ? '' : Std.string(Main.getFPS())].join(' / ')].join(': '),
				['Memory', [Memory.getProcessPhysicalMemoryUsage().formatBytes(), Memory.getProcessPeakPhysicalMemoryUsage().formatBytes()].join(' / ')].join(': '),
				['CPU', ['${FlxMath.roundDecimal(CPU.getProcessCPUUsage(), 2)}%', '${FlxMath.roundDecimal(CPU.getProcessPeakCPUUsage(), 2)}%'].join(' / ')].join(': '),
				'State: ${FlxG.state.getClassName(FlxG.state.getClassName() != 'ScriptedState')}${FlxG.state.getClassName() == 'ScriptedState' ? '(${imaginative.backend.scripting.states.ScriptedState.prevName})' : ''}'
			].join('\n');

			text.textColor = framesPerSecond < (Settings.setup.fpsType == Unlimited ? FlxWindow.instance.monitorRefreshRate : Main.getFPS()) * 0.5 ? FlxColor.RED : FlxColor.WHITE;

			background.x = text.x;
			background.y = text.y;
			background.width = text.width + boxDistanceOffset;
			background.height = text.height + boxDistanceOffset;

			_framesPassed = 0;
			_updateClock = 0;
		}
		_previousTime = FunkinUtil.getTimerPrecise();
	}
}