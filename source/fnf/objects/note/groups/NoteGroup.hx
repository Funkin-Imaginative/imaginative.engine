package fnf.objects.note.groups;

class NoteGroup extends FlxTypedGroup<Note> {
	public var onUpdate:FlxTypedSignal<Dynamic->Void> = new FlxTypedSignal<Dynamic->Void>();
	public var onDelete:FlxTypedSignal<Dynamic->Void> = new FlxTypedSignal<Dynamic->Void>();

	public function new() {
		super();
	}

	public inline function sortSelf():Void {
		sort(function(i, n1, n2) {
			if (n1.strumTime == n2.strumTime) {
				var level:Int = 0;
				if (n1.strumTime == n2.strumTime) n1.isSustainNote ? level++ : level--;
				if (n1.lowPriority && !n2.lowPriority) level++;
				else if (!n1.lowPriority && n2.lowPriority) level--;
				return level;
			}
			return FlxSort.byValues(FlxSort.DESCENDING, n1.strumTime, n2.strumTime);
		});
	}
}