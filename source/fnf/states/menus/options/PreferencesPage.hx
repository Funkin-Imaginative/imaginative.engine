package fnf.states.menus.options;

class PreferencesPage extends PageTemplate {
	override public function new() {
		super('prefs');
	}

	override public function onPrefCreation() {
		createPrefItem('Auto Pause', 'autoPause', true);
		createPrefItem('FPS Counter', 'showFpsCounter', false);
		createPrefItem('StrumLine Shift', 'strumShift', false);
		createPrefItem('Sustain Notes under StrumLine', 'sustainsUnderStrums', false);
	}
}