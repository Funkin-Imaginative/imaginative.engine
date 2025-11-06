package imaginative.backend.gameplay;

import flixel.graphics.FlxGraphic;

@:bitmap('assets/images/debugger/cursorCross.png')
private class GraphicCursorCross extends openfl.display.BitmapData {}
@:bitmap('assets/images/debugger/buttons/pointer.png')
private class PointerGraphic extends openfl.display.BitmapData {}

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
	/**
	 * Used to tell you where the crosshair is when it is off screen.
	 */
	public var offScreenArrow:FlxSprite;

	override public function new(func:Void->Array<Float>) {
		super();

		thePosition = func;

		chBox = new FlxSprite().makeGraphic(50, 50, FlxColor.BLACK);
		chBox.antialiasing = false;
		chBox.alpha = 0.5;
		chBox.angle = 45;
		add(chBox);

		crosshair = new FlxSprite(FlxGraphic.fromClass(GraphicCursorCross, './flixel/images/debugger/cursorCross.png'));
		crosshair.antialiasing = false;
		add(crosshair);

		offScreenArrow = new FlxSprite(FlxGraphic.fromClass(PointerGraphic, './flixel/images/debugger/buttons/pointer.png'));
		offScreenArrow.antialiasing = false;
		add(offScreenArrow);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var saidCamera = getDefaultCamera();

		crosshair.setGraphicSize(40 / saidCamera.zoom);
		crosshair.updateHitbox(); var camPos = thePosition();
		crosshair.setPosition(camPos[0] - (crosshair.width / 2), camPos[1] - (crosshair.height / 2));

		chBox.scale.set(1 / saidCamera.zoom, 1 / saidCamera.zoom);
		chBox.updateHitbox();
		chBox.setPosition(crosshair.x - (5 / saidCamera.zoom), crosshair.y - (5 / saidCamera.zoom));

		if (offScreenArrow.visible = !crosshair.isOnScreen()) {
			offScreenArrow.setGraphicSize(60 / saidCamera.zoom);
			offScreenArrow.updateHitbox();
			offScreenArrow.angle = FlxAngle.angleBetween(offScreenArrow, crosshair, true) + 135;
			offScreenArrow.setPosition(crosshair.x - (10 / saidCamera.zoom), crosshair.y - (10 / saidCamera.zoom));
			offScreenArrow.cameraBound();
		}
	}
}