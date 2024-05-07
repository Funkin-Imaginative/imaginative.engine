package fnf.states.menus.options;

class SensitivityPage extends PageTemplate {
	override public function new() {
		super('sensitivity');
	}

	override public function onPrefCreation() {
		createPrefItem('Allow Naughtiness~', 'naughtiness', true);
		createPrefItem('VIOLENCE BABY', 'violence', true);
		createPrefItem('Allow Flashing Lights', 'lights', true);
	}
}