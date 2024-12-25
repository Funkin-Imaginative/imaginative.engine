package imaginative.objects.gameplay.hud;

import flixel.ui.FlxBar;

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
	public var healthBar:FlxBar;
	public var statsText:FlxText;

	/**
	 * Returns the field y level for the hud.
	 * @param downscroll If the position should be downscroll.
	 * @param field Optional, you can include a field instance.
	 *              Is used for some of the huds.
	 * @return `Float` ~ The field y level.
	 */
	public function getFieldYLevel(downscroll:Bool = false, ?field:ArrowField):Float {
		var yLevel:Float = (FlxG.height / 2) - ((FlxG.height / 2.6) * (downscroll ? -1 : 1));
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

	var temp:Float = 1;
	override public function new() {
		super();

		scripts = new ScriptGroup(this);
		loadScript();
		scripts.load();
		call(true, 'create');

		healthBar = new FlxBar(0, 0, RIGHT_TO_LEFT, Std.int(600 - 8), Std.int(200 - 8), this, 'temp', 0, 2);
		healthBar.createFilledBar(FlxColor.RED, FlxColor.YELLOW);
		elements.add(healthBar);

		statsText = new FlxText(healthBar.x + healthBar.width - 190, healthBar.y + 30, 0, '', 20);
		statsText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		elements.add(statsText);

		add(elements);
		add(fields);
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