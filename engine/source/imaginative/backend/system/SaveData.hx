package imaginative.backend.system;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

/**
 * Forces specification for "saveName"s but since this is a string you can do whatever you want really.
 */
enum abstract SaveType(String) from String to String {
	#if debug
	/**
	 * For when a debug build is compiled.
	 */
	var DEBUG = 'debug';
	#end
	/**
	 * For specific stuff flixel tends to do.
	 */
	var FLIXEL = 'flixel';
	/**
	 * For engine settings.
	 */
	var SETTINGS = 'settings';
	/**
	 * For player controls.
	 */
	var CONTROLS = 'controls';
	/**
	 * Where scores are kept.
	 */
	var SCORE = 'score';
}

/**
 * Extendable for scripting I guess.
 */
class SaveDataClass {
	public function new() {}
	inline public function toString():String // so it doesn't return the class name
		return '${this.getClassName()}: [' + [for (field in this._fields()) '$field => ${this._get(field)}'].join(', ') + ']';
}
final private class DebugSaveData extends SaveDataClass {
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
final private class SettingsSaveData extends SaveDataClass {
	/**
	 * The main user settings.
	 */
	public var main:MainSettings;
	/**
	 * The players settings.
	 */
	public var player1:PlayerSettings;
	/**
	 * The second players settings.
	 */
	public var player2:PlayerSettings;
}
// MAYBE: Make this not maps?
final private class ControlsSaveData extends SaveDataClass {
	/**
	 * The general controls.
	 */
	public var global:Map<String, Array<FlxKey>> = [
		// UI
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],

		// Actions
		'accept' => [ENTER, SPACE],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, DELETE],

		// Volume
		'volume_up' => [PLUS, NUMPADPLUS],
		'volume_down' => [MINUS, NUMPADMINUS],
		'volume_mute' => [ZERO, NUMPADZERO],

		// Extras
		'fullscreen' => [F11],

		// Debug
		'botplay' => [F4],
		'resetState' => [F5],
		'shortcutState' => [F6],
		'reloadGame' => [F8]
	];
	/**
	 * The players controls.
	 */
	public var player1:Map<String, Array<FlxKey>> = [
		// 4 Keys
		'note_4:0' => [E, LEFT],
		'note_4:1' => [F, DOWN],
		'note_4:2' => [K, UP],
		'note_4:3' => [O, RIGHT]
	];
	/**
	 * The second players controls.
	 */
	public var player2:Map<String, Array<FlxKey>> = [];
}

@:access(flixel.util.FlxSave)
class SaveData {
	/**
	 * The active saves that have been initialized.
	 */
	static final saveInstances:Map<SaveType, FlxSave> = new Map<SaveType, FlxSave>();
	/**
	 * The current save slot.
	 */
	static var saveSlot(default, null):Int = 0;

	/**
	 * Returns the engine save path.
	 * @return String ~ The save path.
	 */
	public static final savePath:String = 'Funkin-Imaginative/Save${#if debug 'Debug' #else saveSlot #end}';

	@:allow(imaginative.backend.system.Main.new)
	static function init():Void {
		#if debug initSave(DEBUG); #end
		initSave(FLIXEL); // initializes this pre FlxGame init so we don't just have flixel init a random one based the exe file name
		FlxWindow.instance.self.onClose.add(() -> {
			#if debug
			if (debug.clearOnExit) {
				debug.flixelVolume = FlxG.save.data.volume;
				debug.flixelMute = FlxG.save.data.mute;
			}
			#end
			for (name => save in saveInstances) {
				var success = save.flush();
				if (success) _log('[SaveData] Successfully saved path "$savePath/$name".');
			}
			#if debug
			if (debug.clearOnExit)
				for (saveName in saveInstances.keys())
					if (saveName != SaveType.DEBUG)
						clearSave(saveName);
			#end
		});
	}

