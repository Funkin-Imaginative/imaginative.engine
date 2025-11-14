package setup;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

typedef SetupJson = {
	var dependencies:Array<Library>;
	var ?questions:Array<Question>;
}

typedef Library = {
	var ?global:Bool;
	var name:String;
	var ?version:String;
	var ?branch:String;
	var ?url:String;
	var ?dependencies:Array<Library>;
}

typedef Question = {
	var name:String;
	var ?description:String;
}

class Setup {
	static var data:SetupJson;
	static var optionalCheck:Map<String, Bool> = new Map<String, Bool>();
	static var questDesc:Map<String, String> = new Map<String, String>();

	public static function run(ranArgs:Array<String>):Void {
		// arguments
		var args:Array<String> = ranArgs;
		optionalCheck.set('global', args.contains('--global'));
		questDesc.set('global', 'install the libraries globally');

		// json parse
		Sys.println('Getting libraries from "commands/setup/data.json"');
		if (FileSystem.exists('./commands/setup/data.json')) {
			data = Json.parse(File.getContent('./commands/setup/data.json'));
		} else {
			var exampleJson:SetupJson = {
				dependencies: [
					{name: 'thx.semver'},
					{
						global: false,
						name: 'hscript-improved',
						version: 'git',
						url: 'https://github.com/CodenameCrew/hscript-improved',
						branch: 'custom-classes'
					}
				],
				questions: [
					{
						name: 'hscript-improved',
						description: 'include haxe scripting support'
					}
				]
			}
			// was hating github not properly coloring the rest of this file.
			Sys.println('The libraries json doesn\'t exist!\nPlease make one in the setup folder.\nHere\'s an example of one.\n${Json.stringify(exampleJson, '\t')}');
			return;
		}

		for (lib in data.dependencies) {
			var questions:Map<String, Question> = new Map<String, Question>();

			for (question in data.questions)
				questions.set(question.name, question);

			if (questions.exists(lib.name)) {
				var question:Question = questions.get(lib.name);
				optionalCheck.set(lib.name, false);
				questDesc.set(
					lib.name,
					question.description ??= 'install ${lib.name}'
				);
			}
		}

		Sys.println(Main.dashes);

		if (args.contains('--always')) { // When "--always" is used, it installs all the libs.
			Sys.println('Skipping questions.');
			for (tag => value in optionalCheck)
				if (tag != 'global')
					optionalCheck.set(tag, true);
		} else {
			Sys.println('Please answer carefully.');
			for (tag => value in optionalCheck)
				if (!optionalCheck.get(tag)) {
					Sys.println('Do you wish to ${questDesc.exists(tag) ? questDesc.get(tag) : 'install $tag'}? [y/n]');
					if (Sys.stdin().readLine().toLowerCase().trim() == 'y')
						optionalCheck.set(tag, true);
				}
		}

		if (!FileSystem.exists('./.haxelib'))
			if (!optionalCheck.get('global'))
				FileSystem.createDirectory('./.haxelib');

		Sys.println(Main.dashes);

		Sys.command('haxelib install haxelib --global');
		Sys.command('haxelib fixrepo');
		dependenciesCheck(data.dependencies);
		File.saveContent('./commands/setup/history.txt', libHistory.join('\n'));

		var proc:Process = new Process('haxe --version');
		proc.exitCode(true);
		var haxeVer:String = proc.stdout.readLine().toLowerCase().trim();
		if (haxeVer != '4.3.7') {
			// check for outdated haxe
			var curHaxeVer:Array<Int> = [
				for (v in haxeVer.split('.'))
					Std.parseInt(v)
			];
			var requiredHaxeVer:Array<Int> = [4, 3, 6];
			for (i in 0...requiredHaxeVer.length) {
				if (curHaxeVer[i] < requiredHaxeVer[i]) {
					Sys.println('Your current Haxe version is outdated.');
					Sys.println('You\'re using $haxeVer, while the required version is 4.3.7.');
					Sys.println('The engine may or may not compile with your current version of Haxe.');
					Sys.println('We recommend upgrading to 4.3.7!');
					break;
				}
			}
		}

		// This part here was taken from Codename Engine's commandline stuff.
		if (getBuildTarget().toLowerCase() == 'windows' && new Process('"C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe" -property catalog_productDisplayVersion').exitCode(true) == 1) {
			Sys.println(Main.dashes);
			Sys.println('Installing Microsoft Visual Studio Community (Dependency)');

			Sys.command('curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe');
			Sys.command('vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p');

			FileSystem.deleteFile('vs_Community.exe');
			Sys.println('If it didn\'t say it before: Because of this component if you want to compile you have to restart the device.');
			Sys.println(Main.dashes);
			Sys.println('Do you wish to do it now? [y/n]');
			if (Sys.stdin().readLine().toLowerCase().trim() == 'y') Sys.command('shutdown /r /t 0 /f');
		}
	}

	static var libHistory:Array<String> = [];
	static function dependenciesCheck(dependencies:Array<Library>, doneAgain:Bool = false):Void {
		for (lib in dependencies) {
			if (optionalCheck.exists(lib.name) && !optionalCheck.get(lib.name))
				continue;
			else if (!optionalCheck.exists(lib.name)) {}

			var isGlobal:Bool = optionalCheck.get('global') || (lib.global ??= false);
			if (lib.version == 'git') {
				var repo:Array<String> = lib.url.split('/');
				Sys.println('${isGlobal ? 'Globally' : 'Locally'} installing "${lib.name}" from git repo "${repo[repo.length - 2]}/${repo[repo.length - 1]}".');
				var command = 'haxelib git ${lib.name} ${lib.url ?? ''} ${lib.branch ?? ''} ${lib.dependencies == null ? '' : '--skip-dependencies'} ${isGlobal ? '--global ' : ''}';
				command = command.split(' ').filter((string:String) -> return string.trim().length != 0).join(' ');
				Sys.command('$command --always');
				libHistory.push(command);
			} else {
				Sys.println('${isGlobal ? 'Globally' : 'Locally'} installing "${lib.name}".');
				var command = 'haxelib install ${lib.name} ${lib.version ?? ''} ${lib.dependencies == null ? '' : '--skip-dependencies'} ${isGlobal ? '--global ' : ''}';
				command = command.split(' ').filter((string:String) -> return string.trim().length != 0).join(' ');
				Sys.command('$command --always');
				libHistory.push(command); // TODO: Figure out how to get lib version when none specified.
			}
			if (lib.dependencies != null)
				dependenciesCheck(lib.dependencies, true);
			if (!doneAgain)
				Sys.println(Main.dashes);
		}
	}

	static function getBuildTarget():String {
		return switch (Sys.systemName()) {
			case 'Windows':
				'windows';
			case 'Mac':
				'macos';
			case 'Linux':
				'linux';
			default:
				Sys.systemName().toLowerCase().trim();
		}
	}
}