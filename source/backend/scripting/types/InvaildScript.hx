package backend.scripting.types;

/**
 * This class doesn't handle script instances. It's used to represent an invaild language type.
 */
final class InvaildScript extends Script {
	@:allow(backend.scripting.Script.create)
	override function new(path:String, ?_:String) {
		trace('Extension "${FilePath.extension(path).toLowerCase()}" is invaild!');
		super(path, null);
	}
}