	#if debug
	/**
	 * The save data for debug builds.
	 */
	public static var debug(get, never):DebugSaveData;
	inline static function get_debug():DebugSaveData
		return getSave(DEBUG).data.content;
	#end
	// There ain't one for flixel because it's literally just "FlxG.save", I'm not making a shortcut for a shortcut.
	/**
	 * The save data for settings.
	 */
	public static var settings(get, never):SettingsSaveData;
	inline static function get_settings():SettingsSaveData
		return getSave(SETTINGS).data.content;
	/**
	 * The save data for controls.
	 */
	public static var controls(get, never):ControlsSaveData;
	inline static function get_controls():ControlsSaveData
		return getSave(CONTROLS).data.content;

	/**
	 * Returns the 'FlxSave' instance if its been pre-initialized.
	 * @param saveName The file name for the save.
	 * @return Null<FlxSave> ~ The 'FlxSave' instance.
	 */
	static function getSave(saveName:SaveType):Null<FlxSave> {
		if (saveInstances.exists(saveName))
			return saveInstances.get(saveName);
		_log('[SaveData] Save path of "$savePath/$saveName" needs to be initialized first before attempting to get it.');
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
			_log('[SaveData] Loading save "$savePath/$saveName".');
			save.bind(saveName, savePath);
			switch (save.status) {
				case EMPTY: // it only calls this if you don't run bind()
					_log('[SaveData] Save "$savePath/$saveName" was empty, new save initiated!', DebugMessage);
				case ERROR(msg):
					_log('[SaveData] Error on save "$savePath/$saveName". (error:$msg)', ErrorMessage);
				case SAVE_ERROR(type):
					_log('[SaveData] Error saving "$savePath/$saveName". (error:$type)', ErrorMessage);
				case LOAD_ERROR(type):
					_log('[SaveData] Error loading "$savePath/$saveName". (error:$type)', ErrorMessage);
				case BOUND(name, path):
					if (save.isEmpty()) _log('[SaveData] Save "$path/$name" was empty, new save initiated!', DebugMessage);
					else _log('[SaveData] Save "$path/$name" has data, save initiated! (savedata:${save.isEmpty() ? 'empty' : save.data})', DebugMessage);
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
					// if (!(data is Type.getClass(template))) return template;
					for (field in template._fields())
						if (!data._has(field) || data._get(field) == null)
							data._set(field, template._get(field));
					return data;
				}
				switch (saveName) {
					#if debug
					case DEBUG:
						if (save.isEmpty()) save.data._set('content', new DebugSaveData());
						save.data._set('content', mergeNewClassVars(save.data.content, new DebugSaveData()));
					case FLIXEL:
						if (save.isEmpty())
							save.data = {
								volume: debug.flixelVolume,
								mute: debug.flixelMute
							}
					#end
					case SETTINGS:
						if (save.isEmpty()) save.data._set('content', new SettingsSaveData());
						save.data._set('content', mergeNewClassVars(save.data.content, new SettingsSaveData()));
					case CONTROLS:
						if (save.isEmpty()) save.data._set('content', new ControlsSaveData());
						save.data._set('content', mergeNewClassVars(save.data.content, new ControlsSaveData()));
					default:
				}
				#if debug
				var nonDebugPath:String = savePath.replace('Debug', '$saveSlot');
				try {
					if (debug.mergeBaseSave && saveName != SaveType.DEBUG) { // allows debug builds to get save data from non-debug builds
						save.mergeDataFrom(saveName, nonDebugPath, true, false);
						_log('[SaveData] Merged from base save. ($savePath/$nonDebugPath)', DebugMessage);
					}
				} catch(error:haxe.Exception)
					_log('[SaveData] Failed to merge base save. ($savePath/$nonDebugPath)', ErrorMessage);
				#end
				var success = save.flush();
				if (success) _log('[SaveData] Successfully saved path "$savePath/$saveName".');
				return true;
			} else if (saveName != FLIXEL)
				save.destroy();
		}
		return false;
	}

	/**
	 * Clears the save data from the set path.
	 * @param saveName The file name for the save.
	 */
	static function clearSave(saveName:SaveType):Void {
		if (saveInstances.exists(saveName)) {
			getSave(saveName).erase();
			_log('[SaveData] Save "$savePath/$saveName" was erased.');
		} else _log('[SaveData] Save "$savePath/$saveName" needs to be initialized first before attempting to clear it.');
	}
}