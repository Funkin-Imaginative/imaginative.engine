package fnf.objects.note.groups;

class NoteGroup extends FlxTypedGroup<Note> {
	public function new() {
		super();
	}

	public static function noteSortFunc(i, n1, n2):Int {
		if (n1.strumTime == n2.strumTime) {
			var level:Int = 0;
			if (n1.strumTime == n2.strumTime) n1.isSustainNote ? level++ : level--;
			if (n1.lowPriority && !n2.lowPriority) level++;
			else if (!n1.lowPriority && n2.lowPriority) level--;
			return level;
		}
		return FlxSort.byValues(FlxSort.DESCENDING, n1.strumTime, n2.strumTime);
	}
	public static function noteSortFunc_ArrayVer(n1, n2):Int {
		if (n1.strumTime == n2.strumTime) {
			var level:Int = 0;
			if (n1.strumTime == n2.strumTime) n1.isSustainNote ? level++ : level--;
			if (n1.lowPriority && !n2.lowPriority) level++;
			else if (!n1.lowPriority && n2.lowPriority) level--;
			return level;
		}
		return FlxSort.byValues(FlxSort.DESCENDING, n1.strumTime, n2.strumTime);
	}

	override public function add(basic:Note):Note {
		var toReturn:Note = super.add(basic);
		sortSelf();
		return toReturn;
	}

	public inline function sortSelf():Void sort(noteSortFunc);
}