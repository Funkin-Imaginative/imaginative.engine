package imaginative.backend.system;

import haxe.MainLoop;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import moonchart.backend.Util as MoonUtil;
import openfl.media.Sound;
import openfl.utils.AssetCache as OpenFLAssetCache;
import openfl.utils.Assets as OpenFLAssets;
import imaginative.backend.display.BetterBitmapData;
import imaginative.states.editors.ChartEditor;
#if ANIMATE_SUPPORT
import animate.FlxAnimateFrames;
#end

enum abstract PersistenceType(String) {
	/**
	 * States that the asset cannot be removed, even if persistant assets are told to be cleared.
	 */
	var IsIndestructible = 'indestructible';
	/**
	 * States that the asset cannot be removed, unless told to be.
	 */
	var IsPersistent = 'persistent';
	/**
	 * A normal asset.
	 */
	var IsVulnerable = 'vulnerable';
}

abstract class CacheTemplate<Asset> {
	/**
	 * List of cached assets.
	 */
	public final cacheList:Map<String, Asset> = new Map<String, Asset>();
	/**
	 * The list of every assets level of persistence.
	 */
	final persistenceList:Map<String, PersistenceType> = new Map<String, PersistenceType>();
	/**
	 * The asset to fallback on when the desired one doesn't exist.
	 */
	final fallbackAsset:String;

	public function new(?fallbackAsset:String) {
		this.fallbackAsset = fallbackAsset;
		if (fallbackAsset != null)
			add(fallbackAsset, false, IsIndestructible);
	}

	/**
	 * What should be added to the cache list.
	 * @param path The path for the asset.
	 * @param useFallback Wether to use the fallback asset if the desired one doesn't exist.
	 * @param persistenceLevel The level of persistence the asset should have. Can change an assets persistence level if it already was added.
	 * @return Asset
	 */
	public function add(path:String, useFallback:Bool, persistenceLevel:PersistenceType = IsVulnerable):Asset
		throw 'This function must be extended!';
	/**
	 * What should be removed from the cache list.
	 * @param path The path for the asset.
	 * @param ignorePersistant If true, the asset won't be ignored, even if it's marked as persistant.
	 */
	public function remove(path:String, ignorePersistant:Bool = false):Void
		throw 'This function must be extended!';

	/**
	 * What asset should be removed and re-added (reloaded).
	 * Can be useful for when a file is changed without having to reopen the game.
	 * @param path The path for the asset.
	 * @return Asset
	 */
	inline public function reload(path:String):Asset {
		final persistence:PersistenceType = persistenceList.get(path);
		add(path, false, IsVulnerable); // forces level to "IsVulnerable"
		remove(path); return add(path, false, persistence); // readds the asset with it's original persistence level
	}

	/**
	 * What should be grabbed from the cache list.
	 * @param path The path for the asset.
	 * @param useFallback Wether to use the fallback asset if the desired one doesn't exist.
	 * @return Asset
	 */
	public function get(path:String, useFallback:Bool):Asset {
		if (path == null) return useFallback ? getFallback() : null;
		if (cacheList.exists(path))
			return cacheList.get(path);
		else {
			var asset:Asset = add(path, useFallback);
			if (asset != null) return asset;
			return useFallback ? getFallback() : null;
		}
	}
	/**
	 * The asset to fallback on when the desired one doesn't exist.
	 * @return Asset
	 */
	inline public function getFallback():Asset
		return get(fallbackAsset, false);

	/**
	 * Clears all cached data with some exceptions.
	 * @param ignorePersistant If true, the asset won't be ignored, even if it's marked as persistant.
	 * @param fullDestroy If true, **all** assets stored will be cleared.
	 * @param includeRawFlixel If true, this all also effect raw flixel's assets.
	 */
	public function clear(ignorePersistant:Bool = false, fullDestroy:Bool = false, includeRawFlixel:Bool = false):Void
		throw 'This function must be extended!';
}

