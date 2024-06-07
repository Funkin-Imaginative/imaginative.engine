package fnf.utils;

import fnf.objects.Character;
import yaml.*;

enum abstract CharDataType(String) {
	var BASE = 'base';
	var PSYCH = 'psych';
	var CNE = 'codename';
	var IMAG = 'imag';
}

class ParseUtil {
	public static function yaml(path:String, ?pathType:FunkinPath):Dynamic return Yaml.parse(Paths.getContent(Paths.yaml(path, pathType)), Parser.options().useObjects());
	public static function json(path:String, ?pathType:FunkinPath):Dynamic return haxe.Json.parse(Paths.getContent(Paths.json(path, pathType)));

	// What? We're you expecting it to be complex?
	public static function difficulty(diffName:String, ?pathType:FunkinPath):DifficultyMeta.DiffData {
		var yamlData:Dynamic = yaml('content/difficulties/$diffName', pathType);
		return cast yamlData == null ? FailsafeUtil.diffYaml : {
			audioVariant: yamlData.audioVariant,
			scoreMult: yamlData.scoreMult,
			fps: yamlData.fps == null ? 24.0 : yamlData.fps
		}
	}

	public static function level(fileName:String, ?pathType:FunkinPath):fnf.states.menus.StoryMenuState.LevelData {
		var levelInfo = yaml('levels/$fileName', pathType);
		return cast levelInfo == null ? FailsafeUtil.levelYaml : {
			name: fileName,
			title: levelInfo.title,
			songs: levelInfo.songs,
			diffs: levelInfo.difficulties,
			chars: levelInfo.characters,
			color: FlxColor.fromString(levelInfo.color)
		}
	}
	public static function song(songName:String, ?pathType:FunkinPath):fnf.states.menus.FreeplayState.SongData {
		var songInfo = yaml('songs/$songName/SongMetaData', pathType);
		return cast songInfo == null ? FailsafeUtil.songMetaYaml : {
			name: songInfo.display,
			icon: songInfo.icon,
			color: FlxColor.fromString(songInfo.color),
			diffs: songInfo.difficulties,
			measure: songInfo.measure
		}
	}

	public static function character(charName:String, charVariant:String = 'none'):CharData {
		var path:String = '';
		var applyFailsafe:Bool = false;

		for (lol in ['yaml', 'json', 'xml']) {
			var funclol:(String, ?FunkinPath)->String = switch (lol) {
				case 'yaml': Paths.yaml;
				case 'json': Paths.json;
				case 'xml': Paths.xml;
				default: (file:String, ?pathType:FunkinPath) -> return file;

			}
			if (charVariant == 'none') {
				if (FileSystem.exists(funclol('characters/$charName'))) {
					path = 'characters/$charName';
					break;
				}
			} else {
				if (!FileSystem.exists(funclol('characters/$charName'))) {
					if (FileSystem.exists(funclol('characters/$charName/$charVariant'))) {
						path = 'characters/$charName/$charVariant';
						break;
					}
				} else {
					path = 'characters/$charName';
					break;
				}
			}
		}

		var charDataType:CharDataType = null;
		if (FileSystem.exists(Paths.json(path))) charDataType = PSYCH;
		else if (FileSystem.exists(Paths.yaml(path))) charDataType = IMAG;
		else if (FileSystem.exists(Paths.xml(path))) charDataType = CNE;

		var theData:CharData = FailsafeUtil.charYaml;
		switch (charDataType) {
			// case BASE:
			case PSYCH:
				var jsonData:Dynamic = json(path);

				var sprite:String = jsonData.image;
				var pathSplit:Array<String> = sprite.split('/');
				if (pathSplit[0] == 'characters') pathSplit.remove('characters');

				var icon:String = jsonData.healthicon;
				var iconSplit:Array<String> = icon.split('-');
				if (iconSplit[0] == 'icon') iconSplit.remove('icon');

				theData = {
					sprite: pathSplit.join('/'),
					flip: jsonData.flip_x,
					anims: [],
					position: {x: jsonData.position[0], y: jsonData.position[1]},
					camera: {x: jsonData.camera_position[0], y: jsonData.camera_position[1]},

					scale: jsonData.scale,
					singLen: jsonData.sing_duration,
					icon: iconSplit.join('-'),
					aliasing: !jsonData.no_antialiasing,
					color: FlxColor.fromRGB(jsonData.healthbar_colors[0], jsonData.healthbar_colors[1], jsonData.healthbar_colors[2]).toHexString(false, false),
					beat: 0
				}

				for (index in 0...jsonData.animations.length) {
					var info:Dynamic = jsonData.animations[index];

					var animName:String = info.anim;
					animName = animName.replace('danceLeft', 'idle');
					animName = animName.replace('danceRight', 'sway');

					var flipAnim:String = switch (animName) {
						case 'singLEFT': 'singRIGHT'; case 'singRIGHT': 'singLEFT';
						case 'singLEFT-alt': 'singRIGHT-alt'; case 'singRIGHT-alt': 'singLEFT-alt';
						case 'singLEFTmiss': 'singRIGHTmiss'; case 'singRIGHTmiss': 'singLEFTmiss';
						case 'singLEFTmiss-alt': 'singRIGHTmiss-alt'; case 'singRIGHTmiss-alt': 'singLEFTmiss-alt';
						default: '';
					}

					theData.anims.insert(index, {
						name: animName,
						flipAnim: flipAnim,
						tag: info.name,
						fps: info.fps,
						loop: info.loop,
						offset: {x: info.offsets[0], y: info.offsets[1]},
						indices: info.indices,
						flip: false
					});
				}
			// case CNE:
			case IMAG: theData = yaml(path);
			default: applyFailsafe = true;
		}

		return cast applyFailsafe ? FailsafeUtil.charYaml : Character.applyCharData(theData);
	}
}