package imaginative.objects.holders;

class CharacterHolder extends BeatGroup {
	/**
	 * The conductor the arrow field follows.
	 */
	public var conductor(get, default):Conductor;
	inline function get_conductor():Conductor
		return conductor ?? Conductor.mainInstance;

	public var tagName(default, null):String;

	public var characters:Map<String, BeatSpriteGroup> = new Map<String, BeatSpriteGroup>();

	override public function new() {
		super();
	}
}