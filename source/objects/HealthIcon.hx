package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var char:String = '';

	public var hasLosing:Bool = true;
	public var hasWinning:Bool = false;
	public var isAnimated:Bool = false;

	public function new(char:String = 'bf', isAnimated:Bool = false, hasLosing:Bool = true, hasWinning:Bool = false) {
		super();
		isOldIcon = (char == 'bf-old');
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			var amount:Int = 2;
			if (hasWinning) amount = 3;
			
			loadGraphic(file); //Load stupidly first for getting the file size
			loadGraphic(file, true, Math.floor(width / amount), Math.floor(height)); //Then load it fr
			iconOffsets[0] = (width - 150) / amount;
			iconOffsets[1] = (width - 150) / amount;
			updateHitbox();
			
			animation.add(char, [0], 0, false);
			animation.add(char, [1], 0, false);
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.data.antialiasing;
			if(char.endsWith('-pixel')) antialiasing = false;
		}
	}

	override function updateHitbox() {
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function playAnim() {
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
