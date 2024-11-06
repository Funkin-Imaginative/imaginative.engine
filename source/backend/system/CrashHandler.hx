package backend.system;

import haxe.CallStack;
import sys.io.File;
import openfl.events.UncaughtErrorEvent;

class CrashHandler {
	@:allow(backend.system.Main)
	static function onCrash(e:UncaughtErrorEvent):Void {
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
					Sys.println(stackItem);
			}
		}

		errMsg += '\nUncaught Error: $e.error\n\n> Crash Handler written by: Nebula S. Nova';

		if (!FileSystem.exists('./crash/'))
			FileSystem.createDirectory('./crash/');

		File.saveContent(path, errMsg + '\n');

		Sys.println(errMsg);
		Sys.println('Crash dump saved in ${FilePath.normalize(path)}');

		FlxWindow.direct.self.alert(errMsg, 'Error!');
		BeatState.resetState();
	}
}