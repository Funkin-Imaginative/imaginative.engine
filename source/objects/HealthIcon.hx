package objects;

class HealthIcon extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var char:String = ''; // Uh?

	public var hasLosing:Bool = true;
	public var hasWinning:Bool = false;
	public var isAnimated:Bool = false;

	public function new(char:String = 'bf', ?hasLosing:Bool = true, ?hasWinning:Bool = false, ?customStates:Array<String>) {
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
		if (isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if (this.char != char) {
			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/face'; //Prevents crash from missing icon
			isAnimated = Paths.fileExists('images/' + name + '.xml', IMAGE);
			var file:Dynamic = Paths.image(name);
			
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

			animation.play('Neutral');
			this.char = char;
			antialiasing = ClientPrefs.data.antialiasing;
			if (char.endsWith('-pixel')) antialiasing = false;
		}
	}

	override function updateHitbox() {
		super.updateHitbox();
		if (isAnimated) {} else {
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?startFrame:Int = 0) {
		if (isAnimated) {}
		animation.play(anim, force, reversed, startFrame);
	}

	public function getCharacter():String {return char;} // Why does this exist???
}