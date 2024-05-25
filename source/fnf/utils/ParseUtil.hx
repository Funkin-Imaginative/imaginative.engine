package fnf.utils;

import fnf.objects.Character;

enum abstract CharDataType(String) {
	var BASE = 'base';
	var PSYCH = 'psych';
	var CNE = 'codename';
	var IMAG = 'imag';
}

class ParseUtil {
	public static function parseYaml(path:String):Dynamic return yaml.Yaml.parse(Paths.getContent(Paths.yaml(path)), yaml.Parser.options().useObjects());
	public static function parseJson(path:String):Dynamic return haxe.Json.parse(Paths.getContent(Paths.json(path)));

	public static function parseCharacter(charName:String, charVariant:String = 'none'):CharData {
		var path:String = '';
		var applyFailsafe:Bool = false;

		for (lol in ['yaml', 'json', 'xml']) {
			var funclol:(String, ?Null<String>)->String = switch (lol) {
				case 'yaml': Paths.yaml;
				case 'json': Paths.json;
				case 'xml': Paths.xml;
				default: (key:String, ?lib:Null<String>) -> return key;

			};
			if (!sys.FileSystem.exists(funclol('characters/$charName'))) {
				if (sys.FileSystem.exists(funclol('characters/$charName/$charVariant'))) {
					path = 'characters/$charName/$charVariant';
					break;
				} else applyFailsafe = true;
			}
			else {
				path = 'characters/$charName';
				break;
			}
		}

		#if debug trace(path); #end
		var charDataType:CharDataType = null;
		if (sys.FileSystem.exists(Paths.json(path))) charDataType = PSYCH;
		else if (sys.FileSystem.exists(Paths.yaml(path))) charDataType = IMAG;
		else if (sys.FileSystem.exists(Paths.xml(path))) charDataType = CNE;
		#if debug trace(charDataType); #end

		var theData:CharData = FailsafeUtil.charYaml;
		switch (charDataType) {
			// case BASE:
			case PSYCH:
				var jsonData:Dynamic = parseJson(path);
				var sprite:String = jsonData.image;
				var icon:String = jsonData.healthicon;
				theData = {
					sprite: sprite.replace('characters/', ''),
					flip: jsonData.flip_x,
					anims: [],
					position: {x: jsonData.position[0], y: jsonData.position[1]},
					camera: {x: jsonData.camera_position[0], y: jsonData.camera_position[1]},

					scale: jsonData.scale,
					singLen: jsonData.sing_duration,
					icon: icon.replace('icon-', ''),
					aliasing: !jsonData.no_antialiasing,
					color: FlxColor.fromRGB(jsonData.healthbar_colors[0], jsonData.healthbar_colors[1], jsonData.healthbar_colors[2]).toHexString(false, false),
					beat: 0
				};

				for (index in 0...jsonData.animations.length) {
					var info:Dynamic = jsonData.animations[index];
					theData.anims.insert(index, {
						name: info.anim,
						tag: info.name,
						fps: info.fps,
						loop: info.loop,
						offset: {x: info.offsets[0], y: info.offsets[1]},
						indices: info.indices,
						flip: false
					});
				}

				theData = jsonData;
			// case CNE:
			case IMAG: theData = parseYaml(path);
			default: applyFailsafe = true;
		}

		return cast applyFailsafe ? FailsafeUtil.charYaml : Character.applyCharData(theData);
	}
}