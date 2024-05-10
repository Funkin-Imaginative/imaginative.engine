package fnf.objects.note.groups;

class NoteGroup extends FlxTypedGroup<Note> {
	public var onUpdate:FlxTypedSignal<Dynamic->Void> = new FlxTypedSignal<Dynamic->Void>();
	public var onDelete:FlxTypedSignal<Dynamic->Void> = new FlxTypedSignal<Dynamic->Void>();

	public function new() {
		super();
	}
}