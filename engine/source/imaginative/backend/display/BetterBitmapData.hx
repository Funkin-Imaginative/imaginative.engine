package imaginative.backend.display;

import lime.graphics.Image;
import lime.graphics.cairo.CairoImageSurface;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * Used for GPU caching!
 */
class BetterBitmapData extends BitmapData {
	override function __fromImage(image:Image):Void {
		if (!Settings.setup.gpuCaching) {
			super.__fromImage(image);
			return;
		}
		if (image != null && image.buffer != null) {
			this.image = image;

			width = image.width;
			height = image.height;
			rect = new Rectangle(0, 0, image.width, image.height);

			__textureWidth = width;
			__textureHeight = height;

			#if sys
			image.format = BGRA32;
			image.premultiplied = true;
			#end

			readable = true;
			__isValid = true;

			// https://github.com/CodenameCrew/CodenameEngine/blob/main/source/funkin/backend/system/OptimizedBitmapData.hx#L9L46
			if (FlxG.stage.context3D != null) {
				lock();
				getTexture(FlxG.stage.context3D);
				getSurface();
				readable = true;
				this.image = null;
			}
		}
	}

	override function getSurface():CairoImageSurface {
		if (!Settings.setup.gpuCaching) return super.getSurface();
		// https://github.com/CodenameCrew/CodenameEngine/blob/main/source/funkin/backend/system/OptimizedBitmapData.hx#L48L61
		return __surface ??= CairoImageSurface.fromImage(image);
	}

	/**
	 * Shortcut function for create
	 * @param path The image path.
	 * @param pushToGPU Wether it should push to your GPU.
	 * @return BitmapData ~ The bitmap data.
	 */
	public static function fromFile(path:String, pushToGPU:Bool = true):BitmapData {
		#if (js && html5)
		return null;
		#else
		var data:BitmapData;
		if (pushToGPU && Settings.setup.gpuCaching)
			data = new BetterBitmapData(0, 0, true, 0);
		else data = new BitmapData(0, 0, true, 0);
		data.__fromFile(path);
		return data;
		#end
	}
}