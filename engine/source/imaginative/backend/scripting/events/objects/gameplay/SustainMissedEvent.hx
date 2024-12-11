package imaginative.backend.scripting.events.objects.gameplay;

final class SustainMissedEvent extends PlayAnimEvent {
	/**
	 * The sustain instance.
	 */
	public var sustain:Sustain;
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
	 * The field the sustain is assigned to.
	 */
	public var field:ArrowField;
	/**
	 * If true, it prevents the press animation from playing on the target strum.
	 */
	public var stopStrumPress:Bool;

	/**
	 * The first assigned actor attached to the sustain.
	 */
	public var character(get, set):Character;
	inline function get_character():Character
		return characters[0];
	inline function set_character(value:Character):Character
		return characters[0] = value;
	/**
	 * The assigned actors attached to the sustain.
	 */
	public var characters(get, set):Array<Character>;
	inline function get_characters():Array<Character>
		return sustain.assignedActors;
	inline function set_characters(value:Array<Character>):Array<Character>
		return sustain.assignedActors = value;

	override public function new(sustain:Sustain, ?id:Int, ?field:ArrowField, stopStrumPress:Bool, force:Bool = true, ?suffix:String) {
		super('', force, HasMissed, suffix);
		this.sustain = sustain;
		this.id = id ??= sustain.id;
		this.field = field ??= sustain.setField;
		this.stopStrumPress = stopStrumPress;
	}
}