package backend.scripting.types;

/**
 * This class doesn't handle script instances. It's used to represent an invaild language type.
 */
final class InvaildScript extends Script {
	@:allow(backend.scripting.Script.create)
	override function new(file:ModPath, ?_:String) {
		trace('Extension "${file.extension.toLowerCase()}" is invaild!');
		super(file, null);
	}
}