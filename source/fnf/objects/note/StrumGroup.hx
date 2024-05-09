package fnf.objects.note;

class StrumGroup extends FlxTypedGroup<Strum> {
	override public function new(x:Float, y:Float, pixel:Bool = false) {
		super();
		var amount:Int = 4;
		for (i in 0...amount) {
			var babyArrow:Strum = new Strum(x - (Note.swagWidth / 2), y, i, pixel);
			babyArrow.x += Note.swagWidth * i;
			babyArrow.x -= (Note.swagWidth * ((amount - 1) / 2));
			if (SaveManager.getOption('gameplay.strumShift')) babyArrow.x -= Note.swagWidth / 2.4;
			insert(i, babyArrow);
		}
	}
}