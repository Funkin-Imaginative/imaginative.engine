package imaginative.backend.scripting.events.objects.gameplay;

final class NoteHitEvent extends PlayAnimEvent {
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
	 * If true, it creates a splash instance.
	 */
	public var createSplash:Bool = true;
	/**
	 * If true, it creates a hold cover instance.
	 */
	public var createHoldCover:Bool;
	/**
	 * If true, it prevents the comfirm animation from playing on the target strum.
	 */
	public var stopStrumConfirm:Bool = false;

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

	override public function new(note:Note, ?id:Int, ?field:ArrowField, force:Bool = true, ?suffix:String) {
		createHoldCover = note.length != 0;
		super('', force, IsSinging, suffix);
		this.note = note;
		this.id = id ??= note.id;
		this.field = field ??= note.setField;
		strum = note.setStrum;
	}
}