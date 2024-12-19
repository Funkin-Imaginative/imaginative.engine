package imaginative.objects.gameplay.hud;

class ScriptedHUD extends HUDTemplate {
	override function get_type():HUDType
		return Custom;
	public var name:String;

	override public function new(name:String) {
		this.name = name;
		super();
	}
}