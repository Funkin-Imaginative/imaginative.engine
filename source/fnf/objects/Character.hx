package fnf.objects;

import flixel.util.FlxStringUtil;

typedef AnimSuffixes = { // will still work even if alt isn't found
	@:default('') var idle:String; // for idle/sway
	@:default('') var sing:String; // for sing anims (global version)
	@:default('') var anim:String; // for any anim
}

enum abstract SpriteFacing(String) {
	var leftFace = 'left';
	var rightFace = 'right';
}

// after some thinking I see why cne did it capitalized
enum abstract AnimType(String) {
	var NONE = null;
	var DANCE = 'dance';
	var SING = 'sing';
	var MISS = 'miss';
	var LOCK = 'lock';
}

private typedef XY = {
	@:default(0) var x:Float;
	@:default(0) var y:Float;
}

private typedef AnimHas = {
	var miss:Bool;
	var suffix:Bool;
}
private typedef AnimCheck = {
	var miss:String;
	var suffix:String;
}

typedef AnimList = {
	var name:String;
	var tag:String;
	@:default(24) var fps:Float;
	@:default(false) var loop:Bool;
	var offset:XY;
	@:default([]) var indices:Array<Int>;
	@:optional var spritePath:String;
	@:optional @:default(false) var flip:Bool;
}

typedef CharData = {
	var sprite:String;
	@:default(false) var flip:Bool;
	var anims:Array<AnimList>;
	var position:XY;
	var camera:XY;

	@:optional @:default(1) var scale:Float;
	@:optional @:default(4) var singLen:Float;
	@:optional @:default('') var icon:String;
	@:optional @:default(true) var aliasing:Bool;
	@:optional @:default('') var color:String;
	@:optional @:default(0) var beat:Int;
}

class Character extends FlxSprite {
	public var debugMode:Bool = false; // for editors

	public var animOffsets:Map<String, FlxPoint> = new Map<String, FlxPoint>(); // the offsets
	public var animType:AnimType = NONE;

	// internal set to prevent setting
	@:unreflective var __name:String = 'boyfriend';
	@:unreflective var __variant:String = 'normal';
	// vars to actually use
	@:isVar public var charName(get, never):String; private function get_charName():String return __name;
	@:isVar public var charVariant(get, never):String; private function get_charVariant():String return __variant;
	public var hasVariant(get, never):Bool; private function get_hasVariant():Bool return charVariant != 'none';

	// quick way to set which direction the character is facing
	@:isVar public var isFacing(get, set):SpriteFacing = rightFace;
	private function get_isFacing():SpriteFacing return flipX ? rightFace : leftFace;
	private function set_isFacing(value:SpriteFacing):SpriteFacing {
		flipX = value == leftFace;
		return isFacing = value;
	}

	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	public var stunned:Bool = false;

	public var bopSpeed(default, set):Int = 1; private function set_bopSpeed(value:Int):Int return bopSpeed = bopSpeed < 1 ? 1 : value;
	public var beatInterval(get, default):Int = 0; private function get_beatInterval():Int return beatInterval < 1 ? (hasSway ? 1 : 2) : beatInterval;
	public var singLength:Float = 4; // Multiplier of how long a character holds the sing pose.
	public var suffixes:AnimSuffixes = {idle: '', sing: '', anim: ''}; // even tho @:default is used it didn't actually work lol
	public var preventIdle:Bool = false;
	public var hasSway(get, never):Bool; // Replaces 'danceLeft' with 'idle' and 'danceRight' with 'sway'.
	private function get_hasSway():Bool return suffixes.idle.trim() == '' ? animOffsets.exists('sway') : animOffsets.exists('sway${suffixes.idle}');

	public var xyOffset(default, never):FlxPoint = new FlxPoint();
	public var camPoint(default, never):BareCameraPoint = new BareCameraPoint();
	public function getCamPos():FlxPoint {
		var basePos:FlxPoint = getMidpoint();
		var event:PointEvent = new PointEvent(
			basePos.x + (xyOffset.x + camPoint.x) * (isFacing == rightFace ? 1 : -1),
			basePos.y + xyOffset.y + camPoint.y
		);
		basePos.put();
		scripts.call('getCameraPos', [event]);
		return new FlxPoint(event.x, event.y);
	}

