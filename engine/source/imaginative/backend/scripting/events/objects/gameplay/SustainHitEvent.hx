package imaginative.backend.scripting.events.objects.gameplay;

final class SustainHitEvent extends PlayAnimEvent {
	/**
	 * The field the sustain is assigned to.
	 */
	public var field:ArrowField;
	/**
	 * The parent strum instance.
	 */
	public var strum:Strum;
	/**
	 * The parent note instance.
	 */
	public var note:Note;
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
	 * If true, it prevents the comfirm animation from playing on the target strum.
	 */
	public var stopStrumConfirm:Bool = false;

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

	override public function new(sustain:Sustain, ?id:Int, ?field:ArrowField, force:Bool = true, ?suffix:String) {
		super('', force, IsSinging, suffix);
		this.sustain = sustain;
		this.id = id ??= sustain.id;
		this.field = field ??= sustain.setField;
		strum = sustain.setStrum;
		note = sustain.setHead;
	}
}