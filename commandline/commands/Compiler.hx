package commands;

class Compiler {
	public static function run(args:Array<String>) {
		__build(args, ['test', getBuildTarget(), '-debug']);
	}
	public static function compile(args:Array<String>) {
		__build(args, ['build', getBuildTarget(), '-debug']);
	}
	public static function compileRelease(args:Array<String>) {
		__build(args, ['build', getBuildTarget(), '-final']);
	}
	public static function runRelease(args:Array<String>) {
		__build(args, ['test', getBuildTarget(), '-final']);
	}

	private static function __build(args:Array<String>, arg:Array<String>) {
		for(a in args)
			arg.push(a);
		Sys.command('lime', arg);
	}

	public static function getBuildTarget() {
		return switch(Sys.systemName()) {
			case 'Windows':
				'windows';
			case 'Mac':
				'macos';
			case 'Linux':
				'linux';
			case def:
				def.toLowerCase();
		}
	}
}