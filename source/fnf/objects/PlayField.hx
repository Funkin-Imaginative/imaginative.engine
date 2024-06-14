package fnf.objects;

import fnf.objects.note.groups.*;
import fnf.objects.note.*;
import fnf.ui.HealthIcon;

private typedef StupidLOL = {
	var enemy:HealthBarSetup;
	var player:HealthBarSetup;
}
private typedef HealthBarSetup = {
	var color:FlxColor;
	var icon:String;
}
typedef PlayFieldSetup = {
	var scriptGroup:Null<ScriptGroup>;
	@:optional var barStuff:StupidLOL;
}

class PlayField extends MusicBeatGroup implements IMusicBeat {
	public var strumLines:Array<StrumGroup> = [];
	public var enemyStrumLine:StrumGroup;
	public var playerStrumLine:StrumGroup;
	public var healthBarBG:FunkinSprite;
	public var healthBar:BetterBar;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var iconOffset:Int = 26;

	public static var fieldScripts:ScriptGroup;
	public var stateScripts:ScriptGroup;
	public static var direct:PlayField = null;
	public var state:Dynamic; // ideas, ideas

	public var minHealth(default, set):Float = 0; // >:)
	inline function set_minHealth(value:Float):Float {
		if (healthBar != null && healthBar.min == minHealth)
			healthBar.setRange(minHealth, healthBar.max);
		return minHealth = value;
	}

	var __health:Float;
	public var health(default, set):Float;
	inline function set_health(value:Float):Float return health = FlxMath.bound(value, minHealth, maxHealth);

	public var maxHealth(default, set):Float = 2;
	inline function set_maxHealth(value:Float):Float {
		if (healthBar != null && healthBar.max == maxHealth)
			healthBar.setRange(healthBar.min, value);
		return maxHealth = value;
	}

	public function new(state:Dynamic, ?setup:PlayFieldSetup):Void {
		super(); // note using the state var in source is a bitch
		if (direct == null || (this.state = state) is MusicBeatState) {/*Satety first!*/} else {
			trace('Either you have a PlayField instance already or you didn\'t make it in a MusicBeatState instance.');
			destroy();
		}
		setup == null ? {stateScripts: null} : setup;
		setup.barStuff == null ? {
			enemy: {color: null, icon: 'face'},
			player: {color: null, icon: 'face'}
		} : setup.barStuff;
		stateScripts = setup.scriptGroup == null ? new ScriptGroup(this) : setup.scriptGroup;
		fieldScripts = new ScriptGroup(direct = this);
		fieldScripts.add(Script.create('content/fieldscripts/script'));
		fieldScripts.load();

		__health = health = (maxHealth - minHealth) / 2; // health setup lol
		var downscroll:Bool = SaveManager.getOption('downscroll');

		(healthBarBG = new FunkinSprite()).makeGraphic(600, 20);
		healthBarBG.color = FlxColor.BLACK;
		healthBarBG.screenCenter();
		healthBarBG.y += FlxG.height / 2.6 * (downscroll ? -1 : 1);
		add(healthBarBG);

		#if debug trace(setup); #end
		healthBar = new BetterBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, '__health', minHealth, maxHealth);
		healthBar.changeColors(FlxColor.RED, 0xFF66FF33, true);
		healthBar.changeColorsUnsafe(setup.barStuff.enemy.color, setup.barStuff.player.color);
		add(healthBar);

		add(iconP1 = new HealthIcon(setup.barStuff.player.icon, true));
		add(iconP2 = new HealthIcon(setup.barStuff.enemy.icon));
		iconP1.setupTracking(healthBar, (bar:BetterBar) -> return PositionMeta.get(bar.midPoint.x - iconOffset, bar.midPoint.y - (iconP1.height / 2)));
		iconP2.setupTracking(healthBar, (bar:BetterBar) -> return PositionMeta.get(bar.midPoint.x - (iconP2.width - iconOffset), bar.midPoint.y - (iconP2.height / 2)));

		add(StrumGroup.enemy = enemyStrumLine = new StrumGroup((FlxG.width * .5) - (FlxG.width * .25), 0, false));
		add(StrumGroup.player = playerStrumLine = new StrumGroup((FlxG.width * .5) + (FlxG.width * .25), 0, false));

