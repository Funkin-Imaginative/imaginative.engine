package fnf.objects.note.groups;

class NoteGroup extends FlxTypedGroup<Note> {
	public function new() {
		super();
	}

	static function sortCode(n1:Note, n2:Note):Int {
		if (n1.strumTime == n2.strumTime) {
			var level:Int = 0;
			// n1.isSustain ? level++ : level--;
			if (n1.lowPriority && !n2.lowPriority) level++;
			else if (!n1.lowPriority && n2.lowPriority) level--;
			return level;
		}
		return FlxSort.byValues(FlxSort.DESCENDING, n1.strumTime, n2.strumTime);
	}
	public static function noteSortGroup(i:Int, n1:Note, n2:Note):Int return sortCode(n1, n2);
	public static function noteSortArray(n1:Note, n2:Note):Int return sortCode(n1, n2);

	override public function add(basic:Note):Note {
		var toReturn:Note = super.add(basic);
		sortSelf();
		return toReturn;
	}

	public inline function sortSelf():Void {
		sort(noteSortGroup);
		for (note in members)
			if (note.hasTail)
				note.tail.sort(noteSortArray);
	}
}