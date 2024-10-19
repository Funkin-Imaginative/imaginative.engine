package backend.scripting.types;

final class InvaildScript extends Script {
	/**
	 * All possible invaild script extension types.
	 */
	public static final exts:Array<String> = ['this array is useless lmao'];

	override public function new(path:String) {
		trace('Extension "${FilePath.extension(path).toLowerCase()}" is invaild!');
		super(path);
	}
}