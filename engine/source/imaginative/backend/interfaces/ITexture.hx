package imaginative.backend.interfaces;

// TODO: Make sure function names match purpose.
/**
 * Used for keeping track of what images a sprites using.
 */
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
	 * Loads a sheet or graphic texture for the sprite to use based on checks.
	 * @param newTexture The mod path.
	 * @return FlxSprite ~ Current instance for chaining.
	 */
	function loadTexture(newTexture:ModPath):T;
	/**
	 * Loads a graphic texture for the sprite to use.
	 * @param newTexture The mod path.
	 * @param animated Whether the graphic should be the sprite cut into a grid.
	 * @param width Grid width.
	 * @param height Grid height.
	 * @return FlxSprite ~ Current instance for chaining.
	 */
	function loadImage(newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):T;
	/**
	 * Loads a sheet for the sprite to use.
	 * @param newTexture The mod path.
	 * @return FlxSprite ~ Current instance for chaining.
	 */
	function loadSheet(newTexture:ModPath):T;
	#if ANIMATE_SUPPORT
	/**
	 * Loads an animate atlas for the sprite to use.
	 * @param newTexture The mod path.
	 * @return FlxAnimate ~ Current instance for chaining.
	 */
	function loadAtlas(newTexture:ModPath):T;
	#end
}

/**
 * The texture typing of a sprite.
 */
enum abstract TextureType(String) from String to String {
	/**
	 * States that this sprite uses the sparrow sheet method.
	 */
	var IsSparrow = 'Sparrow';
	/**
	 * States that this sprite uses the packer sheet method.
	 */
	var IsPacker = 'Packer';
	/**
	 * States that this sprite uses the single image grid system method.
	 */
	var IsGraphic = 'Graphic';
	/**
	 * States that this sprite uses the aseprite sheet method.
	 */
	var IsAseprite = 'Aseprite';
	#if ANIMATE_SUPPORT
	/**
	 * States that this sprite uses the animate atlas method.
	 */
	var IsAnimateAtlas = 'AnimateAtlas';
	#end
	/**
	 * States that this sprite method is unknown.
	 */
	var IsUnknown = 'Unknown';

	/**
	 * Gets the file extension from texture type.
	 * @param type The texture type.
	 * @return String ~ File extension.
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
	 * Gets the method based on file extension.
	 * @param modPath The mod path extension that the sheet data type is attached to.
	 * @param defaultIsUnknown If default should be recognized as unknown instead of a graphic.
	 * @return TextureType
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
 * Gives details about the texture(s) a sprite uses.
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