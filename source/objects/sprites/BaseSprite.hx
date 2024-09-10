package objects.sprites;

import backend.structures.PositionStruct.TypeXY;
import flixel.addons.effects.FlxSkewedSprite;

@:structInit class TextureData {
	public var image(default, null):String;
	public var type(default, null):String;
	public var path(get, never):FunkinPath;
	inline function get_path():FunkinPath
		return FunkinPath.typeFromPath(image);

	public function toString():String
		return '{image => $image, type => $type, path => $path}';
}

@:optional typedef OffsetsData = {
	var position:PositionStruct;
	var flip:TypeXY<Bool>;
	var scale:PositionStruct;
}

typedef AssetTyping = {
	var image:String;
	var type:String;
}
typedef AnimationTyping = {
	@:optional var asset:AssetTyping;
	var name:String;
	@:optional var tag:String;
	@:optional var dimensions:TypeXY<Bool>;
	var indices:Array<Int>;
	var offset:PositionStruct;
	var flip:TypeXY<Bool>;
	var loop:Bool;
	var fps:Int;
}

typedef ObjectData = {
	var asset:AssetTyping;
	var animations:Array<AnimationTyping>;
	var antialiasing:Bool;
	var flip:TypeXY<Bool>;
	var scale:PositionStruct;
}

class BaseSprite extends FlxSkewedSprite {
	public var _update:Float->Void;
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var debugMode:Bool = false; // for editors

	/**
	 * The main texture the sprite is using.
	 */
	public var texture(get, never):TextureData;
	inline function get_texture():TextureData return textures[0];
	/**
	 * All textures the sprite is using.
	 */
	public var textures(default, null):Array<TextureData>;
	@:unreflective inline function resetTextures(newTexture:String, spriteType:String):String {
		textures = [];
		textures.push({
			image: HaxePath.withoutExtension(newTexture),
			type: spriteType
		});
		return newTexture;
	}

	inline public function loadTexture(newTexture:String):TypeSprite {
		var hasSheet:Bool = Paths.multExst('images/$newTexture', Paths.atlasFrameExts) != '';
		if (Paths.fileExists('images/$newTexture.png'))
			if (hasSheet) loadSheet(newTexture);
			else loadImage(newTexture);
		return this;
	}

	inline public function loadImage(newTexture:String):TypeSprite {
		if (Paths.fileExists('images/$newTexture.png'))
			loadGraphic(resetTextures(Paths.image(newTexture), 'graphic'));
		return this;
	}

	inline public function loadSheet(newTexture:String):TypeSprite {
		var hasSheet:Bool = Paths.multExst('images/$newTexture', Paths.atlasFrameExts) != '';
		if (Paths.fileExists('images/$newTexture.png') && hasSheet) {
			frames = Paths.frames(newTexture);
			resetTextures(Paths.applyRoot('images/$newTexture.png'), switch (HaxePath.extension(Paths.multExst('images/$newTexture', Paths.atlasFrameExts))) {
				case 'xml': 'sparrow';
				case 'txt': 'packer';
				default: 'unknown';
			});
		}
		return this;
	}

	inline public function loadSolid(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):TypeSprite
		return makeSolid(Width, Height, Color, Unique, Key);

	public var data = null;

	public function new(x:Float = 0, y:Float = 0, ?startTexture:String) {
		super(x, y);

		if (startTexture != null)
			loadTexture(startTexture);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (_update != null) _update(elapsed);
	}
}