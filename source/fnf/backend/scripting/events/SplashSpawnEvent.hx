package fnf.backend.scripting.events;

import fnf.objects.note.Splash;

final class SplashSpawnEvent extends ScriptEvent {
	public var splash:Splash;

	override public function new(splash:Splash) {
		super();
		this.splash = splash;
	}
}