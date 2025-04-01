package imaginative.backend.system;

import flash.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
// import lime.utils.Assets as LimeAssets;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFLAssets; // #if CONTAINS_EMBEDDED_FILES // #end

/**
 * This is mostly taken from Psych since idk what to actually do.
 */
@:access(openfl.display.BitmapData)
class Assets {
	@:allow(imaginative.states.EngineProcess)
	static function init():Void {
		excludeAsset(Paths.image('main:menus/bgs/menuArt'));
		excludeAsset(Paths.music('main:freakyMenu'));
		excludeAsset(Paths.music('main:breakfast'));
	}

	/**
	 * Paths that the game shouldn't dump their data for when dumping data.
	 */
	public static var dumpExclusions(default, null):Array<String> = [/* 'flixel/sounds/beep.${#if (windows || android) 'ogg' #else 'mp3' #end}' */];
	/**
	 * An asset to exclude from dumpping.
	 * @param file The mod path.
	 */
	inline public static function excludeAsset(file:ModPath, doTypeCheck:Bool = true):Void {
		var path:String = doTypeCheck ? file.format() : file.path;
		if (!dumpExclusions.contains(path))
			dumpExclusions.push(path);
	}
	// /**
	//  * Clears unused memory from the game.
	//  */
	// inline public static function clearUnusedMemory():Void {
	// 	for (tag => graphic in loadedGraphics)
	// 		// makes sure it's not currently being used and checks if it's in the exclusion list
	// 		if (!assetsInUse.contains(tag) && !dumpExclusions.contains(tag)) {
	// 			destroyGraphic(graphic);
	// 			loadedGraphics.remove(tag);
	// 		}
	// 	// runs system garbage collector
	// 	openfl.system.System.gc();
	// }
	// /**
	//  * Clears stored memory from the game.
	//  */
	// @:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	// inline public static function clearStoredMemory():Void {
	// 	// clear non loaded graphics
	// 	for (tag => graphic in FlxG.bitmap._cache) {
	// 		if (!loadedGraphics.exists(tag))
	// 			destroyGraphic(FlxG.bitmap.get(tag));
	// 	}
	// 	// clear non loaded sounds
	// 	for (tag => sound in loadedSounds) {
	// 		if (!assetsInUse.contains(tag) && !dumpExclusions.contains(tag)) {
	// 			LimeAssets.cache.clear(tag);
	// 			loadedSounds.remove(tag);
	// 		}
	// 	}
	// }
	// public static function freeGraphicsFromMemory():Void {
	// 	var protected:Array<FlxGraphic> = [];
	// 	function checkForGraphics(object:Dynamic):Void {
	// 		if (object is FlxSprite) {
	// 			var graphic:FlxGraphic = cast(object, FlxSprite).graphic;
	// 			if (graphic != null)
	// 				if (!protected.contains(graphic))
	// 					protected.push(graphic);
	// 		} else if (object is FlxTypedGroup) {
	// 			var group:FlxTypedGroup<Dynamic> = cast object;
	// 			for (member in group)
	// 				checkForGraphics(member);
	// 		} else if (object is FlxTypedSpriteGroup) {
	// 			var group:FlxTypedSpriteGroup<Dynamic> = cast object;
	// 			for (member in group)
	// 				checkForGraphics(member);
	// 		} else if (object is FlxState) {
	// 			var state:FlxState = cast object;
	// 			for (member in state.members)
	// 				checkForGraphics(member);
	// 			if (state.subState != null)
	// 				checkForGraphics(state.subState);
	// 		} else if (object is FlxSubState) {
	// 			var state:FlxSubState = cast object;
	// 			for (member in state.members)
	// 				checkForGraphics(member);
	// 			if (state.subState != null)
	// 				checkForGraphics(state.subState);
	// 		}
	// 	}
	// 	checkForGraphics(FlxG.state);

	// 	for (tag => graphic in loadedGraphics) {
	// 		if (!dumpExclusions.contains(tag))
	// 			if (!protected.contains(graphic)) {
	// 				destroyGraphic(graphic);
	// 				loadedGraphics.remove(tag);
	// 			}
	// 	}
	// }

	/**
	 * Assets that are currently being used have their mod paths stored in this array.
	 */
	public static var assetsInUse:Array<String> = [];

	/**
	 * A map of all loaded graphics.
	 */
	public static var loadedGraphics:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	inline static function listGraphic(path:String, graphic:FlxGraphic):FlxGraphic {
		loadedGraphics.set(path, graphic);
		if (!assetsInUse.contains(path))
			assetsInUse.push(path);
		return graphic;
	}

	/**
	 * A map of all loaded sounds.
	 */
	public static var loadedSounds:Map<String, Sound> = new Map<String, Sound>();
	inline static function listSound(path:String, sound:Sound):Sound {
		loadedSounds.set(path, sound);
		if (!assetsInUse.contains(path))
			assetsInUse.push(path);
		return sound;
	}

