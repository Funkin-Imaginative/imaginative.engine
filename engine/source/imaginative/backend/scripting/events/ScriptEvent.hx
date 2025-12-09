package imaginative.backend.scripting.events;

// TODO: Rethink how events might work and if they should be script dependent.
class ScriptEvent {
	/**
	 * The event call return output.
	 */
	public var returnCall:Dynamic = null;

	/**
	 * If true whatever it does is prevented.
	 */
	public var prevented:Bool = false;
	@:allow(imaginative.backend.scripting.group.ScriptGroup.event)
	var continueLoop:Bool = true;

	/**
	 * Just sets prevent to true.
	 * @param finishLoop If false when running through a ScriptGroup halts the loop.
	 */
	inline public function prevent(finishLoop:Bool = true):Void
		haltLoop(finishLoop);
	/**
	 * Has the power to make the loop come to a halt.
	 * @param finishLoop If false when running through a ScriptGroup halts the loop.
	 */
	inline public function haltLoop(finishLoop:Bool = false):Void {
		prevented = true;
		continueLoop = finishLoop;
	}

	public function new() {}

	inline public function toString():String
		return '[${this.getClassName()}${prevented ? ' ~ Prevented' : ''}]';
}