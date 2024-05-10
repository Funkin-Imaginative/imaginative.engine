package fnf.objects.note.groups;

class SplashGroup extends FlxTypedGroup<Splash> {
	public var onSpawn:FlxTypedSignal<Dynamic->Void> = new FlxTypedSignal<Dynamic->Void>();
	public function new() {
		super(6);
	}
}