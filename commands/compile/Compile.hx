package compile;

import sys.FileSystem;
import sys.io.File;

using StringTools;

class Compile {
	static var args:Array<String>;
	public static function run(ranArgs:Array<String>):Void {
		args = ranArgs;

		Sys.println(Main.dashes);

		if (args.contains('--check-platform')) {
			platformCheck();
			return;
		}

		if (getCompileTarget() == 'unknown') {
			Sys.println('Your target is unknown!');
			platformCheck(true);
			return;
		} else Sys.println('Compiling for platform target "${getCompileTarget()}".');

		if (getCompileTarget() == 'cpp') {
			Sys.sleep(2);
			Sys.println('Wait... cpp? Nah dude, put a **real** target!');
			Sys.sleep(1);
			Sys.println('Do you wish to input your platform type? [y/n]');
			if (Sys.stdin().readLine().toLowerCase() == 'y') {
				Sys.println(Main.dashes);
				if (FileSystem.exists('commands/compile/platform.txt'))
					FileSystem.deleteFile('commands/compile/platform.txt');
				platformCheck(true, true);
			} else {
				if (FileSystem.exists('commands/compile/platform.txt'))
					FileSystem.deleteFile('commands/compile/platform.txt');
			}
			return;
		}

		var finalArgs:Array<String> = [typeCheck(args.shift()), getCompileTarget()];
		for (arg in args)
			finalArgs.push(arg);
		Sys.println('lime ${finalArgs.join(' ')}');
		Sys.command('lime', finalArgs);
	}

	static function platformCheck(doneAgain:Bool = false, wasCpp:Bool = false):Void {
		if (FileSystem.exists('commands/compile/platform.txt')) {
			var content:String = File.getContent('commands/compile/platform.txt').toLowerCase().trim();
			if (content == 'cpp') {
				if (wasCpp) {
					Sys.println('HUH???');
					Sys.sleep(0.5);
					Sys.println('HOW??');
					Sys.sleep(1);
					Sys.println('You\'re fast!');
					if (FileSystem.exists('commands/compile/platform.txt'))
						FileSystem.deleteFile('commands/compile/platform.txt');
					Sys.sleep(2);
					Sys.println('This time I\'m booting you from the loop!');
					for (i in 0...10) {
						Sys.sleep(1);
						if (FileSystem.exists('commands/compile/platform.txt')) {
							FileSystem.deleteFile('commands/compile/platform.txt');
							Sys.println('\nNuh uh.');
							break;
						}
					}
				} else {
					Sys.println('c-');
					Sys.sleep(0.5);
					Sys.println('...');
					Sys.sleep(2);
					Sys.println('cpp...');
					Sys.sleep(3);
					Sys.println('Yeah I\'m deletin\' that shit.');
					if (FileSystem.exists('commands/compile/platform.txt'))
						FileSystem.deleteFile('commands/compile/platform.txt');
					Sys.sleep(2);
					Sys.println(Main.dashes);
					platformCheck(false, true);
				}
			} else Sys.println(content);
		} else {
			if (doneAgain)
				Sys.println('Please type your device platform. Do "auto" to detect your device platform!');
			else
				Sys.println('No "platform.txt" exists. Please type your device platform. Do "auto" to detect your device platform!');
			var content:String = Sys.stdin().readLine().toLowerCase();
			if (content == 'cpp') {
				if (doneAgain) {
					Sys.sleep(1);
					Sys.println('...');
					Sys.sleep(2);
					Sys.println('No.');
					Sys.sleep(0.5);
					Sys.println(Main.dashes);
					platformCheck(true);
					return;
				} else {
					Sys.sleep(1);
					Sys.println('I said "auto", not "cpp"!');
					Sys.sleep(1);
					Sys.println(Main.dashes);
					platformCheck(true);
					return;
				}
			}
			File.saveContent('commands/compile/platform.txt', content == 'auto' ? getCompileTarget() : content);
		}
	}

	static function typeCheck(commandType:Null<String>):String {
		if (commandType == null) {
			if (commandType != null)
				args.insert(0, commandType);
			Sys.println('Please input a **real** lime command type.\nNext time, have it as your first arg.');
			commandType = Sys.stdin().readLine().toLowerCase();
		} else { // I fucking hate this, doing || wasn't working right so idfk, deal with it.
			if (commandType != 'clean')
				if (commandType != 'update')
					if (commandType != 'build')
						if (commandType != 'run')
							if (commandType != 'test') {
								if (commandType != null)
									args.insert(0, commandType);
								Sys.println('Please input a lime command type.');
								commandType = Sys.stdin().readLine().toLowerCase();
							}
		}
		return commandType.trim();
	}

	static function getCompileTarget():String {
		if (FileSystem.exists('commands/compile/platform.txt')) {
			var platform:String = File.getContent('commands/compile/platform.txt').toLowerCase().trim();
			return switch (platform) {
				case 'macos': 'mac';
				default: platform;
			}
		}
		return switch(Sys.systemName()) {
			case 'Windows':
				'windows';
			case 'Mac':
				'mac';
			case 'Linux':
				'linux';
			default:
				'unknown';
		}
	}
}