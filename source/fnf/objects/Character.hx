package fnf.objects;

import flixel.util.FlxStringUtil;
import yaml.Parser;
import yaml.Yaml;

typedef AnimSuffixes = { // will still work even if alt isn't found
	@:default('') var idle:String; // for idle/sway
	@:default('') var sing:String; // for sing anims (global version)
	@:default('') var anim:String; // for any anim
}

enum abstract SpriteFacing(String) {
	var leftFace = 'left';
	var rightFace = 'right';
}

private typedef XY = {
	var x:Float;
	var y:Float;
}

private typedef AnimHas = {
	var suffix:Bool;
	var miss:Bool;
}
private typedef AnimCheck = {
	var suffix:String;
	var miss:String;
}

typedef AnimList = {
	var name:String;
	var tag:String;
	var fps:Float;
	var loop:Bool;
	var offset:XY;
	var indices:Array<Int>;
}

typedef CharYaml = {
	var aliasing:Bool;
	var anims:Array<AnimList>;
	var camera:XY;
	var color:String;
	var flip:Bool;
	var icon:String;
	var position:XY;
	var scale:Float;
	var singLen:Float;
	var sprite:String;
}

class Character extends FlxSprite {
	public var debugMode:Bool = false; // for editors

	public var animOffsets:Map<String, FlxPoint> = new Map<String, FlxPoint>(); // the offsets

	// internal set to prevent issues
	var __name:String = 'boyfriend';
	var __variant:String = 'normal';
	// vars to actually use
	@:isVar public var charName(get, never):String;
	@:isVar public var charVariant(get, never):String;
	private function get_charName():String return __name;
	private function get_charVariant():String return __variant;
	public var hasVariant(get, never):Bool;
	private function get_hasVariant():Bool return charVariant != 'none';

	// quick way to set which direction the character is facing
	@:isVar public var isFacing(get, set):SpriteFacing = rightFace;
	private function set_isFacing(value:SpriteFacing):SpriteFacing {
		flipX = value == leftFace;
		return isFacing = value;
	}
	private function get_isFacing():SpriteFacing return flipX ? rightFace : leftFace;

	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	public var stunned:Bool = false;

	public var bopSpeed(default, set):Int = 1;
	private function set_bopSpeed(value:Int):Int return bopSpeed = bopSpeed < 1 ? 1 : value;
	public var beatInterval(get, default):Int = 0;
	private function get_beatInterval():Int return beatInterval < 1 ? (hasSway ? 1 : 2) : beatInterval;
	public var singLength:Float = 4; // Multiplier of how long a character holds the sing pose.
	public var suffixes:AnimSuffixes = {idle: '', sing: '', anim: ''}; // even tho @:default is used it didn't actually work lol
	public var preventIdle:Bool = false;
	public var hasSway(get, never):Bool; // Replaces 'danceLeft' with 'idle' and 'danceRight' with 'sway'.
	private function get_hasSway():Bool return suffixes.idle.trim() == '' ? animOffsets.exists('sway') : animOffsets.exists('sway${suffixes.idle}');

	public var xyOffset(default, never):FlxPoint = new FlxPoint();
	public var camPoint(default, never):BareCameraPoint = new BareCameraPoint();
	public function getCamPos():FlxPoint {
		var basePos:FlxPoint = getMidpoint();
		basePos.x += (xyOffset.x + camPoint.x) * (isFacing == rightFace ? 1 : -1);
		basePos.y += xyOffset.y + camPoint.y;
		scripts.call('getCameraPos', [basePos]);
		return basePos;
	}

	public var icon:String = 'face';

	public var animationNotes:Array<Dynamic> = [];

	public var spritePath:String = '';
	public var scaleMult:Float = 1;
	public var aliasing:Bool = true;
	public var flipSprite:Bool = false;
	public var iconColor(get, default):Null<FlxColor>;
	private function get_iconColor():FlxColor return iconColor == null ? 0xa1a1a1 : iconColor;

