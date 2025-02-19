package imaginative.objects.gameplay.hud;

import imaginative.objects.ui.Bar;

enum abstract HUDType(String) from String to String {
	var Template;
	var VSlice;
	var Kade;
	var Psych;
	var Codename;
	var Imaginative;
	var Custom;
}

class HUDTemplate extends BeatGroup {
	public var type(get, never):HUDType;
	function get_type():HUDType
		return Template;

	// for an easier time layering
	/**
	 * Contains all hud elements like the health bar and icons.
	 */
	public var elements:BeatGroup = new BeatGroup();
	// public var combo:BeatGroup = new BeatGroup();
	/**
	 * Contains all existing ArrowFields.
	 * Well it doesn't really have to contain *all* of them.
	 */
	public var fields:BeatTypedGroup<ArrowField> = new BeatTypedGroup<ArrowField>();

	// hud specific shit
	public var healthBar:Bar;
	public var statsText:FlxText;

	/**
	 * Returns the field y level for the hud.
	 * @param downscroll If the position should be downscroll.
	 * @param field Optional, you can include a field instance.
	 *              Is used for some of the huds.
	 * @return `Float` ~ The field y level.
	 */
	public function getFieldYLevel(downscroll:Bool = false, ?field:ArrowField):Float {
		var yLevel:Float = (FlxG.camera.height / 2) - ((FlxG.camera.height / 2.6) * (downscroll ? -1 : 1));
		return call(true, 'onGetFieldY', [downscroll, yLevel], yLevel);
	}

	// scripting shiz
	/**
	 * Scripts that can effect the hud.
	 */
	public var scripts:ScriptGroup;
	inline function getScripts(?hudOnly:Bool):Array<Script> {
		var _scripts:Array<Script> = [];
		// adds song scripts
		if (!hudOnly || hudOnly == null)
			if (PlayState.direct != null && PlayState.direct.scripts != null)
				for (script in PlayState.direct.scripts)
					_scripts.push(script);
		// adds hud scripts
		if (hudOnly || hudOnly == null)
			for (script in scripts)
				_scripts.push(script);
		return _scripts;
	}
	/**
	 * Call's a function in the script instance.
	 * @param hudOnly If true, it only calls this for hud scripts.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @param def If it's null, then return this.
	 * @return `Dynamic` ~ Whatever is in the functions return statement.
	 */
	public function call(?hudOnly:Bool, func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		for (script in getScripts())
			if (script != null)
				return script.call(func, args) ?? def;
		return def;
	}
	/**
	 * Call's a function in the script instance and triggers an event.
	 * @param hudOnly If true, it only calls this for hud scripts.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	@:access(imaginative.backend.scripting.events.ScriptEvent.continueLoop)
	public function event<SC:ScriptEvent>(?hudOnly:Bool, func:String, event:SC):SC {
		for (script in getScripts()) {
			if (!script.active) continue;
			event.returnCall = call(func, [event]);
			if (event.prevented && !event.continueLoop) break;
		}
		return event;
	}

	function loadScript():Void
		if (type != Template || type != Custom)
			/* if (Paths.folderExists('lead:content/huds/$type'))
				for (ext in Script.exts)
					for (file in Paths.readFolder(folder, ext))
						for (script in Script.create(file))
							scripts.add(script);
			else */
				for (script in Script.create('lead:content/huds/${type}HUD'))
					scripts.add(script);

	public var health:Float = 1;

	function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, Settings.setupP1.downscroll ? FlxG.camera.height * 0.1 : FlxG.camera.height * 0.9).makeGraphic(600, 20, FlxColor.BLACK);
		bg.screenCenter(X);
		elements.add(bg);

		var bar:Bar = new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'health', 0, 2);
		bar.createFilledBar(FlxColor.RED, FlxColor.YELLOW);
		bar.screenCenter(X);
		return bar;
	}
	function initStatsText():FlxText {
		var text:FlxText = new FlxText(healthBar.x + healthBar.width - 190, healthBar.y + 30, 0, '', 20);
		text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		return text;
	}

	function createElements():Void {
		healthBar = initHealthBar();
		elements.add(healthBar);

		statsText = initStatsText();
		elements.add(statsText);
		updateStatsText();
	}

	override public function new() {
		super();

		scripts = new ScriptGroup(this);
		loadScript();
		scripts.load();
		call(true, 'create');

		createElements();

		add(elements);
		add(fields);
	}

	public function updateStatsText():Void {
		statsText.text = 'Score: ${Scoring.statsP1.score.formatMoney(false)}';
	}

	var _fields(null, null):Array<ArrowField>;
	@:access(flixel.FlxCamera._defaultCameras)
	override public function draw():Void {
		var i:Int = 0;
		var basic:FlxBasic = null;

		var oldDefaultCameras = FlxCamera._defaultCameras;
		if (cameras != null)
			FlxCamera._defaultCameras = cameras;

		while (i < length) {
			basic = members[i++];
			if (basic != null && basic.exists && basic.visible)
				if (basic == fields) {
					var i:Int = 0;
					var basic:FlxBasic = null;

					// orders the player and enemy fields above all
					_fields = fields.members.copy().filter((field:ArrowField) -> return field.status == null);
					var bot:ArrowField = ArrowField.enemyPlay ? ArrowField.player : ArrowField.enemy;
					if (bot != null)
						_fields.insert(0, bot);
					var top:ArrowField = ArrowField.enemyPlay ? ArrowField.enemy : ArrowField.player;
					if (top != null)
						_fields.insert(0, top);

					while (i < _fields.length) {
						basic = _fields[i++];
						if (basic != null && basic.exists && basic.visible)
							basic.draw();
					}
				} else basic.draw();
		}

		FlxCamera._defaultCameras = oldDefaultCameras;
	}
}