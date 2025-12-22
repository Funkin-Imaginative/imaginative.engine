package imaginative.objects.gameplay.hud;

import imaginative.objects.ui.Bar;

class ScriptedHUD extends HUDTemplate {
	override function get_type():HUDType
		return Custom;

	/**
	 * The name of the scripted HUD instance.
	 */
	public var name(default, null):String;
	override function loadScript():Void
		for (script in Script.createMulti('lead:content/huds/$name'))
			scripts.add(script);

	override function initHealthBar():Bar
		return call(true, 'onHealthBarInit', [Settings.setupP1.downscroll]) ?? super.initHealthBar(); // so it doesn't create a object that doesn't get used

	override function initStatsText():FlxText
		return call(true, 'onStatsTextInit', [Settings.setupP1.downscroll]) ?? super.initStatsText();
	override function initStatsP2Text():FlxText
		return call(true, 'onStatsTextInitP2', [Settings.setupP1.downscroll]) ?? super.initStatsP2Text();

	override function createElements():Void {
		call(true, 'onCreateElements');
		if (elements.length == 0) { // if blank, add for them
			elements.add(healthBar = initHealthBar());
			elements.add(statsP2Text = initStatsP2Text());
			elements.add(statsText = initStatsText());
		}
		updateStatsText();
		updateStatsP2Text();
	}

	override public function new(name:String) {
		this.name = name;
		super();
	}

	override public function updateStatsText():Void
		call('onUpdateStats', [Settings.setupP1, Scoring.statsP1]);
	override public function updateStatsP2Text():Void
		call('onUpdateStatsP2', [Settings.setupP2, Scoring.statsP2]);
}