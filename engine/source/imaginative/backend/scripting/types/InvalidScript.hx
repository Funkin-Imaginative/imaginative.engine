package imaginative.backend.scripting.types;

/**
 * This class doesn't handle script instances. It's used to represent an invalid language type.
 */
final class InvalidScript extends Script {
	@:allow(imaginative.backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		_log('[Script] Extension "${file.extension.toLowerCase()}" is invalid!', SystemMessage);
		super(file, null);
	}
}