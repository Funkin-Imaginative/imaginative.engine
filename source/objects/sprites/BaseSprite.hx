package objects.sprites;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.graphics.frames.FlxAtlasFrames;

@:structInit class TextureData {
	public var image(default, null):String;
	public var type(default, null):String;
	public var path(get, never):FunkinPath;
	inline function get_path():FunkinPath
		return FunkinPath.typeFromPath(image);

	public function toString():String
		return '{ image => $image, path => $path, type => $type }';
}

class BaseSprite extends FlxSkewedSprite {
	public var _update:Float->Void;
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var debugMode:Bool = false; // for editors

	public var textures(default, null):Array<TextureData>;
	@:unreflective private function resetTextures(newTexture:String, spriteType:String):String {
		textures = [];
		textures.push({
			image: HaxePath.withoutExtension(newTexture),
			type: spriteType
		});
		return newTexture;
	}

	public function loadTexture(newTexture:String):BaseSprite {
		var hasSheet:Bool = Paths.multExst('images/$newTexture', Paths.atlasFrameExts) != '';
		if (Paths.fileExists('images/$newTexture.png'))
			if (hasSheet) loadSheet(newTexture);
			else loadImage(newTexture);
		return this;
	}

	public function loadImage(newTexture:String):BaseSprite {
		if (Paths.fileExists('images/$newTexture.png'))
			loadGraphic(resetTextures(Paths.image(newTexture), 'graphic'));
		return this;
	}

	public function loadSheet(newTexture:String):BaseSprite {
		var spriteType:String = switch (HaxePath.extension(Paths.multExst('images/$newTexture', Paths.atlasFrameExts))) {
			case 'xml': 'sparrow';
			case 'txt': 'packer';
			default: 'unknown';
		}
		var hasSheet:Bool = Paths.multExst('images/$newTexture', Paths.atlasFrameExts) != '';
		if (Paths.fileExists('images/$newTexture.png') && hasSheet) {
			frames = Paths.frames(newTexture);
			resetTextures(Paths.applyRoot('images/$newTexture.png'), spriteType);
		}
		return this;
	}

	public function loadSolid(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):BaseSprite
		return cast makeSolid(Width, Height, Color, Unique, Key);

	public function new(x:Float = 0, y:Float = 0, ?startTexture:String) {
		super(x, y);

		if (startTexture != null)
			loadTexture(startTexture);
	}
}