package imaginative.backend.system;

import flash.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import lime.utils.Assets as LimeAssets;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFLAssets; // #if CONTAINS_EMBEDDED_FILES // #end

enum abstract AssetType(String) from String to String {
	var IMAGE;
	var AUDIO;

	var UNFILLED;
}

class EngineAsset {
	/**
	 * A shortcut function for making an EngineAsset from a ModPath.
	 * @param path The mod path.
	 * @param assetType The asset type.
	 * @return `EngineAsset`
	 */
	inline public static function fromModPath(path:ModPath, assetType:AssetType = UNFILLED):EngineAsset {
		path.simplifyPathType();
		return new EngineAsset(path.path, assetType, path.type);
	}

	public var modPath:String;
	public var assetType:AssetType;
	public var fromEngine:Bool;
	public var forcedModType:ModType;

	public function new(modPath:String, assetType:AssetType = UNFILLED, fromEngine:Bool = true, forcedModType:ModType = ANY) {
		this.modPath = modPath;
		this.assetType = assetType;
		this.fromEngine = fromEngine;
		this.forcedModType = forcedModType;
	}

	inline public function pathTypingFormat():String {
		return switch (assetType) {
			case IMAGE: '${FilePath.withoutExtension(modPath)}.png'; // lol
			case AUDIO: Paths.audio(modPath, false).path; // since Paths.audio doesn't add anything to the path itself, this works
			case UNFILLED: modPath;
		}
	}

	inline public function guessPath():String {
		var type:ModType = forcedModType == ANY ? ModType.typeFromPath(modPath) : forcedModType;
		if (!fromEngine || type == null) {
			return modPath;
		} else {
			var mod:ModPath = new ModPath(modPath, type);
			return mod.format();
		}
	}

	inline public function createModPath():ModPath {
		return new ModPath(pathTypingFormat(), forcedModType);
	}

	inline public function toString(values):String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('Mod Path', modPath),
			LabelValuePair.weak('Asset Type', assetType),
			LabelValuePair.weak('From Engine', fromEngine),
			LabelValuePair.weak('Forced Mod Type', forcedModType)
		]);
	}
}

/**
 * This is mostly taken from Psych since idk what to actually do.
 */
@:access(openfl.display.BitmapData)
class Assets {
	@:allow(imaginative.states.EngineProcess)
	static function init():Void {
		for (asset in dumpExclusions) {
			switch (asset.assetType) {
				case IMAGE:
					cacheBitmap(asset);
				case AUDIO:
					cacheSound(asset);
				default:
			}
		}
	}

	/**
	 * Paths that the game shouldn't dump their data for when dumping data.
	 */
	public static var dumpExclusions(default, null):Array<EngineAsset> = [
		new EngineAsset('music/breakfast', AUDIO, MAIN),
		new EngineAsset('music/freakyMenu', AUDIO, MAIN),
		new EngineAsset('flixel/sounds/beep', AUDIO, false),
		new EngineAsset('images/menus/bgs/menuArt', IMAGE, MAIN)
	];
	/**
	 * An asset to exclude from dumpping.
	 * @param asset The asset.
	 */
	inline public static function excludeAsset(asset:EngineAsset):Void
		if (!dumpExclusions.contains(asset))
			dumpExclusions.push(asset);
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
	// 		var path:String = fixPath(tag);
	// 		var modPath:ModPath = new ModPath(path, ModType.typeFromPath(tag));
	// 		if (!loadedGraphics.exists(modPath))
	// 			destroyGraphic(FlxG.bitmap.get(tag));
	// 	}
	// 	// clear non loaded sounds
	// 	for (tag => sound in loadedSounds) {
	// 		var path:String = fixPath(tag);
	// 		var modPath:ModPath = new ModPath(path, ModType.typeFromPath(tag));
	// 		if (!assetsInUse.contains(modPath) && !dumpExclusions.contains(modPath)) {
	// 			LimeAssets.cache.clear(tag);
	// 			loadedSounds.remove(modPath);
	// 		}
	// 	}
	// }
	// public static function freeGraphicsFromMemory():Void {
	// 	var protected:Array<FlxGraphic> = [];
	// 	function checkForGraphics(object:Dynamic):Void {
	// 		if (object is FlxSprite) {
	// 			var graphic:FlxGraphic = cast(object, FlxSprite).graphic;
	// 			if (graphic != null)
	// 				protected.push(graphic);
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
	// 		var path:String = fixPath(tag);
	// 		var modPath:ModPath = new ModPath(path, ModType.typeFromPath(tag));
	// 		if (!dumpExclusions.contains(modPath))
	// 			if (!protected.contains(graphic)) {
	// 				destroyGraphic(graphic);
	// 				loadedGraphics.remove(modPath);
	// 			}
	// 	}
	// }

