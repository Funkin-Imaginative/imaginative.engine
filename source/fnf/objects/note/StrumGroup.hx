package fnf.objects.note;

class StrumGroup extends FlxTypedGroup<Strum> {
	override public function new(x:Float, y:Float, pixel:Bool = false, hate:Null<Int> = null) { // KEEP `hate` FOR NOW
		super();
		for (i in 0...4) {
			var babyArrow:Strum = new Strum(Note.swagWidth * i, y, i, pixel);
			babyArrow.ID = i;
			if (hate == null) {
				babyArrow.x = x - (Note.swagWidth / 2);
				babyArrow.x += Note.swagWidth * babyArrow.noteData;
				babyArrow.x -= (Note.swagWidth * ((length - 1) / 2));
			} else {
				babyArrow.x += 50;
				babyArrow.x += ((FlxG.width / 2) * hate);
			}
			add(babyArrow);
		}
	}
}