	@:using inline static function destroyGraphic(graphic:FlxGraphic):Void {
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

	/**
	 * Get's the data of an image file.
	 * From `../images/`.
	 * @param file The mod path.
	 * @return `FlxGraphic` ~ The graphic data.
	 */
	inline public static function image(file:ModPath):FlxGraphic {
		var path:String = Paths.image(file, false).format();
		if (loadedGraphics.exists(path)) {
			if (!assetsInUse.contains(path))
				assetsInUse.push(path);
			return loadedGraphics.get(path);
		}
		return cacheBitmap(path);
	}

	/**
	 * Get's the data of an audio file.
	 * @param file The mod path.
	 * @param beepWhenNull If true, the flixel beep sound when play when the wanted sound doesn't exist.
	 * @return `Sound` ~ The sound data.
	 */
	inline public static function audio(file:ModPath, beepWhenNull:Bool = true):Sound {
		var path:String = Paths.audio(file, false).format();
		if (loadedSounds.exists(path)) {
			if (!assetsInUse.contains(path))
				assetsInUse.push(path);
			return loadedSounds.get(path);
		}
		return cacheSound(path, beepWhenNull);
	}
	/**
	 * Get's the data of a songs instrumental file.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param variant The variant key.
	 * @return `Sound` ~ The sound data.
	 */
	inline public static function inst(song:String, variant:String = 'normal'):Sound
		return audio(Paths.inst(song, variant, false), false);
	/**
	 * Get's the data of a songs vocal track.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param suffix The suffix tag.
	 * @param variant The variant key.
	 * @return `ModPath` ~ The sound data.
	 */
	inline public static function vocal(song:String, suffix:String, variant:String = 'normal'):Sound
		return audio(Paths.vocal(song, suffix, variant, false), false);
	/**
	 * Get's the data of a song.
	 * From `../music/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The sound data.
	 */
	inline public static function music(file:ModPath):Sound
		return audio(Paths.music(file, false));
	/**
	 * Get's the data of a sound.
	 * From `../sounds/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The sound data.
	 */
	inline public static function sound(file:ModPath):Sound
		return audio(Paths.sound(file, false));

	/**
	 * Get's a spritesheet's data file.
	 * @param file The mod path.
	 *             From `../images/`.
	 * @param type The texture type.
	 * @return `FlxAtlasFrames`
	 */
	inline public static function frames(file:ModPath, type:TextureType = IsUnknown):FlxAtlasFrames {
		if (type == IsUnknown) {
			if (Paths.fileExists(Paths.xml('${file.type}:images/${file.path}'))) type = IsSparrow;
			if (Paths.fileExists(Paths.txt('${file.type}:images/${file.path}'))) type = IsPacker;
			if (Paths.fileExists(Paths.json('${file.type}:images/${file.path}'))) type = IsAseprite;
		}
		return switch (type) {
			case IsSparrow: getSparrowFrames(file);
			case IsPacker: getPackerFrames(file);
			case IsAseprite: getAsepriteFrames(file);
			default: getSparrowFrames(file);
		}
	}
	/**
	 * Get's sparrow sheet data.
	 * @param file The mod path.
	 *             From `../images/`.
	 * @return `FlxAtlasFrames` ~ The Sparrow frame collection.
	 */
	inline public static function getSparrowFrames(file:ModPath):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(file), Paths.xml('${file.type}:images/${file.path}'));
	/**
	 * Get's packer sheet data.
	 * @param file The mod path.
	 *             From `../images/`.
	 * @return `FlxAtlasFrames` ~ The Packer frame collection.
	 */
	inline public static function getPackerFrames(file:ModPath):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(file), Paths.txt('${file.type}:images/${file.path}'));
	/**
	 * Get's aseprite sheet data.
	 * @param file The mod path.
	 *             From `../images/`.
	 * @return `FlxAtlasFrames` ~ The Aseprite frame collection.
	 */
	inline public static function getAsepriteFrames(file:ModPath):FlxAtlasFrames
		return FlxAtlasFrames.fromAseprite(image(file), Paths.json('${file.type}:images/${file.path}'));

	// BUG: Exists check doesn't check if its embedded or not since it does ||.
	/**
	 * Get's the content of a file containing text.
	 * @param file The mod path.
	 * @param doTypeCheck If false, it starts the check from the engine root.
	 * @return `String` ~ The file contents.
	 */
	inline public static function text(file:ModPath, doTypeCheck:Bool = true):String {
		var finalPath:String = doTypeCheck ? file.format() : file.path;
		var sysContent:Null<String> = Paths.fileExists(file, doTypeCheck) ? sys.io.File.getContent(finalPath) : null;
		var limeContent:Null<String> = #if CONTAINS_EMBEDDED_FILES Paths.fileExists(file, doTypeCheck) ? OpenFLAssets.getText(finalPath) : #end null;
		return sysContent ?? limeContent ?? '';
	}

	static function cacheBitmap(path:String):FlxGraphic {
		var bitmap:BitmapData = null;
		if (Paths.fileExists(path, false)) {
			bitmap = BitmapData.fromFile(path);
			// #if CONTAINS_EMBEDDED_FILES
			if (bitmap == null)
				bitmap = OpenFLAssets.getBitmapData(path);
			// #end
		}
		if (bitmap == null) {
			FlxG.log.error('No bitmap data from path "$path".');
			return null;
		}

		if (Settings.setup.gpuCaching && bitmap.image != null) {
			bitmap.lock();
			if (bitmap.__texture == null) {
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, path);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		return listGraphic(path, graphic);
	}
	static function cacheSound(path:String, beepWhenNull:Bool = true):Sound {
		var result:Sound = null;
		if (!loadedSounds.exists(path)) {
			if (Paths.fileExists(path, false)) {
				result = Sound.fromFile(path);
				// #if CONTAINS_EMBEDDED_FILES
				if (result == null)
					result = OpenFLAssets.getSound(path);
				// #end
				if (result == null) {
					FlxG.log.error('No sound data from path "$path".');
					return beepWhenNull ? FlxAssets.getSound('flixel/sounds/beep') : null;
				}
			}
		}
		return listSound(path, result);
	}
}