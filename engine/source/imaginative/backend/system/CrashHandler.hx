package imaginative.backend.system;

import haxe.CallStack;
import sys.io.File;
import openfl.events.UncaughtErrorEvent;

class CrashHandler {
	@:allow(imaginative.backend.system.Main)
	inline static function onCrash(e:UncaughtErrorEvent):Void {
		var errMsg:String = '';
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(' ', '_');
		dateNow = dateNow.replace(':', '\'');

		path = './crash/Imaginative_$dateNow.txt';

		for (stackItem in callStack) {
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

		File.saveContent(path, errMsg + '\n');

		_log(errMsg, ErrorMessage);
		_log('Crash dump saved in ${FilePath.normalize(path)}', ErrorMessage);

		FlxWindow.instance.self.alert(errMsg, 'Error!');
		BeatState.switchState(() -> new imaginative.states.menus.MainMenu());
	}
}