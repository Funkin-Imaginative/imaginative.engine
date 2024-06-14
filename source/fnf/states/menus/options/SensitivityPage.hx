package fnf.states.menus.options;

class SensitivityPage extends PageTemplate {
	public function new() {
		super('sensitivity');
	}

	override function onPrefCreation() {
		createPrefItem('Allow Naughtiness~', 'naughtiness', true);
		createPrefItem('VIOLENCE BABY', 'violence', true);
		createPrefItem('Allow Flashing Lights', 'flashingLights', true);
	}
}