final class GraphicCache extends CacheTemplate<FlxGraphic> {
	override public function add(path:String, useFallback:Bool, persistenceLevel:PersistenceType = IsVulnerable):FlxGraphic {
		if (!Paths.fileExists('root:$path'))
			return useFallback ? getFallback() : null;

		if (cacheList.exists(path)) {
			persistenceList.set(path, persistenceLevel);
			return cacheList.get(path);
		}

		final graphic:FlxGraphic = FlxG.bitmap.add(BetterBitmapData.fromFile(Paths.removeBeginningSlash(path)));
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		graphic.incrementUseCount();
		cacheList.set(path, graphic);
		persistenceList.set(path, persistenceLevel);

		if (Settings.setup.gpuCaching) // pushes it immediately to gpu
			MainLoop.runInMainThread(() -> graphic.bitmap.getTexture(FlxG.stage.context3D));
		return graphic;
	}
	override public function remove(path:String, ignorePersistant:Bool = false):Void {
		switch (persistenceList.get(path)) {
			case IsIndestructible:
				return;
			case IsPersistent:
				if (ignorePersistant) return;
			case IsVulnerable:
		} persistenceList.remove(path);

		var graphic:FlxGraphic = FlxG.bitmap.get(Paths.removeBeginningSlash(path));
		if (graphic != null) {
			graphic.persist = false;
			graphic.destroyOnNoUse = true;
			graphic.decrementUseCount();
		}
		cacheList.remove(path);
	}

	override public function clear(ignorePersistant:Bool = false, fullDestroy:Bool = false, includeRawFlixel:Bool = false):Void {
		@:privateAccess if (fullDestroy) {
			// clear engine assets
			for (path in cacheList.keys()) {
				switch (persistenceList.get(path)) {
					// ensures full clear
					case IsIndestructible: continue;
					default: persistenceList.remove(path);
				}

				var daPath:String = Paths.removeBeginningSlash(path);
				var graphic:FlxGraphic = cacheList.get(daPath);
				if (graphic != null && !graphic.persist && graphic.destroyOnNoUse) {
					cacheList.remove(path);
					if (FlxG.bitmap._cache.exists(daPath)) FlxG.bitmap.removeKey(daPath);
					if (!graphic.isDestroyed) graphic.destroy();
				}
			}

			if (includeRawFlixel) // clear flixel assets
			for (daPath in FlxG.bitmap._cache.keys()) {
				var path:String = Paths.addBeginningSlash(daPath);
				if (persistenceList.exists(path))
					switch (persistenceList.get(path)) {
						// ensures full clear
						case IsIndestructible: continue;
						default: persistenceList.remove(path);
					}

				var graphic:FlxGraphic = FlxG.bitmap.get(daPath);
				if (graphic != null && !graphic.persist && graphic.destroyOnNoUse) {
					FlxG.bitmap.removeKey(daPath);
					if (cacheList.exists(path)) cacheList.remove(path);
					if (!graphic.isDestroyed) graphic.destroy();
				}
			}
		} else {
			// clear engine assets
			for (path in cacheList.keys())
				remove(path, ignorePersistant);

			if (includeRawFlixel) // clear flixel assets
			for (daPath in FlxG.bitmap._cache.keys()) {
				var path:String = Paths.addBeginningSlash(daPath);
				if (persistenceList.exists(path)) {
					switch (persistenceList.get(path)) {
						case IsIndestructible:
							return;
						case IsPersistent:
							if (ignorePersistant) return;
						case IsVulnerable:
					} persistenceList.remove(path);
				}
				var graphic:FlxGraphic = FlxG.bitmap.get(daPath);
				if (graphic != null) {
					graphic.checkUseCount();
					if (graphic.isDestroyed)
						if (cacheList.exists(path))
							cacheList.remove(path);
				}
			}
		}
	}
}
final class AudioCache extends CacheTemplate<Sound> {
	override public function add(path:String, useFallback:Bool, persistenceLevel:PersistenceType = IsVulnerable):Sound {
		if (!Paths.fileExists('root:$path'))
			return useFallback ? getFallback() : null;

		if (cacheList.exists(path)) {
			persistenceList.set(path, persistenceLevel);
			return cacheList.get(path);
		}

		var daPath:String = Paths.removeBeginningSlash(path);
		if (OpenFLAssets.exists(daPath, SOUND)) {
			final sound:Sound = OpenFLAssets.getSound(daPath, false);
			OpenFLAssets.cache.setSound(daPath, sound);
			cacheList.set(path, sound);
			persistenceList.set(path, persistenceLevel);
			return sound;
		}

		final sound:Sound = Sound.fromFile(FileSystem.absolutePath(daPath));
		OpenFLAssets.cache.setSound(daPath, sound);
		cacheList.set(path, sound);
		persistenceList.set(path, persistenceLevel);
		return sound;
	}
	override public function remove(path:String, ignorePersistant:Bool = false):Void {
		final cache:OpenFLAssetCache = (OpenFLAssets.cache is OpenFLAssetCache) ? cast OpenFLAssets.cache : null;
		@:privateAccess if (cache != null) {
			switch (persistenceList.get(path)) {
				case IsIndestructible:
					return;
				case IsPersistent:
					if (ignorePersistant) return;
				case IsVulnerable:
			} persistenceList.remove(path);

			final sound:Sound = cache.sound.get(Paths.removeBeginningSlash(path));
			if (FlxG.sound.music == null || FlxG.sound.music._sound != sound)
				sound.close();
			for (conductor in Conductor.list)
				for (_sound in conductor.soundGroup.sounds) {
					if (_sound._sound != sound) {
						sound.close();
						break;
					}
				}
			cache.removeSound(Paths.removeBeginningSlash(path));
			cacheList.remove(path);
		}
	}

