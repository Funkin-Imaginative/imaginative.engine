package fnf.objects;

import fnf.objects.note.groups.StrumGroup;
import fnf.ui.HealthIcon;

class PlayField extends FlxGroup {
	public var strumLines:Array<StrumGroup> = [];
	public var opponentStrumLine:StrumGroup;
	public var playerStrumLine:StrumGroup;
	public var healthBarBG:FlxSprite;
	public var healthBar:FunkinBar;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public static var direct:PlayField = null;
	public var game:PlayState; // ideas, ideas

	public var minHealth(default, set):Float = 0; // >:)
	inline function set_minHealth(value:Float):Float {
		if (healthBar != null && healthBar.min == minHealth)
			healthBar.setRange(minHealth, healthBar.max);
		return minHealth = value;
	}
	public var maxHealth(default, set):Float = 2;
	inline function set_maxHealth(value:Float):Float {
		if (healthBar != null && healthBar.max == maxHealth)
			healthBar.setRange(healthBar.min, value);
		return maxHealth = value;
	}
	public var health(default, set):Float;
	inline function set_health(value:Float):Float return health = FlxMath.bound(value, minHealth, maxHealth);

	public function new(game:PlayState):Void {
		super();
		direct = this;
		this.game = game;
		health = (maxHealth - minHealth) / 2;
		var downscroll:Bool = SaveManager.getOption('gameplay.downscroll');

		healthBarBG = new FlxSprite().loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(XY);
        healthBarBG.y += FlxG.height / 2.6 * (downscroll ? -1 : 1);
		add(healthBarBG);

		healthBar = new FunkinBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), 'health', 0, 2);
		healthBar.createFilledBar(game.dad.iconColor, game.boyfriend.iconColor);
		add(healthBar);

		iconP1 = new HealthIcon('bf', true);
		iconP2 = new HealthIcon('dad', false);
		for(icon in [iconP1, iconP2]) {
            icon.y = healthBar.y - (icon.height * .5);
			/* icon.screenCenter(Y);
			icon.y += FlxG.height / 2.6 * (downscroll ? 1 : -1); */
			add(icon);
		}

		add(StrumGroup.opponent = opponentStrumLine = new StrumGroup((FlxG.width * .5) - (FlxG.width * .25), 0, false));
		add(StrumGroup.player = playerStrumLine = new StrumGroup((FlxG.width * .5) + (FlxG.width * .25), 0, false));

		for (strumLine in [opponentStrumLine, playerStrumLine]) {
			for (strum in strumLine) {
				strum.screenCenter(Y);
				strum.y += FlxG.height / 2.7 * (downscroll ? 1 : -1);
			}
			strumLines.push(strumLine);
		}
	}

	public var updateIconPos:Bool = true;
	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (updateIconPos) {
			var iconOffset:Int = 26;
			var center:Float = healthBar.x + healthBar.width * FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0);
			iconP1.x = center - iconOffset;
			iconP2.x = center - (iconP2.width - iconOffset);
		}
	}

	override function destroy():Void {
		direct = null;
		game = null;
		super.destroy();
	}
}



