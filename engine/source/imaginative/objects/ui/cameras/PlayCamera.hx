package imaginative.objects.ui.cameras;

// TODO: Get this functioning.
class PlayCamera extends BeatCamera {
	override function beatSetup(thing:OneOfThree<BeatState, BeatSubState, Conductor>, speed:Float = 1):PlayCamera {
		super.beatSetup(thing, speed);
		return this;
	}
}