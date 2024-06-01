package fnf.utils;

import fnf.backend.metas.DifficultyMeta;
import fnf.objects.Character;

enum abstract CharDataType(String) {
	var BASE = 'base';
	var PSYCH = 'psych';
	var CNE = 'codename';
	var IMAG = 'imag';
}

class ParseUtil {
	public static function parseYaml(path:String, pathType:FunkinPath = UNI):Dynamic return yaml.Yaml.parse(Paths.getContent(Paths.yaml(path, pathType)), yaml.Parser.options().useObjects());
	public static function parseJson(path:String, pathType:FunkinPath = UNI):Dynamic return haxe.Json.parse(Paths.getContent(Paths.json(path, pathType)));

	// What? We're you expecting it to be complex?
	public static function parseDifficulty(diffName:String, pathType:FunkinPath = UNI):DiffData {
		var yamlData:Dynamic = parseYaml('content/difficulties/$diffName', pathType);
		return yamlData == null ? FailsafeUtil.diffYaml : {
			audioVariant: yamlData.audioVariant,
			scoreMult: yamlData.scoreMult,
			fps: yamlData.fps == null ? 24 : yamlData.fps
		};
	}

	public static function parseCharacter(charName:String, charVariant:String = 'none', pathType:FunkinPath = UNI):CharData {
		var path:String = '';
		var applyFailsafe:Bool = false;

		for (lol in ['yaml', 'json', 'xml']) {
			var funclol:(String, ?FunkinPath)->String = switch (lol) {
				case 'yaml': Paths.yaml;
				case 'json': Paths.json;
				case 'xml': Paths.xml;
				default: (key:String, pathType:FunkinPath = UNI) -> return key;

			};
			if (charVariant == 'none') {
				if (sys.FileSystem.exists(funclol('characters/$charName', pathType))) {
					path = 'characters/$charName';
					break;
				}
			} else {
				if (!sys.FileSystem.exists(funclol('characters/$charName', pathType))) {
					if (sys.FileSystem.exists(funclol('characters/$charName/$charVariant', pathType))) {
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
		if (sys.FileSystem.exists(Paths.json(path, pathType))) charDataType = PSYCH;
		else if (sys.FileSystem.exists(Paths.yaml(path, pathType))) charDataType = IMAG;
		else if (sys.FileSystem.exists(Paths.xml(path, pathType))) charDataType = CNE;

		var theData:CharData = FailsafeUtil.charYaml;
		switch (charDataType) {
			// case BASE:
			case PSYCH:
				var jsonData:Dynamic = parseJson(path);

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
				};

				for (index in 0...jsonData.animations.length) {
					var info:Dynamic = jsonData.animations[index];

					var animName:String = info.anim;
					if (animName.contains('danceLeft')) animName.replace('danceLeft', 'idle');
					if (animName.contains('danceRight')) animName.replace('danceRight', 'sway');
					trace(animName);

					var flipAnim:String = switch (animName) {
						case 'singLEFT': 'singRIGHT'; case 'singRIGHT': 'singLEFT';
						case 'singLEFT-alt': 'singRIGHT-alt'; case 'singRIGHT-alt': 'singLEFT-alt';
						case 'singLEFTmiss': 'singRIGHTmiss'; case 'singRIGHTmiss': 'singLEFTmiss';
						case 'singLEFTmiss-alt': 'singRIGHTmiss-alt'; case 'singRIGHTmiss-alt': 'singLEFTmiss-alt';
						default: '';
					};

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
			case IMAG: theData = parseYaml(path, pathType);
			default: applyFailsafe = true;
		}

		return cast applyFailsafe ? FailsafeUtil.charYaml : Character.applyCharData(theData);
	}
}