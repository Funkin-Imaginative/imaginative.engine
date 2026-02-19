package imaginative.backend.system;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import moonchart.backend.Util as MoonUtil;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.AssetCache as OpenFLAssetCache;
import openfl.utils.Assets as OpenFLAssets;
import imaginative.backend.display.BetterBitmapData;
#if ANIMATE_SUPPORT
import animate.FlxAnimateFrames;
#end

@:bitmap('assets/images/logo/logo.png')
private class HaxeLogo extends BitmapData {}

abstract class CacheTemplate<Asset> {
	/**
	 * List of cached assets.
	 */
	public final cacheList:Map<String, Asset> = new Map<String, Asset>();

	public function new() {}

	/**
	 * What should be added to the cache list.
	 * @param path The path for the asset.
	 * @param useWhenNull Wether to use the "whenNull" function if the item doesn't exist.
	 * @return Asset
	 */
	public function add(path:String, useWhenNull:Bool):Asset
		throw 'This function must be extended!';
	/**
	 * What should be removed from the cache list.
	 * @param path The path for the assset.
	 * @param ignorePersistant If true, the asset won't be ignored, even if it's marked as persistant.
	 */
	public function remove(path:String, ignorePersistant:Bool = false):Void
		throw 'This function must be extended!';

	/**
	 * What should be grabbed from the cache list.
	 * @param path The path for the asset.
	 * @param useWhenNull Wether to use the "whenNull" function if the item doesn't exist.
	 * @return Asset
	 */
	public function get(path:String, useWhenNull:Bool):Asset {
		if (cacheList.exists(path))
			return cacheList.get(path);
		else {
			var asset:Asset = add(path, useWhenNull);
			if (asset != null) return asset;
			return useWhenNull ? whenNull() : null;
		}
	}
	/**
	 * What should be used when the asset that's asked for is null.
	 * @return Asset
	 */
	public function whenNull():Asset
		throw 'This function must be extended!';

	/**
	 * Clears all cached data with some exceptions.
	 * @param ignorePersistant If true, the asset won't be ignored, even if it's marked as persistant.
	 */
	public function clear(ignorePersistant:Bool = false):Void
		throw 'This function must be extended!';
}

@SuppressWarnings('checkstyle:CodeSimilarity')
final class GraphicsCache extends CacheTemplate<FlxGraphic> {
	override public function add(path:String, useWhenNull:Bool):FlxGraphic {
		var daPath:String = Paths.removeBeginningSlash(path);
		if (!Paths.fileExists('root:$path'))
			useWhenNull ? whenNull() : null;

		if (cacheList.exists(path))
			return cacheList.get(path);

		final graphic:FlxGraphic = FlxG.bitmap.add(BetterBitmapData.fromFile(daPath));
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		graphic.incrementUseCount();
		cacheList.set(path, graphic);

		if (Settings.setup.gpuCaching) { // following @swordcube's lead
			final t = new openfl.geom.ColorTransform(); t.alphaMultiplier = 0.001;
			FlxG.camera.drawPixels(graphic.imageFrame.frame, graphic.bitmap, new flixel.math.FlxMatrix(), t);
		}
		return graphic;
	}
	override public function remove(path:String, ignorePersistant:Bool = false):Void {
		// if (!ignorePersistant && !Paths.shouldDumpGraphic(graphic))
		// 	continue;

		var graphic:FlxGraphic = FlxG.bitmap.get(Paths.removeBeginningSlash(path));
		if (graphic != null) {
			cacheList.remove(path);
			graphic.persist = false;
			graphic.destroyOnNoUse = true;
			graphic.decrementUseCount();
		}
	}

	override public function whenNull():FlxGraphic
		return get('./flixel/images/logo/logo.png', false);

