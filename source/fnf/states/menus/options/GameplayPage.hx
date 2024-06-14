package fnf.states.menus.options;

class GameplayPage extends PageTemplate {
	public function new() {
		super('gameplay');
	}

	override function onPrefCreation() {
		createPrefItem('Downscroll', 'downscroll', false);
		createPrefItem('Ghost Tapping', 'ghostTapping', true);
		createPrefItem('Prevent Death Key', 'stopDeathKey', false);
		createPrefItem('Camera Bop Zooms', 'camZooming', true);
		createPrefItem('Notes Vwoosh Away', 'notesVwooshOnRestart', true);
	}
}