		for (strumLine in [enemyStrumLine, playerStrumLine]) {
			for (strum in strumLine) {
				strum.screenCenter(Y);
				strum.y += FlxG.height / 2.7 * (downscroll ? 1 : -1);
			}
			strumLines.push(strumLine);
		}
	}

	public static function noteHit(note:Note, strumGroup:StrumGroup) {
		if (!note.wasHit && !note.wasMissed) {
			// pre call checks
			if (note.hitCausesMiss) return noteMiss(note, note.data, strumGroup);
			note.wasHit = true;

			// event creation
			var event:NoteHitEvent = new NoteHitEvent(note, note.data, strumGroup);
			StrumGroup.hitFuncs.noteHit(event); if (event.stopped) return;

			// note calls
			direct.stateScripts.event('noteHit', event);
			strumGroup.signals.noteHit.dispatch(event); if (event.stopped) return;

			// splashes/holdcovers
			if (note.isSustain) note.getHoldCover((cover:HoldCover) -> cover.playAnim('hold'));
			else {
				if (strumGroup.status) strumGroup.spawn(Splash, note);
				if (note.tail.length > 0) strumGroup.spawn(HoldCover, note);
			}

			direct.stateScripts.call('noteHitPost', [event]);
		}
	}
	public static function noteMiss(note:Null<Note>, ?direction:Int, strumGroup:StrumGroup) {
		if (note == null) {
			// event creation
			var event:MissEvent = new MissEvent(direction, strumGroup);

			// note calls
			direct.stateScripts.event('generalMiss', event); if (event.stopped) return;

			direct.stateScripts.call('generalMissPost', [event]);
		} else {
			if (!note.wasHit && !note.wasMissed) {
				// pre call checks
				if (note.isSustain) {note.parent.wasMissed = true; for (sus in note.parent.tail) sus.wasMissed = true;}
				else {note.wasMissed = true; for (sus in note.tail) sus.wasMissed = true;}

				// event creation
				var event:NoteMissEvent = new NoteMissEvent(note, direction, strumGroup);
				StrumGroup.hitFuncs.noteMiss(event); if (event.stopped) return;

				// note calls
				direct.stateScripts.event('noteMiss', event);
				strumGroup.signals.noteMiss.dispatch(event); if (event.stopped) return;

				// kill the cover
				note.getHoldCover((cover:HoldCover) -> cover.kill());

				direct.stateScripts.call('noteMissPost', [event]);
			}
		}
	}

	override public function update(elapsed:Float):Void {
		fieldScripts.call('update', [elapsed]);
		super.update(elapsed);
		__health = FlxMath.lerp(__health, health, 0.15);
		if (FlxG.keys.justPressed.F4) PlayUtil.botplay = !PlayUtil.botplay;
		fieldScripts.call('updatePost', [elapsed]);
	}

	override public function stepHit(curStep:Int) {
		super.stepHit(curStep);
		fieldScripts.call('stepHit', [curStep]);
	}

	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		fieldScripts.call('beatHit', [curBeat]);
	}

	override public function measureHit(curMeasure:Int) {
		super.measureHit(curMeasure);
		fieldScripts.call('measureHit', [curMeasure]);
	}

	override public function destroy():Void {
		fieldScripts.destroy();
		direct = null;
		state = null;
		super.destroy();
	}
}



