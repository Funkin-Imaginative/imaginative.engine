package imaginative.backend.gameplay;

import flixel.graphics.FlxGraphic;
import flixel.system.debug.GraphicConsole;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;

/**
 * Simple group used for rendering the camera position debug visuals.
 */
class CameraDebugCrosshair extends FlxGroup {
	var thePosition:Void->Array<Float>;
	var chBox:FlxSprite;
	/**
	 * Used for showing where the characters camera position is.
	 */
	public var crosshair:FlxSprite;

	override public function new(func:Void->Array<Float>) {
		super();

		thePosition = func;

		chBox = new FlxSprite().makeSolid(50, 50, FlxColor.BLACK);
		chBox.antialiasing = false;
		chBox.alpha = 0.3;
		chBox.angle = 45;
		add(chBox);

		crosshair = new FlxSprite(FlxGraphic.fromClass(GraphicCursorCross));
		crosshair.setGraphicSize(40, 40);
		crosshair.updateHitbox();
		crosshair.antialiasing = false;
		add(crosshair);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var camPos = thePosition();
		crosshair.setPosition(camPos[0] - (crosshair.width / 2), camPos[1] - (crosshair.height / 2));
		chBox.setPosition(crosshair.x - 5, crosshair.y - 5);
	}
}