package imaginative.backend.system;

import flixel.util.FlxSave;

/**
 * Forces specification for "saveName"s but since this is a string you can do whatever you want really.
 */
enum abstract SaveType(String) from String to String {
	/**
	 * For specific stuff flixel tends to do.
	 */
	var FLIXEL = 'flixel';
	/**
	 * For engine settings.
	 */
	var SETTINGS = 'settings';
	#if debug
	/**
	 * For when a debug build is compiled.
	 * This type is also unable to be erased.
	 */
	var DEBUG = 'debug';
	#end
}

/**
 * Extendable for scripting I guess.
 */
class SaveDataClass {
	public function new() {}
	inline public function toString():String // so it doesn't return the class name
		return '${this.getClassName()}: [' + [for (field in Reflect.fields(this)) '$field => ${Reflect.getProperty(this, field)}'].join(', ') + ']';
}
private class DebugSaveData extends SaveDataClass {
	/**
	 * Whether to merge from the save data of non-debug builds.
	 */
	public var mergeBaseSave:Bool = false;
	/**
	 * Whether to clear all saves on exit.
	 */
	public var clearOnExit:Bool = true;

	/**
	 * The last set state of "volume" before save clear.
	 */
	public var flixelVolume:Float = 1;
	/**
	 * The last set state of "mute" before save clear.
	 */
	public var flixelMute:Bool = false;
}

@:access(flixel.util.FlxSave)
class SaveData {
	/**
	 * The active saves that have been initialized.
	 */
	static var saveInstances:Map<SaveType, FlxSave> = new Map<SaveType, FlxSave>();
	/**
	 * The current save slot.
	 */
	static var saveSlot:Int = 0;

	@:allow(imaginative.backend.system.Main.new)
	static function init():Void {
		#if debug initSave(DEBUG); #end
		initSave(FLIXEL); // initializes this pre FlxGame init so we don't just have flixel init a random one based the exe file name
		FlxWindow.instance.self.onClose.add(() -> {
			for (name => save in saveInstances) {
				var success = save.flush();
				if (success) _log('[SaveData] Successfully saved path "$name".');
			}
			#if debug
			if (debug.clearOnExit) {
				debug.flixelVolume = FlxG.save.data.volume;
				debug.flixelMute = FlxG.save.data.mute;
				clearAllSaves();
			}
			#end
		});
	}

	#if debug
	/**
	 * The save data for debug builds.
	 */
	public static var debug(get, never):DebugSaveData;
	inline static function get_debug():DebugSaveData
		return getSave(DEBUG).data;
	#end
	/**
	 * The save data for the player settings.
	 */
	public static var settings(get, never):FlxSave;
	inline static function get_settings():FlxSave
		return getSave(SETTINGS);

	/**
	 * Returns the 'FlxSave' instance if its been pre-initialized.
	 * @param saveName The file name for the save.
	 * @return Null<FlxSave> ~ The 'FlxSave' instance.
	 */
	static function getSave(saveName:SaveType):Null<FlxSave> {
		if (saveInstances.exists(saveName))
			return saveInstances.get(saveName);
		_log('[SaveData] Save path of "$saveName" needs to be initialized first before attempting to get it.');
		return null;
	}

	/**
	 * Initializes a save for the engine to use.
	 * @param saveName The file name for the save.
	 * @return Bool ~ Whether or not you successfully connected to the save data.
	 */
	static function initSave(saveName:SaveType):Bool {
		if (saveInstances.exists(saveName))
			return true;
		else {
			var save:FlxSave = saveName == FLIXEL ? FlxG.save : new FlxSave();
			_log('[SaveData] Loading save slot "$saveSlot" of path "$saveName".');
			save.bind('$saveSlot/$saveName', 'Funkin-Imaginative' #if debug + '/debug' #end);
			switch (save.status) {
				case EMPTY:
					_log('[SaveData] Slot "$saveSlot" of path "$saveName" was empty, new save initiated.', DebugMessage);
				case ERROR(msg):
					_log('[SaveData] Error in slot "$saveSlot" of path "$saveName".', ErrorMessage);
				case SAVE_ERROR(type):
					_log('[SaveData] Error saving slot "$saveSlot" of path "$saveName", error "$type"', ErrorMessage);
				case LOAD_ERROR(type):
					_log('[SaveData] Error loading slot "$saveSlot" of path "$saveName", error "$type"', ErrorMessage);
				case BOUND(name, path):
					_log('[SaveData] Slot "$saveSlot" of path "$saveName" has data, save initiated.', DebugMessage);
			}
			if (save.isBound) {
				saveInstances.set(saveName, save);
				/**
				 * Just in case new variables are added to the classes.
				 * @param data The data to affect.
				 * @param template The data to template from.
				 * @return T
				 */
				inline function mergeNewClassVars<T:SaveDataClass>(data:Dynamic, template:T):T {
					for (field in Reflect.fields(template))
						if (!Reflect.hasField(data, field))
							Reflect.setField(data, field, Reflect.getProperty(template, field));
					return data;
				}
				switch (saveName) {
					#if debug
					case FLIXEL:
						if (save.isEmpty()) {
							save.data.volume = debug.flixelVolume;
							save.data.mute = debug.flixelMute;
						}
					#end
					case SETTINGS:
					#if debug
					case DEBUG:
						if (save.isEmpty()) save.data = new DebugSaveData();
						save.data = mergeNewClassVars(save.data, new DebugSaveData());
					#end
					default:
				}
				#if debug
				try {
					if (debug.mergeBaseSave && saveName != SaveType.DEBUG) { // allows debug builds to get save data from non-debug builds
						save.mergeDataFrom('$saveSlot/$saveName', 'Funkin-Imaginative', true, false);
						_log('[SaveData] Merge from base save.', DebugMessage);
					}
				} catch(error:haxe.Exception)
					_log('[SaveData] Failed to merge from base save.', ErrorMessage);
				#end
				save.flush();
				return true;
			}
		}
		return false;
	}

	static var clearingAll:Bool = false;
	/**
	 * Clears the save data from the set path.
	 * @param saveName The file name for the save.
	 */
	static function clearSave(saveName:SaveType):Void {
		#if debug if (saveName == SaveType.DEBUG) return; #end
		if (saveInstances.exists(saveName)) {
			getSave(saveName).erase();
			if (!clearingAll) _log('[SaveData] Save path of "$saveName" was erased.');
		} else _log('[SaveData] Save path of "$saveName" needs to be initialized first before attempting to clear it.');
	}
	/**
	 * Clears all save data of the current slot.
	 */
	static function clearAllSaves():Void {
		clearingAll = true;
		for (saveName in saveInstances.keys())
			#if debug if (saveName != SaveType.DEBUG) #end
				clearSave(saveName);
		clearingAll = false;
		_log('[SaveData] All save data of slot "${saveSlot}" was erased.');
	}
}