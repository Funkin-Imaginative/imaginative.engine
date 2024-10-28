package backend.scripting.events;

class ScriptEvent {
	/**
	 * The event call return output.
	 */
	public var returnCall:Dynamic = null;

	/**
	 * If true, whatever it does is prevented.
	 */
	public var prevented:Bool = false;
	@:allow(backend.scripting.group.ScriptGroup.event)
	var continueLoop:Bool = true;

	/**
	 * Just sets prevent to true.
	 * @param finishLoop If false, when running through a ScriptGroup halts the loop.
	 */
	inline public function prevent(finishLoop:Bool = true):Void
		haltLoop(finishLoop);
	/**
	 * Has the power to make the loop come to a halt.
	 * @param finishLoop If false, when running through a ScriptGroup halts the loop.
	 */
	inline public function haltLoop(finishLoop:Bool = false):Void {
		prevented = true;
		continueLoop = finishLoop;
	}

	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Dynamic = {}
	public function new(?data:Dynamic)
		if (data != null)
			extra = data;

	inline public function toString():String
		return '[${this.getClassName()}${prevented ? ' ~ Prevented' : ''}]';
}