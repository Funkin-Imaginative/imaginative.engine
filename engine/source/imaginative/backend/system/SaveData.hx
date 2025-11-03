package imaginative.backend.system;

// import flixel.util.FlxSave;

class SaveData {
	static final savePath:String = 'Funkin-Imaginative';
	static final saveName:String = 'settings';
	static var saveSlot:Int = 0;

	@:allow(imaginative.backend.system.Main.new)
	static function init():Void {
		_log('[SaveData] Loading save slot "$saveSlot".');

		FlxG.save.bind('$saveSlot/$saveName', savePath);

		switch (FlxG.save.status) {
			case EMPTY:
				_log('[SaveData] Slot "$saveSlot" was empty, new save initiated.');
			case ERROR(msg):
				_log('[SaveData] Error in slot "$saveSlot".');
			case SAVE_ERROR(type):
				_log('[SaveData] Error saving slot "$saveSlot", error "$type"');
			case LOAD_ERROR(type):
				_log('[SaveData] Error loading slot "$saveSlot", error "$type"');
			case BOUND(name, path):
				_log('[SaveData] Slot "$saveSlot" has data, save initiated.');
		}
	}
}