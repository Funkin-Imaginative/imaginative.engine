package imaginative.backend.interfaces;

interface ITexture<T:FlxSprite> {
	/**
	 * The main texture the sprite is using.
	 */
	var texture(get, never):TextureData;
	/**
	 * All textures the sprite is using.
	 */
	var textures(default, null):Array<TextureData>;
	@:unreflective private function resetTextures(newTexture:ModPath, textureType:TextureType):Void;

	/**
	 * Load's a sheet for the sprite to use.
	 * @param newTexture The mod path.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	function loadTexture(newTexture:ModPath):T;
	/**
	 * Load's a graphic texture for the sprite to use.
	 * @param newTexture The mod path.
	 * @param animated Whether the graphic should be the sprite cut into a grid.
	 * @param width Grid width.
	 * @param height Grid height.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	function loadImage(newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):T;
	/**
	 * Load's a sheet or graphic texture for the sprite to use based on checks.
	 * @param newTexture The mod path.
	 * @return `FlxSprite` ~ Current instance for chaining.
	 */
	function loadSheet(newTexture:ModPath):T;
}

/**
 * The texture typing of a spritesheet.
 */
enum abstract TextureType(String) from String to String {
	/**
	 * States that this sprite uses a sparrow sheet method.
	 */
	var IsSparrow = 'Sparrow';
	/**
	 * States that this sprite uses a packer sheet method.
	 */
	var IsPacker = 'Packer';
	/**
	 * States that this sprite uses a single image, grid system method.
	 */
	var IsGraphic = 'Graphic';
	/**
	 * States that this sprite uses an sheet made in the aseprite pixel art software.
	 */
	var IsAseprite = 'Aseprite';
	#if ANIMATE_SUPPORT
	/**
	 * States that this sprite uses an animate atlas.
	 */
	var IsAnimateAtlas = 'AnimateAtlas';
	#end
	/**
	 * States that this sprite method is unknown.
	 */
	var IsUnknown = 'Unknown';

	/**
	 * Get's the file extension from texture type.
	 * @param type The texture type.
	 * @return `String` ~ File extension.
	 */
	inline public static function getExtFromType(type:TextureType):String {
		return switch (type) {
			case IsSparrow: 'xml';
			case IsPacker: 'txt';
			case IsAseprite: 'json';
			case IsGraphic: 'png';
			#if ANIMATE_SUPPORT
			case IsAnimateAtlas: '';
			#end
			default: IsUnknown;
		}
	}
	/**
	 * Get's the method based on file extension.
	 * @param modPath The mod path extension that the sheet data type is attached to.
	 * @param defaultIsUnknown If default should be recognized as unknown instead of a graphic.
	 * @return `TextureType`
	 */
	inline public static function getTypeFromExt(modPath:ModPath, defaultIsUnknown:Bool = false):TextureType {
		return switch (modPath.extension) {
			case 'xml': IsSparrow;
			case 'txt': IsPacker;
			case 'json': IsAseprite;
			case 'png': IsGraphic;
			#if ANIMATE_SUPPORT
			case '': IsAnimateAtlas;
			#end
			default: defaultIsUnknown ? IsUnknown : IsGraphic;
		}
	}
}

/**
 * Gives details about a texture a sprite uses.
 */
class TextureData {
	/**
	 * The root path of the image.
	 */
	public var image(default, null):ModPath;
	/**
	 * The sheet method used.
	 */
	public var type(default, null):TextureType;
	/**
	 * The mod path type.
	 */
	public var path(get, never):ModType;
	inline function get_path():ModType
		return image.path;

	public function new(image:ModPath, type:TextureType) {
		this.image = image;
		this.type = type;
	}

	inline public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('image', image.format()),
			LabelValuePair.weak('type', type),
			LabelValuePair.weak('path', path)
		]);
	}
}