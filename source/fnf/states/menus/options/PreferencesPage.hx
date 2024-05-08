package fnf.states.menus.options;

class PreferencesPage extends PageTemplate {
	override public function new() {
		super('prefs');
	}

	override public function onPrefCreation() {
		createPrefItem('Auto Pause', 'autoPause', true);
		createPrefItem('FPS Counter', 'showFpsCounter', false);
		createPrefItem('Pause on Lost Focus', 'pauseOnLostFocus', false);
	}
}