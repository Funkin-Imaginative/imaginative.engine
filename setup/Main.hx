package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

typedef Library = {
	var ?global:Bool;
	var name:String;
	var ?version:String;
	var ?url:String;
	var ?branch:String;
	var ?optional:Bool;
	var ?description:String;
}

class Main {
	static var libs:Array<Library> = [];
	static var optionalCheck:Map<String, Bool> = new Map<String, Bool>();
	static var questDesc:Map<String, String> = new Map<String, String>();

	public static function main():Void {
		// arguments
		var args:Array<String> = Sys.args();
		optionalCheck.set('global', false);
		questDesc.set('global', 'install the libraries globally');

		// json parse
		Sys.println('Getting libraries from "setup/libs.json"');
		if (FileSystem.exists('setup/libs.json'))
			libs = Json.parse(File.getContent('setup/libs.json'));
		else {
			Sys.println('The libraries json doesn\'t exist!\nPlease make one in the setup folder.\nHere\'s an example of one.\n${Json.stringify([
				{
					global: false,
					name: 'hscript-improved',
					version: 'git',
					url: 'https://github.com/FNF-CNE-Devs/hscript-improved',
					branch: 'custom-classes',
					optional: true,
					description: 'include haxe scripting support'
				}
			], '\t')}');
			return;
		}

		for (lib in libs)
			if (ifNull(lib.optional, false)) {
				optionalCheck.set(lib.name, false);
				questDesc.set(
					lib.name,
					ifNull(lib.description, 'install ${lib.name}')
				);
			}

		Sys.println('-------------------------------------------------------');

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
					if (Sys.stdin().readLine().toLowerCase() == 'y')
						optionalCheck.set(tag, true);
				}
		}

		if (!FileSystem.exists('.haxelib'))
			if (!args.contains('--global'))
				if (!optionalCheck.get('global'))
					FileSystem.createDirectory('.haxelib');

		Sys.println('-------------------------------------------------------');

		for (lib in libs) {
			if (ifNull(lib.optional, false))
				continue;

			var isGlobal:Bool = args.contains('--global') || optionalCheck.get('global') || lib.global;
			if (lib.version == 'git') {
				var repo:Array<String> = lib.url.split('/');
				Sys.println('${isGlobal ? 'Globally' : 'Locally'} installing "${lib.name}" from git repo "${repo[repo.length - 2]}/${repo[repo.length - 1]}".');
				Sys.command('haxelib git ${lib.name} ${ifNull(lib.url, '')} ${ifNull(lib.branch, '')} ${isGlobal ? '--global ' : ''} --always');
			} else {
				Sys.println('${isGlobal ? 'Globally' : 'Locally'} installing "${lib.name}".');
				Sys.command('haxelib install ${lib.name} ${ifNull(lib.version, '')} ${isGlobal ? '--global ' : ''} --always');
			}
			Sys.println('-------------------------------------------------------');
		}

		var proc:Process = new Process('haxe --version');
		proc.exitCode(true);
		var haxeVer:String = proc.stdout.readLine();
		if (haxeVer != '4.3.6') {
			// check for outdated haxe
			var curHaxeVer:Array<Int> = [
				for (v in haxeVer.split('.'))
					Std.parseInt(v)
			];
			var requiredHaxeVer:Array<Int> = [4, 3, 6];
			for (i in 0...requiredHaxeVer.length) {
				if (curHaxeVer[i] < requiredHaxeVer[i]) {
					Sys.println('Your current Haxe version is outdated.');
					Sys.println('You\'re using ${haxeVer}, while the required version is 4.3.6.');
					Sys.println('The engine may or may not compile with your current version of Haxe.');
					Sys.println('We recommend upgrading to 4.3.6!');
					break;
				}
			}
		}

		// This part here was taken from Codename Engine's commandline stuff.
		if (getBuildTarget().toLowerCase() == 'windows' && new Process('"C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe" -property catalog_productDisplayVersion').exitCode(true) == 1) {
			Sys.println('-------------------------------------------------------');
			Sys.println('Installing Microsoft Visual Studio Community (Dependency)');

			Sys.command('curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe');
			Sys.command('vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p');

			FileSystem.deleteFile('vs_Community.exe');
			Sys.println('If it didn\'t say it before: Because of this component if you want to compile you have to restart the device.');
			Sys.println('-------------------------------------------------------');
			Sys.println('Do you wish to do it now? [y/n]');
			if (Sys.stdin().readLine().toLowerCase() == 'y') Sys.command('shutdown /r /t 0 /f');
		}
	}

	static function getBuildTarget() {
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

	static function ifNull<T>(input:Null<T>, def:T):Dynamic
		return input == null ? def : input;
}