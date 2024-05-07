package fnf.objects.note;

class StrumLine extends FlxTypedGroup<Strum> {
	override public function new(x:Float, y:Float, pixel:Bool = false, hate:Int) {
		super();
		for (i in 0...4) {
			var babyArrow:Strum = new Strum(Note.swagWidth * i, y, i, pixel);
			babyArrow.ID = i;
			babyArrow.playAnim('static', true);
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * hate);
			add(babyArrow);
		}
	}
}