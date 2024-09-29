package backend.scripting.events;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class ScriptEvent implements IFlxDestroyable {
	public var stopped:Bool = false;
	var continueLoop:Bool = true;

	inline public function fullyStop(finishLoop:Bool = true):Void stopCompletely(finishLoop);
	inline public function stopCompletely(finishLoop:Bool = true):Void {
		stopped = true;
		continueLoop = finishLoop;
	}

	public var data:Dynamic = {}
	public function new(?data:Dynamic) this.data = data;

	inline public function toString():String return '[${SpriteUtil.getClassName(this)}${stopped ? ' (Stopped)' : ''}]';

	public function destroy():Void {}
}