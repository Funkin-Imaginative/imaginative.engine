import fnf.objects.background.TankmenBG;
import flixel.util.FlxSort;

var animationNotes:Array<Dynamic> = [];

function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);

function createPost() {
	final swagshit = Song.loadFromJson('Stress', 'picolol');

	final notes = swagshit.notes;
	for (section in notes)
		for (idk in section.sectionNotes)
			animationNotes.push(idk);

	TankmenBG.animationNotes = animationNotes;
	animationNotes.sort(sortAnims);

	singAnims = ['shoot1', 'shoot2', 'shoot3', 'shoot4'];
}

function update(elapsed:Float) {
	if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0]) {
		var noteData:Int = 1;
		if (animationNotes[0][1] > 2) noteData = 3;

		noteData += FlxG.random.int(0, 1);
		playSingAnim(noteData);
		animationNotes.shift();
	}
	// if (isAnimFinished()) playAnim(getAnimName(), false, false, animation.curAnim.frames.length - 3);
	if (getAnimName() == null || (StringTools.startsWith(getAnimName(), 'shoot') && isAnimFinished()))
		dance();
}