	override public function clear(ignorePersistant:Bool = false, fullDestroy:Bool = false, includeRawFlixel:Bool = false):Void {
		@:privateAccess if (fullDestroy) {
			final cache:OpenFLAssetCache = (OpenFLAssets.cache is OpenFLAssetCache) ? cast OpenFLAssets.cache : null;
			if (cache == null) return;

			// clear engine assets
			for (path in cacheList.keys()) {
				switch (persistenceList.get(path)) {
					// ensures full clear
					case IsIndestructible: continue;
					default: persistenceList.remove(path);
				}

				var daPath:String = Paths.removeBeginningSlash(path);
				final sound:Sound = cacheList.get(path);
				if (FlxG.sound.music == null || FlxG.sound.music._sound != sound)
					sound.close();
				for (conductor in Conductor.list)
					for (_sound in conductor.soundGroup.sounds) {
						if (_sound._sound != sound) {
							sound.close();
							break;
						}
					}
				cacheList.remove(path);
				if (cache.hasSound(daPath)) cache.removeSound(daPath);
			}

			if (includeRawFlixel) // clear flixel assets
			for (daPath in cache.sound.keys()) {
				var path:String = Paths.addBeginningSlash(daPath);
				switch (persistenceList.get(path)) {
					// ensures full clear
					case IsIndestructible: continue;
					default: persistenceList.remove(path);
				}

				final sound:Sound = cache.sound.get(daPath);
				if (FlxG.sound.music == null || FlxG.sound.music._sound != sound)
					sound.close();
				for (conductor in Conductor.list)
					for (_sound in conductor.soundGroup.sounds) {
						if (_sound._sound != sound) {
							sound.close();
							break;
						}
					}
				if (cacheList.exists(path)) cacheList.remove(path);
				cache.removeSound(daPath);
			}
		} else {
			// clear engine assets
			for (path in cacheList.keys())
				remove(path, ignorePersistant);

			if (includeRawFlixel) {
				final cache:OpenFLAssetCache = (OpenFLAssets.cache is OpenFLAssetCache) ? cast OpenFLAssets.cache : null;
				if (cache == null) return;
				// clear flixel assets
				for (daPath in cache.sound.keys()) {
					var path:String = Paths.addBeginningSlash(daPath);
					if (persistenceList.exists(path)) {
						switch (persistenceList.get(path)) {
							case IsIndestructible:
								return;
							case IsPersistent:
								if (ignorePersistant) return;
							case IsVulnerable:
						} persistenceList.remove(path);
					}

					final sound:Sound = cache.sound.get(daPath);
					if (FlxG.sound.music == null || FlxG.sound.music._sound != sound)
						sound.close();
					for (conductor in Conductor.list)
						for (_sound in conductor.soundGroup.sounds) {
							if (_sound._sound != sound) {
								sound.close();
								break;
							}
						}
					if (cacheList.exists(path)) cacheList.remove(path);
					cache.removeSound(daPath);
				}
			}
		}
	}
}

