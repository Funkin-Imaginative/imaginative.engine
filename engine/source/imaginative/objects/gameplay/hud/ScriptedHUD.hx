package imaginative.objects.gameplay.hud;

import imaginative.objects.gameplay.hud.HUDTemplate.HUDType;

class ScriptedHUD extends HUDTemplate {
	override function get_type():HUDType
		return Custom;

	public var name:String;

	override function loadScript():Void
		for (script in Script.create('lead:content/huds/$name'))
			scripts.add(script);

	override public function new(name:String) {
		this.name = name;
		super();
	}
}