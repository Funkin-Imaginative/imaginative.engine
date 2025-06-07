package imaginative.utils;

import lime.ui.FileDialog;
import openfl.net.FileFilter;
import openfl.net.FileReference;

class FileUtil {
	/**
	 * The filter for png files.
	 */
	public static final pngFilter:FileFilter = new FileFilter('PNG File', '*.png');
	/**
	 * The filter for json files.
	 */
	public static final jsonFilter:FileFilter = new FileFilter('Json File', '*.json');
}