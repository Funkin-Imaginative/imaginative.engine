package imaginative.backend.system;

import flash.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFLAssets;

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
		FlxG.signals.preGameReset.add(() -> clearCache(true, true));
	}

	/**
	 * Paths that the game shouldn't dump their data for when dumping data.
	 */
	public static var dumpExclusions(default, null):Array<String> = [/* './flixel/sounds/beep.ogg' */];
	/**
	 * An asset to exclude from dumpping.
	 * @param file The mod path.
	 */
	inline public static function excludeAsset(file:ModPath):Void {
		var path:String = file.format();
		if (!dumpExclusions.contains(path))
			dumpExclusions.push(path);
	}
	/**
	 * When called it clears all graphics.
	 * @param clearUnused If true, it clears any unused graphics.
	 * @param ignoreExclusions If true, it ignores excluded graphics.
	 *                         Used for resetGame shenanigans.
	 */
	inline public static function clearGraphics(clearUnused:Bool = false, ignoreExclusions:Bool = false):Void {
		FlxG.bitmapLog.clear();
		for (tag => graphic in loadedGraphics) {
			if (graphic == null) continue;
			if (assetsInUse.contains(tag)) continue;
			if (!ignoreExclusions && dumpExclusions.contains(tag)) continue;

			graphic.persist = false;
			graphic.destroyOnNoUse = true;
			graphic.dump();

			loadedGraphics.remove(tag);

			if (graphic.bitmap.__texture != null) graphic.bitmap.__texture.dispose();
			if (FlxG.bitmap.checkCache(tag)) FlxG.bitmap.remove(graphic);
			if (OpenFLAssets.cache.hasBitmapData(tag)) OpenFLAssets.cache.removeBitmapData(tag);
			assetsInUse.remove(tag);
		}
		if (clearUnused)
			FlxG.bitmap.clearUnused();
		openfl.system.System.gc();
	}
	/**
	 * When called it clears all sounds.
	 * @param clearUnused If true, it clears any unused sounds.
	 * @param ignoreExclusions If true, it ignores excluded sounds.
	 *                         Used for resetGame shenanigans.
	 */
	inline public static function clearSounds(clearUnused:Bool = false, ignoreExclusions:Bool = false):Void {
		for (tag => sound in loadedSounds) {
			if (sound == null) continue;
			if (assetsInUse.contains(tag)) continue;
			if (!ignoreExclusions && dumpExclusions.contains(tag)) continue;

			loadedSounds.remove(tag);

			if (OpenFLAssets.cache.hasSound(tag)) OpenFLAssets.cache.removeSound(tag);
			assetsInUse.remove(tag);
		}
	}
	/**
	 * When called it clears all.
	 * @param clearUnused If true, it clears any unused things.
	 * @param ignoreExclusions If true, it ignores excluded things.
	 *                         Used for resetGame shenanigans.
	 */
	inline public static function clearCache(clearUnused:Bool = false, ignoreExclusions:Bool = false):Void {
		clearSounds(clearUnused, ignoreExclusions);
		clearGraphics(clearUnused, ignoreExclusions);
	}

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
		var path:String = Paths.image(file).format();
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
	 * @param beepWhenNull If true, the flixel beep sound will be retrieved when the wanted sound doesn't exist.
	 * @return `Sound` ~ The sound data.
	 */
	inline public static function audio(file:ModPath, beepWhenNull:Bool = true):Sound {
		var path:String = Paths.audio(file).format();
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
		return audio(Paths.inst(song, variant), false);
	/**
	 * Get's the data of a songs vocal track.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param suffix The suffix tag.
	 * @param variant The variant key.
	 * @return `ModPath` ~ The sound data.
	 */
	inline public static function vocal(song:String, suffix:String, variant:String = 'normal'):Sound
		return audio(Paths.vocal(song, suffix, variant), false);
	/**
	 * Get's the data of a song.
	 * From `../music/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The sound data.
	 */
	inline public static function music(file:ModPath):Sound
		return audio(Paths.music(file));
	/**
	 * Get's the data of a sound.
	 * From `../sounds/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The sound data.
	 */
	inline public static function sound(file:ModPath):Sound
		return audio(Paths.sound(file));

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

	/**
	 * Get's the content of a file containing text.
	 * @param file The mod path.
	 * @return `String` ~ The file contents.
	 */
	inline public static function text(file:ModPath):String {
		var finalPath:String = file.format();
		var sysContent:Null<String> = Paths.fileExists(file) ? sys.io.File.getContent(finalPath) : null;
		var limeContent:Null<String> = Paths.fileExists(file) ? OpenFLAssets.getText(Paths.removeBeginningSlash(finalPath)) : null;
		return sysContent ?? limeContent ?? '';
	}
	/**
	 * Parse's json data.
	 * @param data The stringified json data.
	 * @param file A mod path, for just in case reasons.
	 *             Mostly for showing the path when it errors.
	 * @return `Dynamic` ~ The parsed data.
	 */
	inline public static function json(data:String, ?file:ModPath):Dynamic {
		var content:Dynamic = {}
		try {
			content = haxe.Json.parse(data);
		} catch(error:haxe.Exception)
			if (file != null)
				log('${file.format()}: ${error.message}', ErrorMessage);
			else
				log('Json Parse: ${error.message}', ErrorMessage);
		return content;
	}

	static function cacheBitmap(path:String):FlxGraphic {
		if (loadedGraphics.exists(path))
			return loadedGraphics.get(path);

		var bitmap:BitmapData = null;
		if (Paths.fileExists('root:$path'))
			bitmap = BitmapData.fromFile(Paths.removeBeginningSlash(path)) ?? FlxAssets.getBitmapData(Paths.removeBeginningSlash(path));
		if (bitmap == null) {
			FlxG.log.error('No bitmap data from path "$path".');
			return FlxG.bitmap.add(FlxAssets.getBitmapData('flixel/images/logo.png'), './flixel/images/logo.png');
		}

		if (Settings.setup.gpuCaching && bitmap.image != null && bitmap.image.buffer != null) {
			bitmap.image.format = BGRA32;
			bitmap.image.premultiplied = bitmap.__isValid = bitmap.readable = true;
			if (FlxG.stage.context3D != null) {
				bitmap.lock();
				bitmap.getTexture(FlxG.stage.context3D);
				bitmap.readable = true;
				bitmap.getSurface();
				bitmap.image = null;
			}
		}

		var graphic:FlxGraphic = FlxG.bitmap.add(bitmap, path);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		return listGraphic(path, FlxG.bitmap.addGraphic(graphic));
	}
	static function cacheSound(path:String, beepWhenNull:Bool = true):Sound {
		if (loadedSounds.exists(path))
			return loadedSounds.get(path);

		var sound:Sound = null;
		if (Paths.fileExists('root:$path'))
			sound = Sound.fromFile(Paths.removeBeginningSlash(path)) ?? FlxAssets.getSound(Paths.removeBeginningSlash(path));
		if (sound == null) {
			FlxG.log.error('No sound data from path "$path".');
			return beepWhenNull ? FlxAssets.getSound('flixel/sounds/beep') : null;
		}

		return listSound(path, sound);
	}
}