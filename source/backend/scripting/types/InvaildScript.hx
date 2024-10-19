package backend.scripting.types;

final class InvaildScript extends Script {
	/**
	 * All possible invaild script extension types.
	 */
	public static final exts:Array<String> = ['this array is useless lmao'];

	@:allow(backend.scripting.Script.create)
	override function new(path:String, ?_:String) {
		trace('Extension "${FilePath.extension(path).toLowerCase()}" is invaild!');
		super(path, null);
	}
}