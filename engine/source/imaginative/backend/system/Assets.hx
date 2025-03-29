package imaginative.backend.system;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;

class Assets {
	public static var dumpExclusions:Array<ModPath> = [
		Paths.music('main:breakfast'),
		Paths.music('main:freakyMenu')
	];
	public static function excludeAsset(path:ModPath):Void {
		if (!dumpExclusions.contains(path))
			dumpExclusions.push(path);
	}
	public static var localGraphics:Array<ModPath>;
	public static var loadedGraphics:Map<String, FlxGraphic>;

	public static function image(file:ModPath):FlxGraphic {
		var bitmap:BitmapData;
		if (loadedGraphics.exists(file)) {
			localGraphics.push(file);
			return loadedGraphics.get(file);
		}
		return null;
	}
}