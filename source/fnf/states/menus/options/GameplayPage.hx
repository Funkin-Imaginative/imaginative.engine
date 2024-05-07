package fnf.states.menus.options;

class GameplayPage extends PageTemplate {
	override public function new() {
		super('gameplay');
	}

	override public function onPrefCreation() {
		createPrefItem('Downscroll', 'downscroll', false);
		createPrefItem('Ghost Tapping', 'ghostTapping', true);
		createPrefItem('Prevent Death Key', 'stopDeathKey', false);
		createPrefItem('Camera Bop Zooming', 'camZooming', true);
		createPrefItem('Notes Vwoosh Away', 'doVwoosh', true);
	}
}