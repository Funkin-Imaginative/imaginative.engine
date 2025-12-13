package imaginative.backend.scripting.types;

/**
 * This class doesn't handle script instances. It's used to represent an invalid language type.
 */
final class InvalidScript extends Script {
	@:allow(imaginative.backend.scripting.Script._create)
	@:allow(imaginative.backend.scripting.Script.loadCodeFromString)
	override function new(file:ModPath) {
		if (file.isFile && !file.extension.isNullOrEmpty())
			_log('[Script] Extension "${file.extension.toLowerCase()}" is invalid! (file:${file.format()})');
		super(file, null);
	}
}