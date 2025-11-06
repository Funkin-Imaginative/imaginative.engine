package imaginative.backend.system;

import haxe.CallStack;
import sys.io.File;
import openfl.events.UncaughtErrorEvent;

// TODO: Figure out if this is working.
class CrashHandler {
	@:allow(imaginative.backend.system.Main.new)
	static function init():Void {
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	inline static function onCrash(e:UncaughtErrorEvent):Void {
		var errMsg:String = '';
		for (stackItem in CallStack.exceptionStack(true)) {
			switch (stackItem) {
				case FilePos(_, file, line, _):
					errMsg += '$file (line $line)\n';
				default:
					_log(stackItem, ErrorMessage);
			}
		}

		errMsg += '\nUncaught Error: $e.error\n\n> Crash Handler written by: Nebula S. Nova';

		if (!FileSystem.exists('./crash/'))
			FileSystem.createDirectory('./crash/');

		var path:String = './crash/Imaginative_${Date.now().toString().replace(' ', '_').replace(':', "'")}.txt';
		File.saveContent(path, errMsg + '\n');
		_log(errMsg, ErrorMessage);
		_log('Crash dump saved in ${FilePath.normalize(path)}', ErrorMessage);

		FlxWindow.instance.self.alert(errMsg, 'Error!');
		BeatState.switchState(() -> new imaginative.states.menus.MainMenu());
	}
}