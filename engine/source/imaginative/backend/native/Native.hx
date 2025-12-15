package imaginative.backend.native;

import lime.system.Display;
import lime.system.System;

@:buildXml('<include name="../../../../engine/source/imaginative/backend/native/build.xml" />')
@:include('native.hpp')
/**
 * Basically taken from psych since idk how tf to avoid the issue :sob:.
 * https://github.com/ShadowMario/FNF-PsychEngine/commit/7fa4f9c89526241ca4926b81b2a04661ab2e91f4
 * https://github.com/ShadowMario/FNF-PsychEngine/commit/ecdb1a037a20bd16275981f0afd0b37aea79c53c
 */
@SuppressWarnings('checkstyle:FieldDocComment')
extern class Native {
	#if windows
	public static function __init__():Void
		registerDPIAware();

	@:native('native::registerDPIAware')
	static function registerDPIAware():Void;

	@:native('native::fixScaling')
	private static function _fixScaling():Void;

	@:native('native::fixedScaling')
	private static var fixedScaling:Bool;

	static var fixedScaling:Bool = false;
	public static function fixScaling():Void {
		if (fixedScaling) return;
		fixedScaling = true;

		#if windows
		final display:Null<Display> = System.getDisplay(0);
		if (display != null) {
			final dpiScale:Float = display.dpi / 96;
			FlxWindow.instance.self.width = Std.int(Main.initialWidth * dpiScale);
			FlxWindow.instance.self.height = Std.int(Main.initialHeight * dpiScale);
			FlxWindow.instance.screenCenter();
		}

		_fixScaling();
		#end
	}

	#elseif linux
	@:native('native::getMonitorRefreshRate')
	static function getLinuxMonitorRefreshRate():cpp.Int16;
	#end
}