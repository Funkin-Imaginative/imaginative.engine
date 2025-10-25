package imaginative.backend.display;

import lime.graphics.Image;
import lime.graphics.cairo.CairoImageSurface;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class BetterBitmapData extends BitmapData {
	@SuppressWarnings('checkstyle:Dynamic')
	override function __fromImage(image:#if lime Image #else Dynamic #end):Void {
		#if lime
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
			if (Settings.setup.gpuCaching && FlxG.stage.context3D != null) {
				lock();
				getTexture(FlxG.stage.context3D);
				getSurface();
				readable = true;
				this.image = null;
			}
		}
		#end
	}

	override function getSurface():CairoImageSurface {
		#if lime
		// https://github.com/CodenameCrew/CodenameEngine/blob/main/source/funkin/backend/system/OptimizedBitmapData.hx#L48L61
		return __surface ??= CairoImageSurface.fromImage(image);
		#else
		return null;
		#end
	}
}