	public var icon(get, default):String = 'face';
	private function get_icon():String return icon.trim() == '' ? spritePath : icon;

	public var animationNotes:Array<Dynamic> = [];

	public var spritePath:String = '';
	public var scaleMult:Float = 1;
	public var aliasing:Bool = true;
	public var flipSprite:Bool = false;
	public var iconColor(get, default):Null<FlxColor>;
	private function get_iconColor():FlxColor return iconColor == null ? 0xa1a1a1 : iconColor;

	public var charData:CharData;
	public static function applyCharData(yamlContent:Dynamic):CharData
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
			color: yamlContent.color,
			beat: yamlContent.beat
		};

	public var scripts:ScriptGroup; // just for effecting both scripts at once lmao
	public var charScript:Script;
	public var variantScript:Script;

	public function new(x:Float, y:Float, faceLeft:Bool = false, character:String = 'making this whatever to force failsafe', variant:String = 'Peanut Butter & (Blue) Cheese') {
		super(x, y);

		__name = character;
		__variant = variant;
		isFacing = faceLeft ? leftFace : rightFace;

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
			/* case 'gf':
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

				loadOffsetFile(charName); */

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

			/* case 'dad':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'DADDY_DEAREST'}');

				quickAnimAdd('idle', 'Dad idle dance');
				quickAnimAdd('singLEFT', 'Dad Sing Note LEFT');
				quickAnimAdd('singDOWN', 'Dad Sing Note DOWN');
				quickAnimAdd('singUP', 'Dad Sing Note UP');
				quickAnimAdd('singRIGHT', 'Dad Sing Note RIGHT');

				loadOffsetFile(charName); */

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
				quickAnimAdd('singLEFT', 'Monster Right note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singRIGHT', 'Monster left note');

				loadOffsetFile(charName);

			case 'monster-christmas':
				frames = Paths.getSparrowAtlas('characters/${spritePath = 'monsterChristmas'}');

				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singLEFT', 'Monster Right note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singRIGHT', 'Monster left note');

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
				charData = ParseUtil.parseCharacter(charName, charVariant); // get char data

				frames = Paths.getSparrowAtlas('characters/${spritePath = charData.sprite}');
				flipSprite = charData.flip;
				var anims:Array<AnimList> = charData.anims;
				for (anim in anims) {
					// final anim = charData.anims[i];
					// multsparrow support soon
					if (anim.indices != null && anim.indices.length > 0)
						animation.addByIndices(anim.name, anim.tag, anim.indices, '', anim.fps, anim.loop, flipSprite);
					else animation.addByPrefix(anim.name, anim.tag, anim.fps, anim.loop, flipSprite);
					addOffset(anim.name, anim.offset.x, anim.offset.y);
				}
				xyOffset.set(charData.position.x, charData.position.y);
				camPoint.setPoint(charData.camera.x, charData.camera.y);

				scaleMult = charData.scale;
				singLength = charData.singLen;
				icon = charData.icon;
				aliasing = charData.aliasing;
				if (charData.color.trim() != '') iconColor = Std.parseInt(charData.color);
				beatInterval = charData.beat;
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
			if (animName().endsWith('miss') && animFinished()) {
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
					if (animFinished()) playAnim(animName(), false, false, animation.curAnim.frames.length - 3);
			}

			if (animType != DANCE) tryDance();

			if (animFinished() && animOffsets.exists('${animName()}-loop')) {
				var event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('loop', false, NONE, false, 0));
				if (event.stopped) return;
				playAnim('${animName()}-loop', event.force, event.animType, event.reverse, event.frame);
				scripts.call('playingSpecialAnimPost', [event]);
			}
		}
		super.update(elapsed);
		scripts.call('updatePost', [elapsed]);
	}

	public var onSway:Bool = false;
	public function dance() {
		var event:BopEvent = scripts.event('dancing', new BopEvent(!onSway));
		if (!debugMode || !event.stopped) {
			if (animFinished() && animOffsets.exists('$animB4Loop-end') && !animName().endsWith('-end')) {
				var event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('end', false, NONE, false, 0));
				if (event.stopped) return;
				playAnim('$animB4Loop-end', event.force, event.animType, event.reverse, event.frame);
				scripts.call('playingSpecialAnimPost', [event]);
			} else if (!preventIdle) {
				onSway = event.sway;
				final anim:String = onSway ? (hasSway ? 'sway' : 'idle') : 'idle';
				final suffix:String = animOffsets.exists('$anim${suffixes.idle}') ? suffixes.idle : '';
				playAnim('$anim$suffix', true, DANCE);
			}
		}
		scripts.call('dancingPost', [event]);
	}

	public var preventIdleBopping:Bool = false;
	public function tryDance() {
		switch (animType) {
			case SING | MISS:
				if (lastHit + (Conductor.stepCrochet * singLength) < Conductor.songPosition)
					dance();
			case DANCE:
				dance();
			case LOCK:
				if (animName() == null)
					dance();
			default:
				if (animName() == null || animFinished())
					dance();
		}
	}

	public function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0):Void {
		var event:PlayAnimEvent = scripts.event('playingAnim', new PlayAnimEvent(name, force, animType, reverse, frame));
		if (event.stopped) return;
		final suffix:String = animOffsets.exists('${event.anim}${suffixes.anim}') ? suffixes.anim : '';
		final anim:String = '${event.anim}$suffix';
		if (animOffsets.exists(anim)) {
			if (!animName().endsWith('-loop')) animB4Loop = anim;
			this.animType = event.animType;
			animation.play(anim, event.force, event.reverse, event.frame);
			final daOffset = animOffsets.get(anim);
			offset.set(daOffset.x - xyOffset.x, daOffset.y - xyOffset.y);
			daOffset.putWeak();
			if (animType == SING || animType == MISS)
				lastHit = Conductor.songPosition;
			scripts.call('playingAnimPost', [event]);
		}
	}

	public function singAnimCheck(sing:String, miss:String, suffix:String):Array<String> {
		var has:AnimHas = {
			miss: animOffsets.exists('${sing}miss$suffix') || animOffsets.exists('${sing}miss'),
			suffix: suffix.trim() == '' ? false : animOffsets.exists('$sing$miss$suffix')
		};
		var cool:AnimCheck = {
			miss: has.miss ? miss : '',
			suffix: has.suffix ? suffix : ''
		};
		return [sing, cool.miss, cool.suffix];
	}

	public static var globalSingAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public var singAnims(get, default):Null<Array<Null<String>>>;
	private function get_singAnims():Array<String> {
		var theAnims:Array<String> = singAnims == null ? globalSingAnims : singAnims;
		for (index => anim in theAnims) theAnims[index] = anim == null ? globalSingAnims[index] : anim;
		return theAnims;
	}
	public function playSingAnim(direction:Int, suffix:String = '', animType:AnimType = SING, force:Bool = true, reverse:Bool = false, frame:Int = 0) {
		var event:PlaySingAnimEvent = scripts.event('playingSingAnim', new PlaySingAnimEvent(direction, suffix, animType, force, reverse, frame));
		if (event.stopped) return;
		var checkedAnims:Array<String> = singAnimCheck(
			singAnims[event.direction],
			event.animType == MISS ? 'miss' : '',
			event.suffix.trim() == '' ? suffixes.sing : event.suffix
		);
		playAnim('${checkedAnims[0]}${checkedAnims[1]}${checkedAnims[2]}', event.force, event.animType, event.reverse, event.frame);
		scripts.call('playingSingAnimPost', [event]);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) animOffsets.set(name, FlxPoint.get(x, y));

	public function animName():String return animation.name;
	public function animFinished():Bool return animation.curAnim.finished;

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
