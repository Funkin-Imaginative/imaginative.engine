package imaginative.objects.holders;

class CharacterHolder extends BeatGroup {
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();

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