package imaginative.utils;

import lime.ui.FileDialog;
import openfl.net.FileFilter;

class FileUtil {
	/**
	 * The filter for png files.
	 */
	public static final pngFilter:FileFilter = new FileFilter('PNG File (.png)', '*.png');
	/**
	 * The filter for json files.
	 */
	public static final jsonFilter:FileFilter = new FileFilter('Json File (.json)', '*.json');
	/**
	 * The filter for audio files.
	 */
	public static final audioFilter:FileFilter = new FileFilter('Audio File (.ogg)', '*.wav;*.mp3;*.ogg');

	static var fileRef:FileDialog;

	@:allow(imaginative.states.EngineProcess)
	inline static function init():Void {
		fileRef = new FileDialog();
	}
}