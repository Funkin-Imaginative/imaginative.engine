package backend.scripting.types;

/**
 * This class doesn't handle script instances. It's used to represent an invalid language type.
 */
final class InvalidScript extends Script {
	@:allow(backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		log('Extension "${file.extension.toLowerCase()}" is invalid!', SystemMessage);
		super(file, null);
	}
}