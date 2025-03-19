package imaginative.objects.gameplay.hud;

import imaginative.objects.ui.Bar;

class ImaginativeHUD extends HUDTemplate {
	override function get_type():HUDType
		return Imaginative;

	public var breakInfo:FlxText;
	public var accuracyInfo:FlxText;

	override public function getFieldYLevel(downscroll:Bool = false, field:ArrowField):Float {
		var yLevel:Float = (FlxG.camera.height / 2) + (FlxG.camera.height / 2.7) * (downscroll ? 1 : -1);
		return call(true, 'onGetFieldY', [downscroll, yLevel], yLevel);
	}

	override function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, (FlxG.camera.height / 2) + (FlxG.camera.height / 2.6) * (Settings.setupP1.downscroll ? -1 : 1)).makeGraphic(600, 20, FlxColor.BLACK);
		bg.y += bg.height / 2;
		bg.screenCenter(X);
		elements.add(bg);

		return new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'visualHealth', minHealth, maxHealth);
	}

	function calculateTextYs(?downscroll:Bool):Array<Float> {
		downscroll ??= Settings.setupP1.downscroll;
		return [
			Position.getObjMidpoint(healthBar).y + (50 * (downscroll ? 1 : -1)),
			10 * (downscroll ? 1 : -1)
		];
	}
	override function initStatsText():FlxText {
		var texts:Array<FlxText> = [];
		for (i in 0...3) {
			var yCalc:Array<Float> = calculateTextYs();
			var text:FlxText = new FlxText(0, yCalc[0] - (yCalc[1] * (i == 1 ? -1 : 1)), FlxG.camera.width / 3.2);
			text.setFormat(Paths.font('PhantomMuff/full letters').format(), 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			text.screenCenter(X);
			text.borderSize = 2;
			texts.push(text);
		}
		elements.add(breakInfo = texts[0]);
		elements.add(accuracyInfo = texts[1]);
		accuracyInfo.text = 'Accuracy: 0% Start playing! (...)';
		breakInfo.x = accuracyInfo.x - ((healthBar.width + 8) / 2);
		texts[2].x = accuracyInfo.x + ((healthBar.width + 8) / 2);
		return texts[2];
	}
	override function initStatsP2Text():FlxText {
		return new FlxText('', 0); // to prevent crashes
	}

	var range = {
		outer: [0.4, 0.6],
		inner: [0.3, 0.7]
	}
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var yCalc:Array<Float> = calculateTextYs();
		var healthPercent:Float = FunkinUtil.toPercent(healthBar.percent, 100, 1);
		breakInfo.y = FlxMath.lerp(yCalc[0] - yCalc[1], yCalc[0] + yCalc[1], FlxMath.bound(FlxMath.remapToRange(healthPercent, range.outer[1], 1, 0, 1), 0, 1));
		accuracyInfo.y = FlxMath.lerp(yCalc[0] - yCalc[1], yCalc[0] + yCalc[1], FlxMath.remapToRange(healthPercent < 0.5 ? FlxMath.bound(FlxMath.remapToRange(healthPercent, range.inner[0], 0, 0, 1), 0, 1) : FlxMath.bound(FlxMath.remapToRange(healthPercent, range.inner[1], 1, 0, 1), 0, 1), 1, 0, 0, 1));
		statsText.y = FlxMath.lerp(yCalc[0] + yCalc[1], yCalc[0] - yCalc[1], FlxMath.bound(FlxMath.remapToRange(healthPercent, range.outer[0], 0, 1, 0), 0, 1));
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		var spedCalc:Int = 0;
		if (true) {
			var spedLevel:Array<Array<Int>> = [
				[90, 1],
				[70, 2],
				[50, 3],
				[30, 4],
				[0, 0]
			];
			var value:Array<Int> = spedLevel[spedLevel.length - 1];
			for (i in 0...spedLevel.length) {
				value = spedLevel[i];
				if (100 >= value[0])
					spedCalc = value[1];
				else break;
			}
			if (spedCalc <= 69 && spedCalc >= 69)
				spedCalc = 1;
		}

		try {
			if (true && (curBeat % spedCalc == 0 || accuracyInfo.text.contains('(...)'))) {
				FlxTween.cancelTweensOf(accuracyInfo, ['scale.x', 'scale.y']);
				accuracyInfo.scale.set(1.2, 1.2);
				var beatCalc:Float = Conductor.direct.beatTime / 1000 / 2.3;
				FlxTween.tween(accuracyInfo, {'scale.x': 1}, beatCalc, {ease: FlxEase.bounceOut});
				FlxTween.tween(accuracyInfo, {'scale.y': 1}, beatCalc, {ease: FlxEase.smootherStepInOut});
			}
		} catch(error:haxe.Exception) {}
	}

	override public function updateStatsText():Void {
		breakInfo.text = 'Misses: ${(ArrowField.enemyPlay ? 0 : Scoring.statsP1.misses) + (ArrowField.enemyPlay ? Scoring.statsP2.misses : 0)}';
		// this is just visual, don't worry
		var accuracy:Float = ArrowField.enableP2 ? FlxMath.remapToRange(Scoring.statsP1.accuracy + Scoring.statsP2.accuracy, 0, 100, 0, 200) : (ArrowField.enemyPlay ? Scoring.statsP2.accuracy : Scoring.statsP1.accuracy);
		accuracyInfo.text = 'Accuracy: ${accuracy < 0 ? '-' : Std.string(Math.fround(accuracy * 100 * 100) / 100)}% Start playing! (...)';
		statsText.text = 'Score: ${(ArrowField.enemyPlay ? 0 : Scoring.statsP1.score) + (ArrowField.enemyPlay ? Scoring.statsP2.score : 0)}';
		call('onUpdateStats', [Settings.setupP1, Scoring.statsP1]);
	}
	override public function updateStatsP2Text() {
		updateStatsText();
		call('onUpdateStatsP2', [Settings.setupP2, Scoring.statsP2]);
	}
}

