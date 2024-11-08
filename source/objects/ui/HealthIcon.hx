package objects.ui;

/**
 * This class is used for a character's health icon.
 */
final class HealthIcon extends BeatSprite implements ITexture<HealthIcon> {
	// Texture related stuff.
	override public function loadTexture(newTexture:ModPath):HealthIcon
		return cast super.loadTexture(newTexture);
	override public function loadImage(newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):HealthIcon
		return cast super.loadImage(newTexture, animated, width, height);
	override public function loadSheet(newTexture:ModPath):HealthIcon
		return cast super.loadSheet(newTexture);
}