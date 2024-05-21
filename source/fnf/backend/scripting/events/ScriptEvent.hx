package fnf.backend.scripting.events;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

@:noCustomClass class ScriptEvent implements IFlxDestroyable {
	public var stopped:Bool = false;
	private var continueLoop:Bool = true;

	public function fullyStop(finishLoop:Bool = true) stopCompletely(finishLoop);
	public function stopCompletely(finishLoop:Bool = true) {
		stopped = true;
		continueLoop = finishLoop;
	}

	public var data:Dynamic = {};
	public function new(data:Dynamic = {}) {this.data = data;}

	public function toString():String return '[${CoolUtil.getClassName(this)}${stopped ? ' (Stopped)' : ''}]';

	public function destroy() {}
}