/** original concept, made in psych lua
```lua
local function shared(downscroll)
	for index, value in pairs({ 'iconP1', 'iconP2', 'healthBar' }) do
		screenCenter(value, 'Y')
		setProperty(value .. '.y', getProperty(value .. '.y') + (screenHeight / 2.6) * (downscroll and -1 or 1))
	end
	for index, value in pairs({ 'timeBar', 'timeTxt', 'botplayTxt' }) do
		screenCenter(value, 'Y')
		setProperty(value .. '.y', getProperty(value .. '.y') + (screenHeight / (value == 'botplayTxt' and 2.7 or 2.15)) * (downscroll and 1 or -1))
	end
	for i = 0, getProperty('strumLineNotes.length') - 1 do
		screenCenter('strumLineNotes.members[' .. i .. ']', 'Y')
		setPropertyFromGroup('strumLineNotes', i, 'y', getPropertyFromGroup('strumLineNotes', i, 'y') + (screenHeight / 2.7) * (downscroll and 1 or -1))
	end

	return {
		getProperty('healthBar.y') + 50 * (downscroll and 1 or -1),
		10 * (downscroll and 1 or -1)
	}
end

local breaksInfoDoesCombos = true
function onCreatePost()
	local yCalc = shared(downscroll)
	makeLuaText('breakInfo', (breaksInfoDoesCombos and 'Combo Breaks' or 'Misses') .. ': 0', screenWidth / 3.2, 0, yCalc[1] - yCalc[2])
	makeLuaText('accuracyInfo', 'Accuracy: 0% Start playing! (...)', screenWidth / 3.2, 0, yCalc[1] + yCalc[2])
	makeLuaText('scoreInfo', 'Score: 0', screenWidth / 3.2, 0, yCalc[1] - yCalc[2])
	addLuaText('breakInfo')
	addLuaText('accuracyInfo')
	addLuaText('scoreInfo')
	setTextFont('breakInfo', 'PhantomMuff.ttf')
	setTextFont('accuracyInfo', 'PhantomMuff.ttf')
	setTextFont('scoreInfo', 'PhantomMuff.ttf')

	setTextWidth('scoreTxt', 1) -- completely hide original
	screenCenter('accuracyInfo', 'x')
	setProperty('breakInfo.x', getProperty('accuracyInfo.x') - (screenWidth / 4.3))
	setProperty('scoreInfo.x', getProperty('accuracyInfo.x') + (screenWidth / 4.3))
end

function ChaSrlTyp_onUpdateHud(_, downscroll, _, _)
	local yCalc = shared(downscroll)
	setProperty('breakInfo.y', yCalc[1] - yCalc[2])
	setProperty('accuracyInfo.y', yCalc[1] + yCalc[2])
	setProperty('scoreInfo.y', yCalc[1] - yCalc[2])

	screenCenter('accuracyInfo', 'x')
	setProperty('breakInfo.x', getProperty('accuracyInfo.x') - (screenWidth / 4.3))
	setProperty('scoreInfo.x', getProperty('accuracyInfo.x') + (screenWidth / 4.3))
end

local percent = 0
function clamp(x, min, max) return math.max(min, math.min(x, max)) end
function onUpdate()
	percent = clamp(math.floor(rating * 100), 0, 100)
end

local function sharedNoteMiss(membersIndex, noteData, noteType, isSustainNote)
	if scoreZoom then
		cancelTween('breakInfoTweens')
		scaleObject('breakInfo', getRandomFloat(0.7, 0.99), getRandomFloat(0.7, 0.99), false)
		setProperty('breakInfo.angle', getRandomFloat(-50, 50, '-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10'))
		startTween('breakInfoTweens', 'breakInfo', { ['scale.x'] = 1, ['scale.y'] = 1, angle = 0 }, 1, { ease = 'smootherstepInOut' })
	end
	cancelTween('breakInfoColor')
	setTextColor('breakInfo', 'ff0000')
	doTweenColor('breakInfoColor', 'breakInfo', 'ffffff', 1, 'smootherstepInOut')
end
function noteMiss(membersIndex, noteData, noteType, isSustainNote) sharedNoteMiss(membersIndex, noteData, noteType, isSustainNote) end
function noteMissPress(direction) sharedNoteMiss(nil, direction, '', false) end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
	if scoreZoom then
		cancelTween('scoreInfoZoomX')
		cancelTween('scoreInfoZoomY')
		scaleObject('scoreInfo', 1.2, 1.2, false)
		startTween('scoreInfoZoomX', 'scoreInfo.scale', { x = 1 }, 0.2, { ease = 'bounceOut' })
		startTween('scoreInfoZoomY', 'scoreInfo.scale', { y = 1 }, 0.2, { ease = 'smootherstepInOut' })
	end
	if breaksInfoDoesCombos and (getPropertyFromGroup('notes', membersIndex, 'rating') == 'bad' or getPropertyFromGroup('notes', membersIndex, 'rating') == 'shit') then
		sharedNoteMiss(membersIndex, noteData, noteType, isSustainNote)
		onUpdateScore(true)
	end
end

function onCountdownTick(swagCounter) onBop(swagCounter) end
function onBeatHit() onBop(curBeat) end
function onBop(onPercent)
	local spedCalc = 0
	if scoreZoom then
		local spedLevel = {
			{ 90, 1 },
			{ 70, 2 },
			{ 50, 3 },
			{ 30, 4 },
			{ 0,  0 }
		}
		local v
		for i = #spedLevel, 1, -1 do
			v = spedLevel[i]
			if (percent >= v[1]) then spedCalc = v[2] else break end
		end
		if spedCalc <= 69 and spedCalc >= 69 then
			spedCalc = 1
		end
	end

	if scoreZoom and (onPercent % spedCalc == 0 or getTextString('accuracyInfo'):find('(...)')) then
		cancelTween('accuracyInfoZoomX')
		cancelTween('accuracyInfoZoomY')
		scaleObject('accuracyInfo', 1.2, 1.2, false)
		local beatCalc = (crochet / 1000) / 2.3
		startTween('accuracyInfoZoomX', 'accuracyInfo.scale', { x = 1 }, beatCalc, { ease = 'bounceOut' })
		startTween('accuracyInfoZoomY', 'accuracyInfo.scale', { y = 1 }, beatCalc, { ease = 'smootherstepInOut' })
	end
end

function onRecalculateRating()
	setTextString('accuracyInfo', 'Accuracy: ' .. percent .. '% ' .. ratingName .. ' (' .. ratingFC .. ')')
end

function onUpdateScore(miss)
	local text = miss and (breaksInfoDoesCombos and 'Combo Breaks' or 'Misses') or 'Score'
	local info = miss and (getMisses() + (breaksInfoDoesCombos and (getProperty('ratingsData[2].hits') + getProperty('ratingsData[3].hits')) or 0)) or getScore()
	setTextString(miss and 'breakInfo' or 'scoreInfo', text .. ': ' .. tostring(info))
end
```
*/