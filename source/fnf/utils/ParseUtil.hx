package fnf.utils;

import fnf.objects.Character;
import yaml.*;

enum abstract CharDataType(String) from String to String {
	var BASE = 'Funkin';
	var PSYCH = 'Psych';
	var CNE = 'Codename';
	var IMAG = 'Imaginative';
}

class ParseUtil {
	inline public static function yaml(path:String, ?pathType:FunkinPath):Dynamic return Yaml.parse(Paths.getContent(Paths.yaml(path, pathType)), Parser.options().useObjects());
	inline public static function json(path:String, ?pathType:FunkinPath):Dynamic return haxe.Json.parse(Paths.getContent(Paths.json(path, pathType)));

	// What? We're you expecting it to be complex?
	public static function difficulty(diffName:String, ?pathType:FunkinPath):DifficultyMeta.DiffData {
		var diffData:Dynamic = yaml('content/difficulties/$diffName', pathType);
		return cast diffData == null ? FailsafeUtil.diffYaml : {
			audioVariant: diffData.audioVariant,
			scoreMult: diffData.scoreMult,
			fps: diffData.fps == null ? 24.0 : diffData.fps
		}
	}

	inline public static function level(fileName:String, ?pathType:FunkinPath):fnf.states.menus.StoryMenuState.LevelData {
		var levelInfo:Dynamic = yaml('levels/$fileName', pathType);
		return cast levelInfo == null ? FailsafeUtil.levelYaml : {
			name: fileName,
			title: levelInfo.title,
			songs: levelInfo.songs,
			diffs: levelInfo.difficulties,
			chars: levelInfo.characters,
			color: FlxColor.fromString(levelInfo.color)
		}
	}
	inline public static function song(songName:String, ?pathType:FunkinPath):fnf.states.menus.FreeplayState.SongData {
		var songInfo:Dynamic = yaml('songs/$songName/SongMetaData', pathType);
		return cast songInfo == null ? FailsafeUtil.songMetaYaml : {
			name: songInfo.display,
			icon: songInfo.icon,
			color: FlxColor.fromString(songInfo.color),
			diffs: songInfo.difficulties,
			measure: songInfo.measure
		}
	}

	inline public static function icon(iconName:String, ?pathType:FunkinPath):fnf.ui.HealthIcon.IconData {
		var iconData:Dynamic = yaml('images/icons/$iconName', pathType);
		return cast iconData == null ? FailsafeUtil.iconYaml : {
			dimensions: iconData.dimensions,
			scale: iconData.scale,
			flip: iconData.flip,
			aliasing: iconData.aliasing,
			anims: iconData.anims,
			frames: iconData.frames
		}
	}

	inline public static function character(charName:String, charVariant:String = 'none'):CharData {
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
					position: {
						x: jsonData.position[0] * (jsonData._editor_isPlayer ? -1 : 1),
						y: jsonData.position[1]
					},
					camera: {
						x: jsonData.camera_position[0] /* + (jsonData._editor_isPlayer ? -100 : 150) */,
						y: jsonData.camera_position[1] /* - 100 */
					},

					scale: jsonData.scale,
					singLen: jsonData.sing_duration,
					icon: iconSplit.join('-'),
					aliasing: !jsonData.no_antialiasing,
					color: FlxColor.fromRGB(jsonData.healthbar_colors[0], jsonData.healthbar_colors[1], jsonData.healthbar_colors[2]).toWebString(),
					beat: 0
				}

				for (index in 0...jsonData.animations.length) {
					var info:Dynamic = jsonData.animations[index];

					var animName:String = info.anim;
					animName = animName.replace('danceLeft', 'idle');
					animName = animName.replace('danceRight', 'sway');

					var swapAnim:String = switch (animName) {
						case 'singLEFT': 'singRIGHT'; case 'singRIGHT': 'singLEFT';
						case 'singLEFT-alt': 'singRIGHT-alt'; case 'singRIGHT-alt': 'singLEFT-alt';
						case 'singLEFTmiss': 'singRIGHTmiss'; case 'singRIGHTmiss': 'singLEFTmiss';
						case 'singLEFTmiss-alt': 'singRIGHTmiss-alt'; case 'singRIGHTmiss-alt': 'singLEFTmiss-alt';
						case 'singLEFT-loop': 'singRIGHT-loop'; case 'singRIGHT-loop': 'singLEFT-loop';
						case 'singLEFT-alt-loop': 'singRIGHT-alt-loop'; case 'singRIGHT-alt-loop': 'singLEFT-alt-loop';
						default: '';
					}

					theData.anims.insert(index, {
						name: animName,
						swapAnim: swapAnim,
						flipAnim: '',
						tag: info.name,
						fps: info.fps,
						loop: info.loop,
						offset: {
							x: info.offsets[0] * (jsonData._editor_isPlayer ? -1 : 1),
							y: info.offsets[1]
						},
						indices: info.indices,
						flip: false
					});
				}
			// case CNE:
			case IMAG: theData = yaml(path);
			default: applyFailsafe = true;
		}

		theData.isFromEngine = charDataType;

		return cast applyFailsafe ? FailsafeUtil.charYaml : {
			name: theData.name,
			sprite: theData.sprite,
			flip: theData.flip,
			anims: theData.anims,
			position: theData.position,
			camera: theData.camera,

			scale: theData.scale,
			singLen: theData.singLen,
			icon: theData.icon,
			aliasing: theData.aliasing,
			color: theData.color,
			beat: theData.beat,

			isFromEngine: theData.isFromEngine
		}
	}
}