/**
```lua
---@param downscroll boolean
---@param onlymath? boolean
---@return table
local function shared(downscroll, onlymath)
	if onlymath == nil then onlymath = false end
	if not onlymath then
		for index, value in pairs({ 'iconP1', 'iconP2', 'healthBar' }) do
			screenCenter(value, 'Y')
			setProperty(value .. '.y', getProperty(value .. '.y') + (screenHeight / 2.6) * (downscroll and -1 or 1))
		end
		for index, value in pairs({ 'timeBar', 'timeTxt', 'botplayTxt' }) do
			screenCenter(value, 'Y')
			setProperty(value .. '.y', getProperty(value .. '.y') + (screenHeight / (value == 'botplayTxt' and 2.7 or 2.15)) * (downscroll and 1 or -1))
		end
		removeLuaSprite('botplayTxt', false, 'uiGroup')
		setObjectOrder('botplayTxt', getObjectOrder('grpNoteSplashes', 'noteGroup') + 1000, 'noteGroup')
		for i = 0, getProperty('strumLineNotes.length') - 1 do
			screenCenter('strumLineNotes.members[' .. i .. ']', 'Y')
			setPropertyFromGroup('strumLineNotes', i, 'y', getPropertyFromGroup('strumLineNotes', i, 'y') + (screenHeight / 2.7) * (downscroll and 1 or -1))
		end
	end

	return {
		getProperty('healthBar.y') + 50 * (downscroll and 1 or -1),
		10 * (downscroll and 1 or -1)
	}
end

-- This variable contains the range information for when the status texts should move!
local range = {
	-- States when the break and score texts should move.
	outer = {0.4, 0.6},
	-- States when the accuracy text should move.
	inner = {0.3, 0.7}
}
local breaksInfoDoesCombos = true
function onCreatePost()
	local yCalc = shared(downscroll)
	makeLuaText('breakInfo', (breaksInfoDoesCombos and 'Combo Breaks' or 'Misses') .. ': 0', screenWidth / 3.2, 0, yCalc[1] - yCalc[2])
	makeLuaText('accuracyInfo', 'Accuracy: 0% Start playing! (...)', screenWidth / 3.2, 0, yCalc[1] + yCalc[2])
	makeLuaText('scoreInfo', 'Score: 0', screenWidth / 3.2, 0, yCalc[1] - yCalc[2])
	setObjectOrder('breakInfo', getObjectOrder('scoreTxt', 'uiGroup'), 'uiGroup')
	setObjectOrder('accuracyInfo', getObjectOrder('scoreTxt', 'uiGroup'), 'uiGroup')
	setObjectOrder('scoreInfo', getObjectOrder('scoreTxt', 'uiGroup'), 'uiGroup')
	setTextFont('breakInfo', 'PhantomMuff.ttf')
	setTextFont('accuracyInfo', 'PhantomMuff.ttf')
	setTextFont('scoreInfo', 'PhantomMuff.ttf')

	setTextWidth('scoreTxt', 1) -- completely hide original
	screenCenter('accuracyInfo', 'x')
	setProperty('breakInfo.x', getProperty('accuracyInfo.x') - (getProperty('healthBar.width') / 2))
	setProperty('scoreInfo.x', getProperty('accuracyInfo.x') + (getProperty('healthBar.width') / 2))
end

function ChaSrlTyp_onUpdateHud(_, downscroll, _, _)
	local yCalc = shared(downscroll)
	setProperty('breakInfo.y', yCalc[1] - yCalc[2])
	setProperty('accuracyInfo.y', yCalc[1] + yCalc[2])
	setProperty('scoreInfo.y', yCalc[1] - yCalc[2])
end

local percent = 0
function lerp(to, from, ratio) return callMethodFromClass('flixel.math.FlxMath', 'lerp', {to, from, ratio}) end
function clamp(x, min, max) return math.max(min, math.min(x, max)) end
function onUpdate()
	percent = clamp(math.floor(rating * 100), 0, 100)
end

local function sharedNoteMiss(membersIndex, noteData, noteType, isSustainNote)
	if scoreZoom then
		cancelTween('breakInfoTweens')
		scaleObject('breakInfo', getRandomFloat(0.7, 0.99), getRandomFloat(0.7, 0.99), false)
		setProperty('breakInfo.angle', getRandomFloat(-50, 50, {-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}))
		startTween('breakInfoTweens', 'breakInfo', {['scale.x'] = 1, ['scale.y'] = 1, angle = 0 }, 1, {ease = 'smootherstepInOut'})
	end
	cancelTween('breakInfoColor')
	setTextColor('breakInfo', 'ff0000')
	doTweenColor('breakInfoColor', 'breakInfo', 'ffffff', 1, 'smootherstepInOut')
end
function noteMiss(membersIndex, noteData, noteType, isSustainNote) sharedNoteMiss(membersIndex, noteData, noteType, isSustainNote) end
function noteMissPress(direction) sharedNoteMiss(nil, direction, '', false) end

---@type number
local lerpScore = score
function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
	if scoreZoom and not isSustainNote then
		cancelTween('scoreInfoZoomX')
		cancelTween('scoreInfoZoomY')
		scaleObject('scoreInfo', 1.2, 1.2, false)
		startTween('scoreInfoZoomX', 'scoreInfo.scale', {x = 1}, 0.2, {ease = 'bounceOut'})
		startTween('scoreInfoZoomY', 'scoreInfo.scale', {y = 1}, 0.2, {ease = 'smootherstepInOut'})
	end
	if breaksInfoDoesCombos and (getPropertyFromGroup('notes', membersIndex, 'rating') == 'bad' or getPropertyFromGroup('notes', membersIndex, 'rating') == 'shit') then
		sharedNoteMiss(membersIndex, noteData, noteType, isSustainNote)
		onUpdateScore(true)
	end
	if getPropertyFromGroup('notes', membersIndex, 'tail.length') == 0 and not isSustainNote then
		lerpScore = score
		onUpdateScore(false)
	end
end

---Uses the arguments value and max to create a number that ranges the argument range. ex: toPercent(4, 10, 1) returns 0.4
---@param value number The current value of the percentage. ex: 4
---@param max number The max value of the the percentage. ex: 10
---@param range number The format of the percentage. ex: 1
---@return number result The percentage. ex: 0.4
function toPercent(value, max, range) return (value / max) * range end
---Remaps a number from one range to another.
---@param value number The incoming value to be converted.
---@param start1 number Lower bound of the value's current range.
---@param stop1 any Upper bound of the value's current range.
---@param start2 number Lower bound of the value's target range.
---@param stop2 number Upper bound of the value's target range.
---@return number result The remapped value.
function remapToRange(value, start1, stop1, start2, stop2) return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1)) end

function onUpdatePost(elapsed)
	if lerpScore ~= score then
		lerpScore = math.floor(lerp(score, lerpScore, callMethodFromClass('flixel.tweens.FlxEase', 'sineOut', {0.8})))
		onUpdateScore(false);
	end

	local yCalc = shared(downscroll, true)
	local healthPercent = toPercent(getProperty('healthBar.percent'), 100, 1)
	setProperty('breakInfo.y', lerp(yCalc[1] - yCalc[2], yCalc[1] + yCalc[2], clamp(remapToRange(healthPercent, range.outer[2], 1, 0, 1), 0, 1)))
	setProperty('accuracyInfo.y', lerp(yCalc[1] - yCalc[2], yCalc[1] + yCalc[2], remapToRange(healthPercent < 0.5 and clamp(remapToRange(healthPercent, range.inner[1], 0, 0, 1), 0, 1) or clamp(remapToRange(healthPercent, range.inner[2], 1, 0, 1), 0, 1), 1, 0, 0, 1)))
	setProperty('scoreInfo.y', lerp(yCalc[1] + yCalc[2], yCalc[1] - yCalc[2], clamp(remapToRange(healthPercent, range.outer[1], 0, 1, 0), 0, 1)))
	-- setHealth(remapToRange(0.1, 0, 1, 2, 0))
end

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
	local text = miss and (breaksInfoDoesCombos and 'Combo Breaks' or 'Misses') or 'Score'
	local info = miss and (misses + (breaksInfoDoesCombos and (getProperty('ratingsData[2].hits') + getProperty('ratingsData[3].hits')) or 0)) or lerpScore
	setTextString(miss and 'breakInfo' or 'scoreInfo', text .. ': ' .. tostring(info))
end
```
*/