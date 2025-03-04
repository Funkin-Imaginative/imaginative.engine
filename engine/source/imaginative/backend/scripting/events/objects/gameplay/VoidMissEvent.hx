package imaginative.backend.scripting.events.objects.gameplay;

final class VoidMissEvent extends PlayAnimEvent {
	/**
	 * The field the void miss is assigned to.
	 */
	public var field:ArrowField;
	/**
	 * The strum that would be potentially affected by the miss.
	 * @return `Strum`
	 */
	public var strum(get, never):Strum;
	inline function get_strum():Strum
		return field.strums.members[id ?? idMod];

	/**
	 * The strum lane index.
	 */
	public var id:Int;
	/**
	 * Its just id but with % applied.
	 */
	public var idMod(get, never):Int;
	inline function get_idMod():Int
		return id % field.strumCount;

	/**
	 * If true, the player will have consequences for pressing a key for no reason.
	 */
	public var triggerMiss:Bool;
	/**
	 * If true, it prevents the press animation from playing on the target strum.
	 */
	public var stopStrumPress:Bool = false;
	/**
	 * If true, it prevents the miss animation from playing on the assigned characters.
	 */
	public var stopMissAnimation:Bool = false;

	/**
	 * The first assigned actor attached to the field.
	 * `This variable this a copy of the fields version.`
	 */
	public var character(get, set):Character;
	inline function get_character():Character
		return characters[0];
	inline function set_character(value:Character):Character
		return characters[0] = value;
	/**
	 * The assigned actors attached to the field.
	 * `This array this a copy of the fields version.`
	 */
	public var characters:Array<Character>;

	override public function new(ghostTapping:Bool, id:Int, field:ArrowField, force:Bool = true, ?suffix:String) {
		super('', force, HasMissed, suffix);
		triggerMiss = !ghostTapping;
		this.id = id;
		this.field = field;
		characters = field.assignedActors.copy();
	}
}