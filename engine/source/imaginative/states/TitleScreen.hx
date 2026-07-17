package imaginative.states;

class TitleScreen extends GameState {
	override function create():Void {
		super.create();
		if (!conductor.playing) {
			conductor.loadMusic('freakyMenu');
			conductor.fadeIn(4, 0.7);
		}
	}
}