	override public function clear(ignorePersistant:Bool = false):Void {
		for (path in cacheList.keys()) {
			// if (!ignorePersistant && !Paths.shouldDumpGraphic(graphic))
			// 	continue;

			var daPath:String = Paths.removeBeginningSlash(path);
			var graphic:FlxGraphic = FlxG.bitmap.get(daPath);
			@:privateAccess if (graphic != null && !graphic.persist && graphic.destroyOnNoUse) {
				if (!graphic.isDestroyed) graphic.destroy();
				FlxG.bitmap.removeKey(daPath);
				OpenFLAssets.cache.removeBitmapData(daPath);
				cacheList.remove(path);
			}
		}
	}
}
@SuppressWarnings('checkstyle:CodeSimilarity')
final class AudiosCache extends CacheTemplate<Sound> {
	override public function add(path:String, useWhenNull:Bool):Sound {
		var daPath:String = Paths.removeBeginningSlash(path);
		if (!Paths.fileExists('root:$path'))
			useWhenNull ? whenNull() : null;

		if (cacheList.exists(path))
			return cacheList.get(path);

		if (OpenFLAssets.exists(daPath, SOUND)) {
			final sound:Sound = OpenFLAssets.getSound(daPath, false);
			OpenFLAssets.cache.setSound(daPath, sound);
			cacheList.set(path, sound);
			return sound;
		}

		final sound:Sound = Sound.fromFile(FileSystem.absolutePath(daPath));
		OpenFLAssets.cache.setSound(daPath, sound);
		cacheList.set(path, sound);
		return sound;
	}
	override public function remove(path:String, ignorePersistant:Bool = false):Void {
		final cache:OpenFLAssetCache = (OpenFLAssets.cache is OpenFLAssetCache) ? cast OpenFLAssets.cache : null;
		if (cache != null) {
			// if (!includePersistant && !Paths.shouldDumpAsset(path))
			// 	continue;

			final sound:Sound = cache.sound.get(Paths.removeBeginningSlash(path));
			if (FlxG.sound.music == null || @:privateAccess FlxG.sound.music._sound != sound)
				sound.close();
			cache.removeSound(Paths.removeBeginningSlash(path));
			cacheList.remove(path);
		}
	}

	override public function whenNull():Sound
		return get('./flixel/sounds/beep.ogg', false);

	override public function clear(ignorePersistant:Bool = false):Void {
		final cache:OpenFLAssetCache = (OpenFLAssets.cache is OpenFLAssetCache) ? cast OpenFLAssets.cache : null;
		if (cache != null) {
			for (path in cacheList.keys()) {
				// if (!ignorePersistant && !Paths.shouldDumpAsset(path))
				// 	continue;

				final sound:Sound = cache.sound.get(Paths.removeBeginningSlash(path));
				if (FlxG.sound.music == null || @:privateAccess FlxG.sound.music._sound != sound)
					sound.close();
				cache.removeSound(Paths.removeBeginningSlash(path));
				cacheList.remove(path);
			}
		}
	}
}

/**
 * This is mostly taken from Psych since idk what to actually do.
 */
@:access(openfl.display.BitmapData)
class Assets {
	/**
	 * Contains all loaded graphics.
	 */
	public static final graphics:GraphicsCache = new GraphicsCache();
	/**
	 * Contains all loaded audio.
	 */
	public static final audios:AudiosCache = new AudiosCache();

	@:allow(imaginative.states.EngineProcess)
	static function init():Void {
		#if ANIMATE_SUPPORT
		@:privateAccess {
			FlxAnimateFrames.getTextFromPath = (path:String) -> return text('root:$path').replace(String.fromCharCode(0xFEFF), '');
			FlxAnimateFrames.existsFile = (path:String, type:openfl.utils.AssetType) -> return Paths.fileExists('root:$path');
			FlxAnimateFrames.listWithFilter = (path:String, filter:String->Bool) -> return [for (file in Paths.readFolder('root:$path')) file.format()].filter(filter);
			FlxAnimateFrames.getGraphic = (path:String) -> return image('root:$path');
		}
		#end

		MoonUtil.readFolder = (folder:String) -> [for (file in Paths.readFolder('root:$folder')) file.format()];
		MoonUtil.isFolder = (folder:String) -> Paths.folderExists('root:$folder');
		// MoonUtil.saveBytes;
		// MoonUtil.saveText;
		// MoonUtil.getBytes;
		MoonUtil.getText = (path:String) -> Assets.text('root:$path');

		clearAll(false, true);
	}

	/**
	 * When called it clears all.
	 * @param ignorePersistant If true, the asset won't be ignored, even if it's marked as persistant.
	 * @param runGarbageCollector if true, this will run the garbage collector.
	 * @param isMajor If true, it cleans out bigger chunks of data.
	 */
	inline public static function clearAll(ignorePersistant:Bool = false, runGarbageCollector:Bool = false, isMajor:Bool = false):Void {
		graphics.clear(ignorePersistant);
		audios.clear(ignorePersistant);
		if (runGarbageCollector) {
			cpp.vm.Gc.run(isMajor);
			cpp.vm.Gc.compact();
		}
	}

	/**
	 * Gets the data of an image file.
	 * From `../images/`.
	 * @param file The mod path.
	 * @return FlxGraphic ~ The graphic data.
	 */
	inline public static function image(file:ModPath):FlxGraphic
		return graphics.get(Paths.image(file).format(), true);

