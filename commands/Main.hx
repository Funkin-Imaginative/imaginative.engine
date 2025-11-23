package;

import compile.Compile;
import setup.Setup;

typedef Command = {
	var names:Array<String>;
	var func:Array<String>->Void;
	var ?description:String;
	var ?elaboration:String;
}

class Main {
	inline public static final dashes:String = '-------------------------------------------------------------------------------';

	public static var commands:Array<Command> = [
		{
			names: ['help', null],
			func: help,
			description: 'Tells you how things work. Put a command name for extra info on it (if it has any).'
		},
		{
			names: ['setup'],
			func: Setup.run,
			description: 'Installs / Updates libraries needed for the engine to run.'
		},
		{
			names: ['compile'],
			func: Compile.run,
			description: 'Compiles the engine.'
		}
	];

	public static function main():Void {
		var args:Array<String> = Sys.args();
		var commandName:String = args.shift()?.toLowerCase();
		for (command in commands) {
			if (command.names.contains(commandName)) {
				command.func(args);
				break;
			}
		}
	}

	public static function help(args:Array<String>):Void {
		Sys.println('does nothing for now');
	}
}