	public var yamlData:CharYaml;
	public static function applyCharYaml(yamlContent:Dynamic):CharYaml
		return {
			sprite: yamlContent.sprite,
			flip: yamlContent.flip,
			anims: yamlContent.anims,
			position: yamlContent.position,
			camera: yamlContent.camera,

			scale: yamlContent.scale,
			singLen: yamlContent.singLen,
			icon: yamlContent.icon,
			aliasing: yamlContent.aliasing,
			color: yamlContent.color
		};

	public var scripts:ScriptGroup; // just for effecting both scripts at once lmao
	public var charScript:Script;
	public var variantScript:Script;

	public function new(x:Float, y:Float, faceLeft:Bool = false, character:String = 'making these whatever to force failsafe', variant:String = 'Peanut Butter & (Blue) Cheese') {
		__name = character;
		__variant = variant;
		isFacing = faceLeft ? leftFace : rightFace;

		super(x, y);

		scripts = new ScriptGroup(this);
		charScript = Script.create(charName, 'char');
		if (hasVariant) variantScript = Script.create('$charName/$charVariant', 'char');
		for (script in [charScript, variantScript]) {
			if (script == null) script = new Script(FailsafeUtil.invaildScriptKey);
			scripts.add(script);
		}
		scripts.load(true);
		scripts.call('create');

		switch (charName) {
			case 'gf':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'GF_assets'}');

				animation.addByIndices('idle', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('sway', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('cheer', 'GF Cheer');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], '', 24, true);
				animation.addByIndices('hairBlow', 'GF Dancing Beat Hair blowing', [0, 1, 2, 3], '', 24);
				animation.addByIndices('hairFall', 'GF Dancing Beat Hair Landing', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], '', 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);

				loadOffsetFile(charName);