/** original concept, made in psych lua
```lua
local function shared(downscroll)
	for index, value in pairs({'iconP1', 'iconP2', 'healthBar'}) do
		screenCenter(value, 'Y')
		setProperty(value .. '.y', getProperty(value .. '.y') + (screenHeight / 2.6) * (downscroll and -1 or 1))
	end
	for index, value in pairs({'timeBar', 'timeTxt', 'botplayTxt'}) do
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

function onCreatePost()
	local yCalc = shared(downscroll)
	makeLuaText('missesInfo', 'Misses: 0', screenWidth / 3.2, 0, yCalc[1] - yCalc[2])
	makeLuaText('accuracyInfo', 'Accuracy: 0% Start playing! (...)', screenWidth / 3.2, 0, yCalc[1] + yCalc[2])
	makeLuaText('scoreInfo', 'Score: 0', screenWidth / 3.2, 0, yCalc[1] - yCalc[2])
	addLuaText('missesInfo')
	addLuaText('accuracyInfo')
	addLuaText('scoreInfo')
	setTextFont('missesInfo', 'PhantomMuff.ttf')
	setTextFont('accuracyInfo', 'PhantomMuff.ttf')
	setTextFont('scoreInfo', 'PhantomMuff.ttf')

	setTextWidth('scoreTxt', 1) -- completely hide original
	screenCenter('accuracyInfo', 'x')
	setProperty('missesInfo.x', getProperty('accuracyInfo.x') - (screenWidth / 4.3))
	setProperty('scoreInfo.x', getProperty('accuracyInfo.x') + (screenWidth / 4.3))
end

function ChaSrlTyp_onUpdateHud(_, downscroll, _, _)
	local yCalc = shared(downscroll)
	setProperty('missesInfo.y', yCalc[1] - yCalc[2])
	setProperty('accuracyInfo.y', yCalc[1] + yCalc[2])
	setProperty('scoreInfo.y', yCalc[1] - yCalc[2])

	screenCenter('accuracyInfo', 'x')
	setProperty('missesInfo.x', getProperty('accuracyInfo.x') - (screenWidth / 4.3))
	setProperty('scoreInfo.x', getProperty('accuracyInfo.x') + (screenWidth / 4.3))
end

local percent = 0
function clamp(x, min, max) return math.max(min, math.min(x, max)) end
function onUpdate()
	percent = clamp(math.floor(rating * 100), 0, 100)
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
	if scoreZoom then
		cancelTween('scoreInfoZoomX')
		cancelTween('scoreInfoZoomY')
		scaleObject('scoreInfo', 1.2, 1.2, false)
		startTween('scoreInfoZoomX', 'scoreInfo.scale', {x = 1}, 0.2, {ease = 'bounceOut'})
		startTween('scoreInfoZoomY', 'scoreInfo.scale', {y = 1}, 0.2, {ease = 'smootherstepInOut'})
	end
end

local function sharedNoteMiss(membersIndex, noteData, noteType, isSustainNote)
	if scoreZoom then
		cancelTween('missesInfoTweens')
		scaleObject('missesInfo', getRandomFloat(0.7, 0.99), getRandomFloat(0.7, 0.99), false)
		setProperty('missesInfo.angle', getRandomFloat(-50, 50, '-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10'))
		startTween('missesInfoTweens', 'missesInfo', {['scale.x'] = 1, ['scale.y'] = 1, angle = 0}, 1, {ease = 'smootherstepInOut'})
	end
	cancelTween('missesInfoColor')
	setTextColor('missesInfo', 'ff0000')
	doTweenColor('missesInfoColor', 'missesInfo', 'ffffff', 1, 'smootherstepInOut')
end
function noteMiss(membersIndex, noteData, noteType, isSustainNote) sharedNoteMiss(membersIndex, noteData, noteType, isSustainNote) end
function noteMissPress(direction) sharedNoteMiss(nil, direction, '', false) end

function onCountdownTick(swagCounter) onBop(swagCounter) end
function onBeatHit() onBop(curBeat) end
function onBop(onPercent)
	local spedCalc = 0
	if scoreZoom then
		local spedLevel = {
			{90, 1},
			{70, 2},
			{50, 3},
			{30, 4},
			{0, 0}
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
		startTween('accuracyInfoZoomX', 'accuracyInfo.scale', {x = 1}, beatCalc, {ease = 'bounceOut'})
		startTween('accuracyInfoZoomY', 'accuracyInfo.scale', {y = 1}, beatCalc, {ease = 'smootherstepInOut'})
	end
end

function onRecalculateRating()
	setTextString('accuracyInfo', 'Accuracy: ' .. percent .. '% ' .. ratingName .. ' (' .. ratingFC .. ')')
end

function onUpdateScore(miss)
	setTextString(miss and 'missesInfo' or 'scoreInfo', miss and ('Misses: ' .. getMisses()) or ('Score: ' .. getScore()))
end
```
*/