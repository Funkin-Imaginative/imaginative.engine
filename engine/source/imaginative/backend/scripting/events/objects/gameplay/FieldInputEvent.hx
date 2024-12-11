package imaginative.backend.scripting.events.objects.gameplay;

class FieldInputEvent extends ScriptEvent {
	/**
	 * The strum lane index.
	 */
	public var i(default, null):Int;
	/**
	 * Its just i but with % applied.
	 */
	public var iMod(get, never):Int;
	inline function get_iMod():Int
		return i % field.strumCount;
	/**
	 * The strum object instance.
	 */
	public var strum(default, null):Strum;
	/**
	 * The field the input is assigned to.
	 */
	public var field(default, null):ArrowField;
	inline function get_field():ArrowField
		return strum.setField;
	/**
	 * If true, a bind was pressed.
	 */
	public var hasHit(default, null):Bool;
	/**
	 * If true, a bind is being held.
	 */
	public var beingHeld(default, null):Bool;
	/**
	 * If true, a bind was released.
	 */
	public var wasReleased(default, null):Bool;
	/**
	 * The player settings instance.
	 */
	public var settings(default, null):PlayerSettings;

	public var stopStrumPress:Bool = false;

	override public function new(?i:Int, strum:Strum, ?field:ArrowField, hasHit:Bool, beingHeld:Bool, wasReleased:Bool, settings:PlayerSettings) {
		super();
		this.i = i ??= strum.id;
		this.strum = strum;
		this.field = field ??= strum.setField;
		this.hasHit = hasHit;
		this.beingHeld = beingHeld;
		this.wasReleased = wasReleased;
		this.settings = settings;
	}
}