			case 'gf-christmas':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'gfChristmas'}');

				animation.addByIndices('idle', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('sway', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				quickAnimAdd('cheer', 'GF Cheer');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], '', 24, false);
				// animation.addByIndices('hairBlow', 'GF Dancing Beat Hair blowing', [0, 1, 2, 3], '', 24);
				// animation.addByIndices('hairFall', 'GF Dancing Beat Hair Landing', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], '', 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);

				loadOffsetFile(charName);

			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'gfTankmen'}');

				animation.addByIndices('idle', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('sway', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
				animation.addByIndices('sad', 'GF Crying at Gunpoint', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], '', 24, true);

				loadOffsetFile('gf');

			case 'bf-holding-gf':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'bfAndGF'}');

				flipSprite = true;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('bfCatch', 'BF catches GF');

				loadOffsetFile(charName);

			case 'gf-car':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'gfCar'}');

				animation.addByIndices('idle', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('sway', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
				animation.addByIndices('idle-loop', 'GF Dancing Beat Hair blowing CAR', [10, 11, 12, 25, 26, 27], '', 24, true);
				animation.addByIndices('sway-loop', 'GF Dancing Beat Hair blowing CAR', [10, 11, 12, 25, 26, 27], '', 24, true);
				// animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], '', 24, false);

				loadOffsetFile(charName);

			case 'gf-pixel':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'gfPixel'}');

				animation.addByIndices('idle', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('sway', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
				// animation.addByIndices('singUP', 'GF IDLE', [2], '', 24, false);

				loadOffsetFile(charName);

				scaleMult = 6;
				aliasing = false;

			case 'dad':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'DADDY_DEAREST'}');

				quickAnimAdd('idle', 'Dad idle dance');
				quickAnimAdd('singLEFT', 'Dad Sing Note LEFT');
				quickAnimAdd('singDOWN', 'Dad Sing Note DOWN');
				quickAnimAdd('singUP', 'Dad Sing Note UP');
				quickAnimAdd('singRIGHT', 'Dad Sing Note RIGHT');

				loadOffsetFile(charName);

			case 'spooky':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'spooky_kids_assets'}');

				animation.addByIndices('idle', 'spooky dance idle', [0, 2, 6], '', 12, false);
				animation.addByIndices('sway', 'spooky dance idle', [8, 10, 12, 14], '', 12, false);
				quickAnimAdd('singLEFT', 'note sing left');
				quickAnimAdd('singDOWN', 'spooky DOWN note');
				quickAnimAdd('singUP', 'spooky UP NOTE');
				quickAnimAdd('singRIGHT', 'spooky sing right');

				loadOffsetFile(charName);

			case 'mom':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'Mom_Assets'}');

				quickAnimAdd('idle', 'Mom Idle');
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				quickAnimAdd('singDOWN', 'MOM DOWN POSE');
				quickAnimAdd('singUP', 'Mom Up Pose');
				/**
				 * ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				 * CUZ DAVE IS DUMB!
				 */
				quickAnimAdd('singRIGHT', 'Mom Pose Left');

				loadOffsetFile(charName);

			case 'mom-car':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'momCar'}');

				quickAnimAdd('idle', 'Mom Idle');
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				quickAnimAdd('singDOWN', 'MOM DOWN POSE');
				quickAnimAdd('singUP', 'Mom Up Pose');
				/**
				 * ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				 * CUZ DAVE IS DUMB!
				 */
				quickAnimAdd('singRIGHT', 'Mom Pose Left');
				animation.addByIndices('idle-loop', 'Mom Idle', [10, 11, 12, 13], '', 24, true);

				loadOffsetFile(charName);

			case 'monster':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'Monster_Assets'}');

				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singRIGHT', 'Monster Right note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singLEFT', 'Monster left note');

				loadOffsetFile(charName);

			case 'monster-christmas':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'monsterChristmas'}');

				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singRIGHT', 'Monster Right note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singLEFT', 'Monster left note');

				loadOffsetFile(charName);

			case 'pico':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'Pico_FNF_assetss'}');

				final LEFT:String = faceLeft ? 'LEFT' : 'RIGHT';
				final RIGHT:String = faceLeft ? 'RIGHT' : 'LEFT';

				flipSprite = true;
				quickAnimAdd('idle', 'Pico Idle Dance');
				quickAnimAdd('sing$LEFT', 'Pico NOTE LEFT0');
				quickAnimAdd('singDOWN', 'Pico Down Note0');
				quickAnimAdd('singUP', 'pico Up note0');
				quickAnimAdd('sing$RIGHT', 'Pico Note Right0');
				quickAnimAdd('sing${LEFT}miss', 'Pico NOTE LEFT miss');
				quickAnimAdd('singDOWNmiss', 'Pico Down Note MISS');
				quickAnimAdd('singUPmiss', 'pico Up note miss');
				quickAnimAdd('sing${RIGHT}miss', 'Pico Note Right Miss');

				// Need to be flipped! REDO THIS LATER!
				loadOffsetFile(charName);

			case 'pico-speaker':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'picoSpeaker'}');

				quickAnimAdd('shoot1', 'Pico shoot 1');
				quickAnimAdd('shoot2', 'Pico shoot 2');
				quickAnimAdd('shoot3', 'Pico shoot 3');
				quickAnimAdd('shoot4', 'Pico shoot 4');

				// here for now, will be replaced later for less copypaste
				loadOffsetFile(charName);
				playAnim('shoot1', true);

				loadMappedAnims();

			case 'bf':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'BOYFRIEND'}');

				flipSprite = true;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('hey', 'BF HEY');
				animation.addByPrefix('scared', 'BF idle shaking', 24, true, flipSprite);

				quickAnimAdd('firstDeath', 'BF dies');
				animation.addByPrefix('deathLoop', 'BF Dead Loop', 24, false, flipSprite);
				quickAnimAdd('deathConfirm', 'BF Dead confirm');

				loadOffsetFile(charName);

			case 'bf-christmas':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'bfChristmas'}');

				flipSprite = true;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('hey', 'BF HEY');

				loadOffsetFile(charName);

			case 'bf-car':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'bfCar'}');

				flipSprite = true;
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				animation.addByIndices('idle-loop', 'BF idle dance', [10, 11, 12, 13], '', 24, true, flipSprite);

				loadOffsetFile(charName);

			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'bfPixel'}');

				flipSprite = true;
				quickAnimAdd('idle', 'BF IDLE');
				quickAnimAdd('singLEFT', 'BF LEFT NOTE');
				quickAnimAdd('singDOWN', 'BF DOWN NOTE');
				quickAnimAdd('singUP', 'BF UP NOTE');
				quickAnimAdd('singRIGHT', 'BF RIGHT NOTE');
				quickAnimAdd('singLEFTmiss', 'BF LEFT MISS');
				quickAnimAdd('singDOWNmiss', 'BF DOWN MISS');
				quickAnimAdd('singUPmiss', 'BF UP MISS');
				quickAnimAdd('singRIGHTmiss', 'BF RIGHT MISS');

				loadOffsetFile(charName);

				scaleMult = 6;
				aliasing = false;

			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'bfPixelsDEAD'}');

				flipSprite = true;
				quickAnimAdd('firstDeath', 'BF Dies pixel');
				animation.addByPrefix('deathLoop', 'Retry Loop', 24, false, flipSprite);
				quickAnimAdd('deathConfirm', 'RETRY CONFIRM');
				// quickAnimAdd('singUP', 'BF Dies pixel');

				loadOffsetFile(charName);

				scaleMult = 6;
				aliasing = false;

			case 'bf-holding-gf-dead':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'bfHoldingGF-DEAD'}');

				flipSprite = true;
				quickAnimAdd('firstDeath', 'BF Dies with GF');
				animation.addByPrefix('deathLoop', 'BF Dead with GF Loop', 24, false, flipSprite);
				quickAnimAdd('deathConfirm', 'RETRY confirm holding gf');
				// quickAnimAdd('singUP', 'BF Dead with GF Loop');

				loadOffsetFile(charName);


			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'senpai'}');

				// at framerate 16.8 animation plays over 2 beats at 144bpm,
				// but if the game lags or the bpm is > 144 (mods etc.)
				// he may miss his next dance
				// animation.getByName('idle').frameRate = 16.8;
				quickAnimAdd('idle', 'Senpai Idle');
				quickAnimAdd('singLEFT', 'SENPAI LEFT NOTE');
				quickAnimAdd('singDOWN', 'SENPAI DOWN NOTE');
				quickAnimAdd('singUP', 'SENPAI UP NOTE');
				quickAnimAdd('singRIGHT', 'SENPAI RIGHT NOTE');

				loadOffsetFile(charName);

				scaleMult = 6;
				aliasing = false;

			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'senpai'}');

				quickAnimAdd('idle', 'Angry Senpai Idle');
				quickAnimAdd('singLEFT', 'Angry Senpai LEFT NOTE');
				quickAnimAdd('singDOWN', 'Angry Senpai DOWN NOTE');
				quickAnimAdd('singUP', 'Angry Senpai UP NOTE');
				quickAnimAdd('singRIGHT', 'Angry Senpai RIGHT NOTE');

				loadOffsetFile(charName);

				scaleMult = 6;
				aliasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/${spritePath = 'spirit'}');

				quickAnimAdd('idle', 'idle spirit_');
				quickAnimAdd('singRIGHT', 'right_');
				quickAnimAdd('singDOWN', 'spirit down_');
				quickAnimAdd('singUP', 'up_');
				quickAnimAdd('singLEFT', 'left_');

				loadOffsetFile(charName);

				scaleMult = 6;
				aliasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'mom_dad_christmas_assets'}');

				quickAnimAdd('idle', 'Parent Christmas Idle');
				quickAnimAdd('singLEFT', 'Parent Left Note Dad');
				quickAnimAdd('singDOWN', 'Parent Down Note Dad');
				quickAnimAdd('singUP', 'Parent Up Note Dad');
				quickAnimAdd('singRIGHT', 'Parent Right Note Dad');
				quickAnimAdd('singLEFT-alt', 'Parent Left Note Mom');
				quickAnimAdd('singDOWN-alt', 'Parent Down Note Mom');
				quickAnimAdd('singUP-alt', 'Parent Up Note Mom');
				quickAnimAdd('singRIGHT-alt', 'Parent Right Note Mom');

				loadOffsetFile(charName);

			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'tankmanCaptain'}');

				final LEFT:String = faceLeft ? 'LEFT' : 'RIGHT';
				final RIGHT:String = faceLeft ? 'RIGHT' : 'LEFT';

				flipSprite = true;
				quickAnimAdd('idle', 'Tankman Idle Dance');
				quickAnimAdd('sing$LEFT', 'Tankman Note Left ');
				quickAnimAdd('singDOWN', 'Tankman DOWN note ');
				quickAnimAdd('singUP', 'Tankman UP note ');
				quickAnimAdd('sing$RIGHT', 'Tankman Right Note ');
				// quickAnimAdd('sing${LEFT}miss', 'Tankman Note Left MISS');
				// quickAnimAdd('singDOWNmiss', 'Tankman DOWN note MISS');
				// quickAnimAdd('singUPmiss', 'Tankman UP note MISS');
				// quickAnimAdd('sing${RIGHT}miss', 'Tankman Right Note MISS');
				quickAnimAdd('singDOWN-alt', 'PRETTY GOOD'); // PRETTY GOOD tankman
				quickAnimAdd('singUP-alt', 'TANKMAN UGH'); // TANKMAN UGH instanc

				loadOffsetFile(charName);

			default:
				var path:String = '';
				var applyFailsafe:Bool = false;
				if (!sys.FileSystem.exists('characters/$charName'))
					if (sys.FileSystem.exists('characters/$charName/$charVariant')) path = 'characters/$charName/$charVariant';
					else applyFailsafe = true;
				else path = 'characters/$charName';

				yamlData = applyFailsafe ? FailsafeUtil.charYaml : applyCharYaml(ParseUtil.parseYaml(path)); // get char data

				frames = Paths.getSparrowAtlas('characters/${spritePath = yamlData.sprite}');
				flipSprite = yamlData.flip;
				for (i in 0...yamlData.anims.length) {
					final anim = yamlData.anims[i];
					// multsparrow support soon
					if (anim.indices != null && anim.indices.length > 0)
						animation.addByIndices(anim.name, anim.tag, anim.indices, '', anim.fps, anim.loop, flipSprite);
					else animation.addByPrefix(anim.name, anim.tag, anim.fps, anim.loop, flipSprite);
					addOffset(anim.name, anim.offset.x, anim.offset.y);
				}
				xyOffset.set(yamlData.position.x, yamlData.position.y);
				camPoint.setPoint(yamlData.camera.x, yamlData.camera.y);

				scaleMult = yamlData.scale;
				singLength = yamlData.singLen;
				icon = yamlData.icon;
				aliasing = yamlData.aliasing;
				if (yamlData.color.trim() != '') iconColor = Std.parseInt(yamlData.color);
		}

		antialiasing = aliasing;
		if (scaleMult != 1) {
			setGraphicSize(Std.int(width * scaleMult));
			updateHitbox();
		}

		playAnim('idle', true);
		animation.finish();

		scripts.call('createPost');
	}

	public function loadMappedAnims() {
		final swagshit = Song.loadFromJson('picospeaker', 'stress');

		final notes = swagshit.notes;
		for (section in notes)
			for (idk in section.sectionNotes)
				animationNotes.push(idk);

		fnf.objects.background.TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);

	function quickAnimAdd(name:String, prefix:String)
		animation.addByPrefix(name, prefix, 24, false, flipSprite);

	private function loadOffsetFile(offsetCharacter:String) {
		final daFile:Array<String> = CoolUtil.coolTextFile(Paths.file('images/characters/${offsetCharacter}Offsets.txt'));
		for (i in daFile) {
			final splitWords:Array<String> = i.split(' ');
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}

	// "-end" anim code by @HIGGAMEON
	private var animB4Loop:String = '';
	override public function update(elapsed:Float) {
		scripts.call('update', [elapsed]);
		if (!debugMode && animation.curAnim != null) {
			if (animation.name.endsWith('miss') && animation.curAnim.finished) {
				tryDance();
				animation.finish();
			}

			switch (charName) {
				case 'pico-speaker':
					if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0]) {
						var noteData:Int = 1;
						if (animationNotes[0][1] > 2) noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if (animation.curAnim.finished) playAnim(animation.name, false, false, animation.curAnim.frames.length - 3);
			}

			// if (lastHit + (Conductor.stepCrochet * singLength) < Conductor.songPosition) tryDance();

			if (animation.curAnim.finished && animOffsets.exists('${animation.name}-loop')) {
				scripts.call('playingSpecialAnim', ['loop']);
				playAnim('${animation.name}-loop');
				scripts.call('playingSpecialAnimPost', ['loop']);
			}
		}
		super.update(elapsed);
		scripts.call('updatePost', [elapsed]);
	}

	public var onSway:Bool = false;
	public function dance() {
		scripts.call('dancing', [onSway]);
		if (!debugMode) {
			if (animation.curAnim.finished && animOffsets.exists('$animB4Loop-end') && !animation.name.endsWith('-end')) {
				scripts.call('playingSpecialAnim', ['end']);
				playAnim('$animB4Loop-end');
				scripts.call('playingSpecialAnimPost', ['end']);
			} else if (!preventIdle) {
				final anim:String = (onSway = !onSway) ? (hasSway ? 'sway' : 'idle') : 'idle';
				final suffix:String = animOffsets.exists('$anim${suffixes.idle}') ? suffixes.idle : '';
				playAnim('$anim$suffix');
			}
		}
		scripts.call('dancingPost', [onSway]);
	}

	public var preventIdleBopping:Bool = false;
	public function tryDance() dance(); // for now it like this

	public function playAnim(name:String, force:Bool = false, reverse:Bool = false, frame:Int = 0):Void {
		final suffix:String = animOffsets.exists('$name${suffixes.anim}') ? suffixes.anim : '';
		final anim:String = '$name$suffix';
		if (animOffsets.exists(anim)) {
			if (!animation.name.endsWith('-loop')) animB4Loop = name;
			scripts.call('playingAnim', [anim, force, reverse, frame]);
			animation.play(anim, force, reverse, frame);
			final daOffset = animOffsets.get(anim);
			offset.set(daOffset.x - xyOffset.x, daOffset.y - xyOffset.y);
			daOffset.putWeak();
			scripts.call('playingAnimPost', [anim, force, reverse, frame]);
		}
	}

	public function singAnimCheck(sing:String, suffix:String, miss:String):Array<String> {
		var has:AnimHas = {
			suffix: suffix.trim() == '' ? false : animOffsets.exists('$sing$miss$suffix'),
			miss: animOffsets.exists('${sing}miss$suffix') || animOffsets.exists('${sing}miss')
		};
		var cool:AnimCheck = {
			suffix: has.suffix ? suffix : '',
			miss: has.miss ? miss : ''
		};
		return [sing, cool.miss, cool.suffix]; // proper order
	}

	public var singAnims(get, default):Null<Array<Null<String>>>;
	public var globalSingAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	private function get_singAnims():Array<String> return singAnims == null ? globalSingAnims : singAnims;
	public function playSingAnim(direction:Int, suffix:String = '', missed:Bool = false, force:Bool = false, reverse:Bool = false, frame:Int = 0) {
		scripts.call('playingSingAnim', [direction, suffix, missed, force, reverse, frame]);
		var checkedAnims:Array<String> = singAnimCheck(
			singAnims[direction],
			suffix.trim() == '' ? suffixes.sing : suffix,
			missed ? 'miss' : ''
		);
		playAnim('${checkedAnims[0]}${checkedAnims[1]}${checkedAnims[2]}', force, reverse, frame);
		scripts.call('playingSingAnimPost', [direction, suffix, missed, force, reverse, frame]);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) animOffsets.set(name, FlxPoint.get(x, y));

	override public function destroy() {
		scripts.destroy();
		xyOffset.put();
		camPoint.destroy();
		super.destroy();
	}

	override public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak('Name', charName),
			LabelValuePair.weak('Variant', charVariant),
			LabelValuePair.weak('Facing', isFacing),
			LabelValuePair.weak('Beat Invertal', beatInterval),
			LabelValuePair.weak('Can Sway', hasSway)
		]);
	}
}
