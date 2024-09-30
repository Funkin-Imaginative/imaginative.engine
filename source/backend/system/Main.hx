package backend.system;

import flixel.FlxGame;
import flixel.system.frontEnds.CameraFrontEnd;
import openfl.display.Sprite;
import thx.semver.Version;

class Main extends Sprite {
	public static var overlayCameras(default, null):CameraFrontEnd = @:privateAccess new CameraFrontEnd();

	/**
	 * Engine version.
	 */
	public static var engineVersion(default, null):Version;
	/**
	 * Latest version.
	 */
	public static var latestVersion(default, null):Version;

	public function new():Void {
		super();

		engineVersion = lime.app.Application.current.meta.get('version');
		latestVersion = engineVersion;

		#if (debug && final)
		throw 'Please dont\' so debug and final at the same time.';
		#else
		Controls.p1 = new Controls();
		Controls.p2 = new Controls();
		addChild(new FlxGame(states.TitleScreen, 60, 60));
		#end
	}
}