typedef ChartDataList = {
	/**
	 * All of the songs chart difficulties.
	 */
	var diffs:Map<String, ChartData>;
	/**
	 * All of the songs different variants.
	 */
	var variants:Map<String, ChartDataList>;
}
final class ChartCache extends CacheTemplate<ChartDataList> {
	override public function add(path:String, useFallback:Bool, persistenceLevel:PersistenceType = IsVulnerable):ChartDataList {
		if (!Paths.folderExists('root:$path/charts'))
			return useFallback ? getFallback() : null;

		if (cacheList.exists(path)) {
			persistenceList.set(path, persistenceLevel);
			return cacheList.get(path);
		}

		final list:ChartDataList = {
			diffs: new Map<String, ChartData>(),
			variants: new Map<String, ChartDataList>()
		}
		final song:String = path.split('/').last();
		for (file in Paths.readFolder('root:$path/charts', false)) {
			final diff:String = FilePath.withoutExtension(file.path);
			switch (file.extension) {
				case 'json':
					final chart:Null<ChartData> = ParseUtil.chart(song, diff);
					if (chart != null) list.diffs.set(diff, chart);
				case '':
					final subList:ChartDataList = {
						diffs: new Map<String, ChartData>(),
						variants: new Map<String, ChartDataList>()
					}
					list.variants.set(diff, subList);
					for (file in Paths.readFolder('root:$path/charts/$diff', false)) {
						final variant:String = FilePath.withoutExtension(file.path);
						final chart:Null<ChartData> = ParseUtil.chart(song, variant, diff);
						if (chart != null) subList.diffs.set(variant, chart);
					}
			}
		}

		cacheList.set(path, list);
		persistenceList.set(path, persistenceLevel);
		return list;
	}
	override public function remove(path:String, ignorePersistant:Bool = false):Void {
		switch (persistenceList.get(path)) {
			case IsIndestructible:
				return;
			case IsPersistent:
				if (ignorePersistant) return;
			case IsVulnerable:
		} persistenceList.remove(path);
		cacheList.remove(path);
	}

	override public function clear(ignorePersistant:Bool = false, fullDestroy:Bool = false, includeRawFlixel:Bool = false):Void
		for (path in cacheList.keys())
			remove(path, ignorePersistant);
}

/**
 * This class handles all assets that will be loaded in-game.
 */
class Assets {
	// TODO: Cache's to add - frames, charts, json objects
	/**
	 * Contains all loaded graphics.
	 */
	public static final graphics:GraphicCache = new GraphicCache('./flixel/images/logo/logo.png');
	/**
	 * Contains all loaded music.
	 */
	public static final songs:AudioCache = new AudioCache('./flixel/sounds/beep.ogg');
	/**
	 * Contains all loaded sounds.
	 */
	public static final sounds:AudioCache = new AudioCache('./flixel/sounds/beep.ogg');
	/**
	 * Contains all loaded frame collections.
	 */
	// public static final frameCollections:FramesCache = new FramesCache();
	/**
	 * Contains all loaded charts.
	 */
	public static final charts:ChartCache = new ChartCache();

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

