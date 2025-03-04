package imaginative.backend.scripting.events.objects.gameplay;

final class NoteMissedEvent extends PlayAnimEvent {
	/**
	 * The field the note is assigned to.
	 */
	public var field:ArrowField;
	/**
	 * The parent strum instance.
	 */
	public var strum:Strum;
	/**
	 * The note instance.
	 */
	public var note:Note;

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
	 * If true, it prevents the press animation from playing on the target strum.
	 */
	public var stopStrumPress:Bool;

	/**
	 * The first assigned actor attached to the note.
	 */
	public var character(get, set):Character;
	inline function get_character():Character
		return characters[0];
	inline function set_character(value:Character):Character
		return characters[0] = value;
	/**
	 * The assigned actors attached to the note.
	 */
	public var characters(get, set):Array<Character>;
	inline function get_characters():Array<Character>
		return note.assignedActors;
	inline function set_characters(value:Array<Character>):Array<Character>
		return note.assignedActors = value;

	override public function new(note:Note, ?id:Int, ?field:ArrowField, stopStrumPress:Bool, force:Bool = true, ?suffix:String) {
		super('', force, HasMissed, suffix);
		this.note = note;
		this.id = id ??= note.id;
		this.field = field ??= note.setField;
		this.stopStrumPress = stopStrumPress;
		strum = note.setStrum;
	}
}