package backend.system;

import haxe.CallStack;
import haxe.io.Path;
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

		path = './crash/' + 'ImaginativeEngine_' + dateNow + '.txt';

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + ' (line ' + line + ')\n';
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += '\nUncaught Error: ' + e.error + '\n\n> Crash Handler written by: Nebula S. Nova';

		if (!FileSystem.exists('./crash/'))
			FileSystem.createDirectory('./crash/');

		File.saveContent(path, errMsg + '\n');

		Sys.println(errMsg);
		Sys.println('Crash dump saved in ' + Path.normalize(path));

		FlxWindow.direct.self.alert(errMsg, 'Error!');
		FlxG.resetState();
	}
}