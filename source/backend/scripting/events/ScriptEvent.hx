package backend.scripting.events;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class ScriptEvent implements IFlxDestroyable {
	public var stopped:Bool = false;
	private var continueLoop:Bool = true;

	inline public function fullyStop(finishLoop:Bool = true) stopCompletely(finishLoop);
	inline public function stopCompletely(finishLoop:Bool = true) {
		stopped = true;
		continueLoop = finishLoop;
	}

	public var data:Dynamic = {}
	public function new(?data:Dynamic) this.data = data;

	inline public function toString():String return '[${CoolUtil.getClassName(this)}${stopped ? ' (Stopped)' : ''}]';

	public function destroy() {}
}