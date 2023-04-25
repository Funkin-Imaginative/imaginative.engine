package objects;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#else import openfl.utils.Assets; #end
import haxe.Json;

typedef IconJson = {
	var hasLosing:Bool;
	var hasWinning:Bool;

	var scale:Float;
	var stateDetails:Array<DetailArray>;
	var antialiasing:Bool;
}

typedef DetailArray = {
	var stateName:String
	var fps:Int;
	var loop:Bool;
	var offsets:Array<Int>;
}

class HealthIcon extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	public var iconName:String = ''; // Uh?

	public var hasLosing:Bool = true;
	public var hasWinning:Bool = false;
	public var isAnimated:Bool = false;

	public function new(icon:String = 'bf', ?isPlaya:Bool = false) {
		super();
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

	private static function dummyJson():IconJson {
		return {
			hasLosing: true,
			hasWinning: false,

			scale: 1,
			stateDetails: {
				fps: 24;
				loop: false
				offsets: [0.0, 0.0];
			},
			antialiasing: PlayState.isPixelStage ? false : ClientPrefs.data.antialiasing
		};
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(icon:String) {
		if (iconName != icon) {
			var name:String = icon;
			// if (!Paths.fileExists('images/icons/$name.png', IMAGE)) name = icon;
			if (!Paths.fileExists('images/icons/$name.png', IMAGE)) name = 'face'; //Prevents crash from missing icon
			var iconJson:IconJson = Paths.jsonParse('images/icons/$name.json', dummyJson(), 'preload');

			hasLosing = iconJson.hasLosing;
			hasWinning = iconJson.hasWinning;
			isAnimated = Paths.fileExists('images/icons/$name.xml', IMAGE);

			var file:Dynamic = Paths.image('icons/$name');
			loadGraphic(file);
			if (isAnimated) {
				frames = Paths.getSparrowAtlas(name);
				animation.addByPrefix('Neutral', 'Neutral', 24, false);
				if (hasLosing) animation.addByPrefix('Losing', 'Losing', 24, false);
				if (hasWinning) animation.addByPrefix('Winning', 'Winning', 24, false);
			} else {
				var amount:Int = 2;
				if (hasLosing && hasWinning) amount++;
				else if (!hasLosing && !hasWinning) --amount;
				
				loadGraphic(file, true, Math.floor(width / amount), Math.floor(height));
				iconOffsets[0] = (width - 150) / amount;
				iconOffsets[1] = (width - 150) / amount;
				animation.add('Neutral', [0], 0, false);
				if (hasLosing) animation.add('Losing', [1], 0, false);
				if (hasWinning) animation.add('Winning', [hasLosing ? 2 : 1], 0, false);
			}

			updateHitbox();
			playAnim('Neutral', true);
			iconName = icon;
			antialiasing = iconJson.antialiasing;
		}
	}

	override function updateHitbox() {
		super.updateHitbox();
		if (isAnimated) {
			
		} else {
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?startFrame:Int = 0) {
		if (isAnimated) {}
		animation.play(anim, force, reversed, startFrame);
	}

	public function getCharacter():String return iconName; // Why does this exist???
}