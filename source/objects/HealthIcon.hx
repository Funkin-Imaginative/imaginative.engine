package objects;

typedef IconJson = {
	var scale:Float;
	var stateDetails:Array<StateInfo>;
	var antialiasing:Bool;
}

typedef StateInfo = {
	// Static
	var index:Int;
	// Animated
	var anim:String;
	var fps:Int;
	var loop:Bool;
	// General
	var name:String;
	var offsets:Array<Float>;
}

class HealthIcon extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	public var iconName:String = 'face';

	public var hasLosing:Bool = true;
	public var hasWinning:Bool = false;
	public var isAnimated:Bool = false;
	public var iconScale:Float = 1;
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animsArray:Array<StateInfo> = [];

	public function new(icon:String = 'bf', ?isPlaya:Bool = false) {
		super();
		animOffsets = new Map<String, Array<Dynamic>>();
		isOldIcon = (icon == 'bf-old');
		changeIcon(icon);
		flipX = isPlaya;
		scrollFactor.set();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if (isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private static function dummyJson(?isAnimated:Bool):IconJson {
		var antialiasing:Bool = PlayState.isPixelStage ? false : ClientPrefs.data.antialiasing;
		return if (isAnimated) {{
			scale: 1,
			stateDetails: [
				{
					index: -1,
					
					anim: 'Neutral',
					fps: 24,
					loop: false,
					
					name: 'Neutral',
					offsets: [0, 0]
				},
				{
					index: -1,
					
					anim: 'Losing',
					fps: 24,
					loop: false,
					
					name: 'Losing',
					offsets: [0, 0]
				},
				{
					index: -1,
					
					anim: 'Winning',
					fps: 24,
					loop: false,
					
					name: 'Winning',
					offsets: [0, 0]
				}
			],
			antialiasing: antialiasing
		}} else {{
			scale: 1,
			stateDetails: [
				{
					index: 0,
					
					anim: '',
					fps: 0,
					loop: false,
					
					name: 'Neutral',
					offsets: [0, 0]
				},
				{
					index: 1,
					
					anim: '',
					fps: 0,
					loop: false,
					
					name: 'Losing',
					offsets: [0, 0]
				},
				{
					index: 2,
					
					anim: '',
					fps: 0,
					loop: false,
					
					name: 'Winning',
					offsets: [0, 0]
				}
			],
			antialiasing: antialiasing
		}};
	}

	private var staleOffsets:Array<Float> = [0, 0];
	public function changeIcon(icon:String) {
		if (iconName != icon) {
			var name:String = icon;
			// if (!Paths.fileExists('images/icons/$name.png', IMAGE)) name = icon;
			if (!Paths.fileExists('images/icons/$name.png', IMAGE)) name = 'face'; //Prevents crash from missing icon
			
			isAnimated = Paths.fileExists('images/icons/$name.xml', IMAGE);
			var iconJson:IconJson = Paths.jsonParse('images/icons/$name.json', dummyJson(isAnimated), 'preload');
			iconScale = iconJson.scale;
			animsArray = iconJson.stateDetails;
			
			var file:Dynamic = Paths.image('icons/$name');
			if (animsArray != null && animsArray.length > 0) {
				for (anim in animsArray) {
					hasLosing = (anim.name == 'Losing');
					hasWinning = (anim.name == 'Winning');
				}
			}
			loadGraphic(file);
			if (isAnimated) {
				frames = Paths.getSparrowAtlas(name);
			} else {
				var amount:Int = 2;
				if (hasLosing && hasWinning) amount++;
				else if (!hasLosing && !hasWinning) --amount;
				
				loadGraphic(file, true, Math.floor(width / amount), Math.floor(height));
				staleOffsets[0] = (width - 150) / amount;
				staleOffsets[1] = (width - 150) / amount;
			}
			
			if (animsArray != null && animsArray.length > 0) {
				for (anim in animsArray) {
					var animAnim:String = anim.anim;
					var animName:String = anim.name;
					var animFps:Int = anim.fps;
					var animLoop:Bool = !!anim.loop; //Bruh
					if (isAnimated) animation.addByPrefix(animAnim, animName, animFps, animLoop);
					else animation.add(animName, [anim.index], animFps, animLoop);
					if (anim.offsets != null && anim.offsets.length > 1) addOffset(animAnim, anim.offsets[0], anim.offsets[1]);
				}
			}

			setGraphicSize(Std.int(width * iconScale));
			updateHitbox();
			playAnim('Neutral', true);
			iconName = icon;
			antialiasing = iconJson.antialiasing;
		}
	}

	override function updateHitbox() {
		super.updateHitbox();
		updateAnimOffset(animation.curAnim.name);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?startFrame:Int = 0) {
		if ((!hasLosing && anim == 'Losing') || (!hasWinning && anim == 'Winning')) anim = 'Neutral';
		animation.play(anim, force, reversed, startFrame);
		updateAnimOffset(anim);
	}

	private function updateAnimOffset(daAnim:String) {
		var daOffset = animOffsets.get(daAnim);
		if (!isAnimated) {
			daOffset[0] += staleOffsets[0];
			daOffset[1] += staleOffsets[1];
		}
		if (animOffsets.exists(daAnim)) offset.set(daOffset[0], daOffset[1]);
		else offset.set(0, 0);
	}
}