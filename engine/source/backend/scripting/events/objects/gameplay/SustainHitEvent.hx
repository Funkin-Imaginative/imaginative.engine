package backend.scripting.events.objects.gameplay;

final class SustainHitEvent extends ScriptEvent {
	public var sustain:Sustain;
	public var id:Int;
	public var field:ArrowField;
	public var stopStrumConfirm:Bool = false;

	override public function new(sustain:Sustain, ?id:Int, ?field:ArrowField) {
		super();
		this.sustain = sustain;
		this.id = id ?? sustain.id;
		this.field = field ?? sustain.setField;
	}
}