		final songs:Array<ModPath> = FunkinUtil.getSongFolderNames();
		_log('[Assets] Pre-caching song chart information for ${[for (song in songs) song.path].cleanDisplayList()}.', DebugMessage);

		final successes:Array<String> = [];
		final fails:Array<String> = [];
		for (folder in songs) {
			final name:String = folder.path;
			if (charts.get(Paths.file('content/songs/$name').format(), false) != null)
				successes.push(name);
			else fails.push(name);
		}
		if (!successes.empty()) _log('[Assets] Chart information for ${successes.cleanDisplayList()} was cached successfully!', DebugMessage);
		if (!fails.empty()) _log('[Assets] Chart information for ${fails.cleanDisplayList()} has failed to cache.', ErrorMessage);
	}

	/**
	 * When called it clears **everything**.
	 * @param ignorePersistant If true, the asset won't be ignored, even if it's marked as persistant.
	 * @param runGarbageCollector If true, this will run the garbage collector.
	 * @param isMajor If true, it cleans out bigger chunks of data.
	 */
	inline public static function clearAll(ignorePersistant:Bool = false, runGarbageCollector:Bool = false, isMajor:Bool = false):Void {
		graphics.clear(ignorePersistant, isMajor, true);
		songs.clear(ignorePersistant, isMajor);
		sounds.clear(ignorePersistant, isMajor, true);
		// frameCollections.clear(ignorePersistant);
		charts.clear(ignorePersistant);
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
	 * @param isMusic It true, then the audio will be cached as music.
	 * @return Sound ~ The sound data.
	 */
	inline public static function audio(file:ModPath, beepWhenNull:Bool = true, isMusic:Bool = false):Sound {
		return (isMusic ? songs : sounds).get(Paths.audio(file).format(), beepWhenNull);
	}
	/**
	 * Gets the data of a songs instrumental file.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param variant The variant key.
	 * @return Sound ~ The sound data.
	 */
	inline public static function inst(song:String, variant:String = 'normal'):Sound
		return audio(Paths.inst(song, variant), true, true);
	/**
	 * Gets the data of a songs vocal track.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param suffix The suffix tag.
	 * @param variant The variant key.
	 * @return ModPath ~ The sound data.
	 */
	inline public static function vocal(song:String, suffix:String, variant:String = 'normal'):Sound
		return audio(Paths.vocal(song, suffix, variant), false, true);
	/**
	 * Gets the data of a song.
	 * From `../music/`.
	 * @param file The mod path.
	 * @return ModPath ~ The sound data.
	 */
	inline public static function music(file:ModPath):Sound
		return audio(Paths.music(file), true, true);
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
	 * Gets a song chart.
	 * @param song The song folder name.
	 * @param difficulty The difficulty key.
	 * @param variant The variant key.
	 * @return ChartData ~ The chart data.
	 */
	public static function chart(song:String, difficulty:String, variant:String = 'normal'):ChartData {
		final list:ChartDataList = charts.get(Paths.file('content/songs/$song').format(), false);
		if (list._fields().empty()) {
			_log('[Assets] No list instance found. (song:$song)', DebugMessage);
			return null;
		}
		if (variant != 'normal') {
			final list:ChartDataList = list.variants.get(variant);
			if (list._fields().empty()) {
				_log('[Assets] No list instance found. (song:$song, variant:$variant)', DebugMessage);
				return null;
			}
			if (!list.diffs.exists(difficulty))
				_log('[Assets] No chart found. (song:$song, difficulty:$difficulty, variant:$variant)', DebugMessage);
			return list.diffs.get(difficulty);
		}
		if (!list.diffs.exists(difficulty))
			_log('[Assets] No chart found. (song:$song, difficulty:$difficulty)', DebugMessage);
		return list.diffs.get(difficulty);
	}

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