	/**
	 * Gets the data of an audio file.
	 * @param file The mod path.
	 * @param beepWhenNull If true the flixel beep sound will be retrieved when the wanted sound doesn't exist.
	 * @return Sound ~ The sound data.
	 */
	inline public static function audio(file:ModPath, beepWhenNull:Bool = true):Sound
		return audios.get(Paths.audio(file).format(), beepWhenNull);
	/**
	 * Gets the data of a songs instrumental file.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param variant The variant key.
	 * @return Sound ~ The sound data.
	 */
	inline public static function inst(song:String, variant:String = 'normal'):Sound
		return audio(Paths.inst(song, variant));
	/**
	 * Gets the data of a songs vocal track.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param suffix The suffix tag.
	 * @param variant The variant key.
	 * @return ModPath ~ The sound data.
	 */
	inline public static function vocal(song:String, suffix:String, variant:String = 'normal'):Sound
		return audio(Paths.vocal(song, suffix, variant), false);
	/**
	 * Gets the data of a song.
	 * From `../music/`.
	 * @param file The mod path.
	 * @return ModPath ~ The sound data.
	 */
	inline public static function music(file:ModPath):Sound
		return audio(Paths.music(file));
	/**
	 * Gets the data of a sound.
	 * From `../sounds/`.
	 * @param file The mod path.
	 * @return ModPath ~ The sound data.
	 */
	inline public static function sound(file:ModPath):Sound
		return audio(Paths.sound(file));

	/**
	 * Gets a spritesheet's data file.
	 * @param file The mod path. From `../images/`.
	 * @param type The texture type.
	 * @return FlxAtlasFrames
	 */
	inline public static function frames(file:ModPath, type:TextureType = IsUnknown):FlxAtlasFrames {
		if (type == IsUnknown) {
			if (Paths.image(Paths.xml(file)).isFile) type = IsSparrow;
			if (Paths.image(Paths.txt(file)).isFile) type = IsPacker;
			if (Paths.image(Paths.json(file)).isFile) type = IsAseprite;
			#if ANIMATE_SUPPORT
			if (Paths.image(Paths.json('${file.type}:${file.path}/Animation')).isFile) type = IsAnimateAtlas;
			#end
		}
		return switch (type) {
			case IsSparrow: getSparrowFrames(file);
			case IsPacker: getPackerFrames(file);
			case IsAseprite: getAsepriteFrames(file);
			#if ANIMATE_SUPPORT
			case IsAnimateAtlas: getAnimateAtlas(file);
			#end
			default: getSparrowFrames(file);
		}
	}
	/**
	 * Gets sparrow sheet data.
	 * @param file The mod path. From `../images/`.
	 * @return FlxAtlasFrames ~ The Sparrow frame collection.
	 */
	inline public static function getSparrowFrames(file:ModPath):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(file), Paths.xml('${file.type}:images/${file.path}'));
	/**
	 * Gets packer sheet data.
	 * @param file The mod path. From `../images/`.
	 * @return FlxAtlasFrames ~ The Packer frame collection.
	 */
	inline public static function getPackerFrames(file:ModPath):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(file), Paths.txt('${file.type}:images/${file.path}'));
	/**
	 * Gets aseprite sheet data.
	 * @param file The mod path. From `../images/`.
	 * @return FlxAtlasFrames ~ The Aseprite frame collection.
	 */
	inline public static function getAsepriteFrames(file:ModPath):FlxAtlasFrames
		return FlxAtlasFrames.fromAseprite(image(file), Paths.json('${file.type}:images/${file.path}'));
	#if ANIMATE_SUPPORT
	/**
	 * Gets animate atlas data.
	 * @param file The mod path. From `../images/`.
	 * @return FlxAnimateFrames ~ The Atlas frame collection.
	 */
	inline public static function getAnimateAtlas(file:ModPath):FlxAnimateFrames
		return FlxAnimateFrames.fromAnimate(Paths.image(Paths.json('${file.type}:${file.path}/Animation')));
	#end

	/**
	 * Gets the content of a file containing text.
	 * @param file The mod path.
	 * @return String ~ The file contents.
	 */
	inline public static function text(file:ModPath):String {
		var finalPath:String = file.format();
		try {
			var sysContent:Null<String> = file.isFile ? sys.io.File.getContent(finalPath) : null;
			var limeContent:Null<String> = file.isFile ? OpenFLAssets.getText(Paths.removeBeginningSlash(finalPath)) : null;
			return sysContent ?? limeContent ?? '';
		} catch(error:haxe.Exception) {
			return file.isFile ? sys.io.File.getContent(finalPath) : '';
		}
	}
	/**
	 * Parses json data.
	 * @param data The stringified json data.
	 * @param file A mod path, for just in case reasons. Used for showing the path when it errors.
	 * @return Dynamic ~ The parsed data.
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
}