	/**
	 * Assets that are currently being used have their mod paths stored in this array.
	 */
	public static var assetsInUse:Array<EngineAsset> = [];

	/**
	 * A map of all loaded graphics.
	 */
	public static var loadedGraphics:Map<EngineAsset, FlxGraphic> = new Map<EngineAsset, FlxGraphic>();
	inline static function listGraphic(asset:EngineAsset, graphic:FlxGraphic):FlxGraphic {
		asset.assetType = IMAGE; // force image type
		loadedGraphics.set(asset, graphic);
		assetsInUse.push(asset);
		return graphic;
	}

	/**
	 * A map of all loaded sounds.
	 */
	public static var loadedSounds:Map<EngineAsset, Sound> = new Map<EngineAsset, Sound>();
	inline static function listSound(asset:EngineAsset, sound:Sound):Sound {
		asset.assetType = AUDIO; // force audio type
		loadedSounds.set(asset, sound);
		assetsInUse.push(asset);
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
		var path:ModPath = Paths.image(file, false);
		var asset:EngineAsset = EngineAsset.fromModPath(path, IMAGE);
		if (loadedGraphics.exists(asset)) {
			assetsInUse.push(asset);
			return loadedGraphics.get(asset);
		}
		return cacheBitmap(asset);
	}

	/**
	 * Get's the data of an audio file.
	 * @param file The mod path.
	 * @param beepWhenNull If true, the flixel beep sound when play when the wanted sound doesn't exist.
	 * @return `Sound` ~ The sound data.
	 */
	inline public static function audio(file:ModPath, beepWhenNull:Bool = true):Sound {
		var path:ModPath = Paths.image(file, false);
		var asset:EngineAsset = EngineAsset.fromModPath(path, IMAGE);
		return cacheSound(asset, beepWhenNull);
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

	static function cacheBitmap(asset:EngineAsset):FlxGraphic {
		var modPath:ModPath = asset.createModPath();

		var bitmap:BitmapData = null;
		if (Paths.fileExists(modPath, asset.fromEngine)) {
			bitmap = BitmapData.fromFile(modPath.format());
			// #if CONTAINS_EMBEDDED_FILES
			if (bitmap == null)
				bitmap = OpenFLAssets.getBitmapData(modPath.format());
			// #end
		}
		if (bitmap == null) {
			FlxG.log.error('No bitmap data from path "${modPath.format()}".');
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

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, modPath.format());
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		return listGraphic(asset, graphic);
	}
	static function cacheSound(asset:EngineAsset, beepWhenNull:Bool = true):Sound {
		var modPath:ModPath = asset.createModPath();

		var result:Sound = null;
		if (!loadedSounds.exists(asset)) {
			if (Paths.fileExists(modPath)) {
				result = Sound.fromFile(modPath.format());
				// #if CONTAINS_EMBEDDED_FILES
				if (result == null)
					result = OpenFLAssets.getSound(modPath.format());
				// #end
				if (result == null) {
					FlxG.log.error('No sound data from path "${modPath.format()}".');
					return beepWhenNull ? FlxAssets.getSound('flixel/sounds/beep') : null;
				}
			}
		}
		return listSound(asset, result);
	}

	inline static function fixPath(nonModPath:String):String {
		var path:String = nonModPath;
		if (#if MOD_SUPPORT path.startsWith('solo') || path.startsWith('mods') #else path.startsWith(Main.mainMod) #end) {
			var pathSplit:Array<String> = path.split('/');
			pathSplit.pop(); #if MOD_SUPPORT pathSplit.pop(); #end
			path = pathSplit.join('/');
		}
		return path;
	}
}