package;

import Section.SwagSection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
import haxe.io.Path;

using StringTools;

typedef coolOffsetMapStuff = {
	var facingLeft:Map<String, Array<Dynamic>>;
	var facingRight:Map<String, Array<Dynamic>>;
	var backups = { // For reoffseting when scale is changed
		var facingLeft:Map<String, Array<Dynamic>>;
		var facingRight:Map<String, Array<Dynamic>>;
	};
};

class Character extends FlxSprite {
	public var debugMode:Bool = false;
	public var animOffsets:Map<String, Array<Dynamic>>;
	//public var offsetMaps:Array<coolOffsetMapStuff>

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var swayHead:Bool = false;
	public var danceNumBeats:Int = 1:
	public var bopSpeed:Float = 1:
	
	public var holdTimer:Float = 0;
	public var singDuration:Float = 4;
	
	public var positionOffset:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	
	public var idleSuffix:String = '':
	public var shoutAnim:String = '';
	public var healthColorArray:Array<Int> = [128, 0, 255];
	
	public var noInterup = {
		singing = false,
		bopping = false
	};

	public var animationNotes:Array<Dynamic> = [];

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false) {
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;
		
		if (curCharacter.startsWith('gf') || curCharacter == 'spooky') danceNumBeats = 2;
		if (curCharacter.startsWith('gf')) shoutAnim = 'cheer';
		if (curCharacter.startsWith('bf')) shoutAnim = 'hey';
		switch (curCharacter) {
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets');
				frames = tex;
				quickAnimAdd('cheer', 'GF Cheer');
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], '', 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
				animation.addByIndices('hairBlow', 'GF Dancing Beat Hair blowing', [0, 1, 2, 3], '', 24);
				animation.addByIndices('hairFall', 'GF Dancing Beat Hair Landing', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], '', 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);

				loadOffsetFile(curCharacter);
			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas');
				frames = tex;
				quickAnimAdd('cheer', 'GF Cheer');
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], '', 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
				animation.addByIndices('hairBlow', 'GF Dancing Beat Hair blowing', [0, 1, 2, 3], '', 24);
				animation.addByIndices('hairFall', 'GF Dancing Beat Hair Landing', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], '', 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24, true);

				loadOffsetFile(curCharacter);
			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen');
				animation.addByIndices('sad', 'GF Crying at Gunpoint', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], '', 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);

				shoutAnim = '';
				loadOffsetFile('gf');
			case 'bf-holding-gf':
				frames = Paths.getSparrowAtlas('characters/bfAndGF');
				quickAnimAdd('idle', 'BF idle dance', true);
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0', true);
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0', true);
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0', true);
				quickAnimAdd('singUP', 'BF NOTE UP0', true);

				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS', true);
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS', true);
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS', true);
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS', true);
				quickAnimAdd('bfCatch', 'BF catches GF', true);

				loadOffsetFile(curCharacter);
				shoutAnim = '';
				//flipX = true;
			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], '', 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
				animation.addByIndices('idle-loop', 'GF Dancing Beat Hair blowing CAR', [10, 11, 12, 25, 26, 27], '', 24, true);

				loadOffsetFile(curCharacter);
				shoutAnim = '';
			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], '', 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);

				loadOffsetFile(curCharacter);
				shoutAnim = '';

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
				frames = tex;
				quickAnimAdd('idle', 'Dad idle dance');
				quickAnimAdd('singUP', 'Dad Sing Note UP');
				quickAnimAdd('singRIGHT', 'Dad Sing Note RIGHT');
				quickAnimAdd('singDOWN', 'Dad Sing Note DOWN');
				quickAnimAdd('singLEFT', 'Dad Sing Note LEFT');

				loadOffsetFile(curCharacter);
				singDuration = 6.1;
			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets');
				frames = tex;
				quickAnimAdd('singUP', 'spooky UP NOTE');
				quickAnimAdd('singDOWN', 'spooky DOWN note');
				quickAnimAdd('singLEFT', 'note sing left');
				quickAnimAdd('singRIGHT', 'spooky sing right');
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], '', 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], '', 12, false);

				loadOffsetFile(curCharacter);
			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets');
				frames = tex;

				quickAnimAdd('idle', 'Mom Idle');
				quickAnimAdd('singUP', 'Mom Up Pose');
				quickAnimAdd('singDOWN', 'MOM DOWN POSE');
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				quickAnimAdd('singRIGHT', 'Mom Pose Left');

				loadOffsetFile(curCharacter);
			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar');
				frames = tex;

				quickAnimAdd('idle', 'Mom Idle');
				quickAnimAdd('singUP', 'Mom Up Pose');
				quickAnimAdd('singDOWN', 'MOM DOWN POSE');
				quickAnimAdd('singLEFT', 'Mom Left Pose');
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				quickAnimAdd('singRIGHT', 'Mom Pose Left');
				animation.addByIndices('idle-loop', 'Mom Idle', [10, 11, 12, 13], '', 24, true);

				loadOffsetFile(curCharacter);
			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets');
				frames = tex;
				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singLEFT', 'Monster left note');
				quickAnimAdd('singRIGHT', 'Monster Right note');

				loadOffsetFile(curCharacter);
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas');
				frames = tex;
				quickAnimAdd('idle', 'monster idle');
				quickAnimAdd('singUP', 'monster up note');
				quickAnimAdd('singDOWN', 'monster down');
				quickAnimAdd('singLEFT', 'Monster left note');
				quickAnimAdd('singRIGHT', 'Monster Right note');

				loadOffsetFile(curCharacter);
			case 'pico':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss');
				frames = tex;
				quickAnimAdd('idle', 'Pico Idle Dance', true);
				quickAnimAdd('singUP', 'pico Up note0', true);
				quickAnimAdd('singDOWN', 'Pico Down Note0', true);
				if (isPlayer) {
					quickAnimAdd('singLEFT', 'Pico NOTE LEFT0', true);
					quickAnimAdd('singRIGHT', 'Pico Note Right0', true);
					quickAnimAdd('singRIGHTmiss', 'Pico Note Right Miss', true);
					quickAnimAdd('singLEFTmiss', 'Pico NOTE LEFT miss', true);
				} else {
					// Need to be flipped! REDO THIS LATER!
					quickAnimAdd('singLEFT', 'Pico Note Right0', true);
					quickAnimAdd('singRIGHT', 'Pico NOTE LEFT0', true);
					quickAnimAdd('singRIGHTmiss', 'Pico NOTE LEFT miss', true);
					quickAnimAdd('singLEFTmiss', 'Pico Note Right Miss', true);
				}
				quickAnimAdd('singUPmiss', 'pico Up note miss', true);
				quickAnimAdd('singDOWNmiss', 'Pico Down Note MISS', true);

				loadOffsetFile(curCharacter);
				//flipX = true;
			case 'pico-speaker':
				frames = Paths.getSparrowAtlas('characters/picoSpeaker');
				quickAnimAdd('shoot1', 'Pico shoot 1');
				quickAnimAdd('shoot2', 'Pico shoot 2');
				quickAnimAdd('shoot3', 'Pico shoot 3');
				quickAnimAdd('shoot4', 'Pico shoot 4');

				// here for now, will be replaced later for less copypaste
				loadOffsetFile(curCharacter);
				playAnim('shoot1');
				loadMappedAnims();
			case 'bf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND');
				frames = tex;
				quickAnimAdd('idle', 'BF idle dance', true);
				quickAnimAdd('singUP', 'BF NOTE UP0', true);
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0', true);
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0', true);
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0', true);
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS', true);
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS', true);
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS', true);
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS', true);
				quickAnimAdd('hey', 'BF HEY', true);

				quickAnimAdd('firstDeath', 'BF dies', true);
				quickAnimAdd('deathLoop', 'BF Dead Loop', true);
				quickAnimAdd('deathConfirm', 'BF Dead confirm', true);

				animation.addByPrefix('scared', 'BF idle shaking', 24, true);

				loadOffsetFile(curCharacter);
				//flipX = true;
			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas');
				frames = tex;
				quickAnimAdd('idle', 'BF idle dance', true);
				quickAnimAdd('singUP', 'BF NOTE UP0', true);
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0', true);
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0', true);
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0', true);
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS', true);
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS', true);
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS', true);
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS', true);
				quickAnimAdd('hey', 'BF HEY', true);

				loadOffsetFile(curCharacter);
				//flipX = true;
			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar');
				frames = tex;
				quickAnimAdd('idle', 'BF idle dance', true);
				quickAnimAdd('singUP', 'BF NOTE UP0', true);
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0', true);
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0', true);
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0', true);
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS', true);
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS', true);
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS', true);
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS', true);
				animation.addByIndices('idle-loop', 'BF idle dance', [10, 11, 12, 13], '', 24, true);

				loadOffsetFile(curCharacter);
				shoutAnim = '';
				//flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				quickAnimAdd('idle', 'BF IDLE', true);
				quickAnimAdd('singUP', 'BF UP NOTE', true);
				quickAnimAdd('singLEFT', 'BF LEFT NOTE', true);
				quickAnimAdd('singRIGHT', 'BF RIGHT NOTE', true);
				quickAnimAdd('singDOWN', 'BF DOWN NOTE', true);
				quickAnimAdd('singUPmiss', 'BF UP MISS', true);
				quickAnimAdd('singLEFTmiss', 'BF LEFT MISS', true);
				quickAnimAdd('singRIGHTmiss', 'BF RIGHT MISS', true);
				quickAnimAdd('singDOWNmiss', 'BF DOWN MISS', true);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				shoutAnim = '';

				width -= 100;
				height -= 100;

				antialiasing = false;
				//flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				quickAnimAdd('singUP', 'BF Dies pixel', true);
				quickAnimAdd('firstDeath', 'BF Dies pixel', true);
				quickAnimAdd('deathLoop', 'Retry Loop', true);
				quickAnimAdd('deathConfirm', 'RETRY CONFIRM', true);

				loadOffsetFile(curCharacter);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				//flipX = true;
			case 'bf-holding-gf-dead':
				frames = Paths.getSparrowAtlas('characters/bfHoldingGF-DEAD');
				quickAnimAdd('singUP', 'BF Dead with GF Loop', true);
				quickAnimAdd('firstDeath', 'BF Dies with GF', true);
				quickAnimAdd('deathLoop', 'BF Dead with GF Loop', true);
				quickAnimAdd('deathConfirm', 'RETRY confirm holding gf', true);

				loadOffsetFile(curCharacter);
				playAnim('firstDeath');
				//flipX = true;
			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai');
				quickAnimAdd('idle', 'Senpai Idle');
				// at framerate 16.8 animation plays over 2 beats at 144bpm,
				// but if the game lags or the bpm is > 144 (mods etc.)
				// he may miss his next dance
				// animation.getByName('idle').frameRate = 16.8;

				quickAnimAdd('singUP', 'SENPAI UP NOTE');
				quickAnimAdd('singLEFT', 'SENPAI LEFT NOTE');
				quickAnimAdd('singRIGHT', 'SENPAI RIGHT NOTE');
				quickAnimAdd('singDOWN', 'SENPAI DOWN NOTE');

				loadOffsetFile(curCharacter);
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai');
				quickAnimAdd('idle', 'Angry Senpai Idle');
				quickAnimAdd('singUP', 'Angry Senpai UP NOTE');
				quickAnimAdd('singLEFT', 'Angry Senpai LEFT NOTE');
				quickAnimAdd('singRIGHT', 'Angry Senpai RIGHT NOTE');
				quickAnimAdd('singDOWN', 'Angry Senpai DOWN NOTE');

				loadOffsetFile(curCharacter);
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit');
				quickAnimAdd('idle', 'idle spirit_');
				quickAnimAdd('singUP', 'up_');
				quickAnimAdd('singRIGHT', 'right_');
				quickAnimAdd('singLEFT', 'left_');
				quickAnimAdd('singDOWN', 'spirit down_');

				loadOffsetFile(curCharacter);
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets');
				quickAnimAdd('idle', 'Parent Christmas Idle');
				quickAnimAdd('singUP', 'Parent Up Note Dad');
				quickAnimAdd('singDOWN', 'Parent Down Note Dad');
				quickAnimAdd('singLEFT', 'Parent Left Note Dad');
				quickAnimAdd('singRIGHT', 'Parent Right Note Dad');

				quickAnimAdd('singUP-alt', 'Parent Up Note Mom');
				quickAnimAdd('singDOWN-alt', 'Parent Down Note Mom');
				quickAnimAdd('singLEFT-alt', 'Parent Left Note Mom');
				quickAnimAdd('singRIGHT-alt', 'Parent Right Note Mom');

				loadOffsetFile(curCharacter);
			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/tankmanCaptain');
				quickAnimAdd('idle', 'Tankman Idle Dance', true);
				if (isPlayer) {
					quickAnimAdd('singLEFT', 'Tankman Note Left ', true);
					quickAnimAdd('singRIGHT', 'Tankman Right Note ', true);
					quickAnimAdd('singLEFTmiss', 'Tankman Note Left MISS', true);
					quickAnimAdd('singRIGHTmiss', 'Tankman Right Note MISS', true);
				} else {
					// Need to be flipped! REDO THIS LATER
					quickAnimAdd('singLEFT', 'Tankman Right Note ', true);
					quickAnimAdd('singRIGHT', 'Tankman Note Left ', true);
					quickAnimAdd('singLEFTmiss', 'Tankman Right Note MISS', true);
					quickAnimAdd('singRIGHTmiss', 'Tankman Note Left MISS', true);
				}
				quickAnimAdd('singUP', 'Tankman UP note ', true);
				quickAnimAdd('singDOWN', 'Tankman DOWN note ', true);
				quickAnimAdd('singUPmiss', 'Tankman UP note MISS', true);
				quickAnimAdd('singDOWNmiss', 'Tankman DOWN note MISS', true);

				// PRETTY GOOD tankman
				// TANKMAN UGH instanc

				quickAnimAdd('singDOWN-alt', 'PRETTY GOOD', true);
				quickAnimAdd('singUP-alt', 'TANKMAN UGH', true);

				loadOffsetFile(curCharacter);
				shoutAnim = 'singUP-alt';
				//flipX = true;
		}
		dance();
		animation.finish();

		if (isPlayer) flipX = !flipX;
	}

	public function precacheCharacter(newCharacter:String) {
		var cachedChar:character = new Character(0, 0, newCharacter);
		cachedChar.alpha = 0.0000001;
	}

	public function loadMappedAnims() {
		var swagshit = Song.loadFromJson('picospeaker', 'stress');
		var notes = swagshit.notes;
		for (section in notes)
			for (idk in section.sectionNotes)
				animationNotes.push(idk);

		TankmenBG.animationNotes = animationNotes;
		trace(animationNotes);
		animationNotes.sort(sortAnims);
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int { return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]); }
	function quickAnimAdd(name:String, prefix:String, ?flipX:Bool = false) { animation.addByPrefix(name, prefix, 24, false); }
	private function loadOffsetFile(offsetCharacter:String) {
		var daFile:Array<String> = CoolUtil.coolTextFile(Paths.file('images/characters/' + offsetCharacter + 'Offsets.txt'));
		for (i in daFile) {
			var splitWords:Array<String> = i.split(' ');
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}

	override function update(elapsed:Float) {
		swayHead = animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null;
		if (animation.curAnim.name.startsWith('sing')) holdTimer += elapsed;
		else { if (isPlayer) holdTimer = 0; }

		if (holdTimer >= Conductor.stepCrochet * singDuration * 0.001) {
			dance();
			holdTimer = 0;
		}

		if (animation.curAnim.name.startsWith('sing')) holdTimer += elapsed;
		else holdTimer = 0;

		if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
		playAnim('idle', true, false, 10);

		if (animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
		playAnim(animation.curAnim.name + '-loop');

		if (curCharacter == 'pico-speaker') { // for pico??
			if (animationNotes.length > 0) {
				if (Conductor.songPosition > animationNotes[0][0]) {
					// trace('played shoot anim' + animationNotes[0][1]);
					var shootAnim:Int = 1;
					if (animationNotes[0][1] >= 2) shootAnim = 3;
					shootAnim += FlxG.random.int(0, 1);
					playAnim('shoot' + shootAnim, true);
					animationNotes.shift();
				}
			}
			if (animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
		}
		super.update(elapsed);
	}

	private var danced:Bool = false;

	// FOR GF DANCING SHIT
	public function dance() {
		if (!debugMode || !noInterup.bopping) {
			if (swayHead) {
				danced = !danced;
				if (danced) playAnim('danceRight' + idleSuffix);
				else playAnim('danceLeft' + idleSuffix);
			} else playAnim('idle' + idleSuffix);
		}
		noInterup.bopping = false;
	}

	public function playAnim(AnimName:String, ?Force:Bool = false, ?Reversed:Bool = false, ?Frame:Int = 0):Void {
		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName)) {
			animation.play(AnimName, Force, Reversed, Frame);
			offset.set(daOffset[0], daOffset[1]);
		}
		noInterup.singing = false;
	}
	public function addOffset(name:String, x:Float = 0, y:Float = 0) { animOffsets[name] = [x, y]; }
}
