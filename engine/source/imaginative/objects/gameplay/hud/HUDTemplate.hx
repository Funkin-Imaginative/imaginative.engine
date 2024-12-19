package imaginative.objects.gameplay.hud;

enum abstract HUDType(String) from String to String {
	var Template;
	var Funkin; // idk how to name this yet but this is supposed to be funkin week 7
	var Kade;
	var Psych;
	var Codename;
	var VSlice;
	var Imaginative;
	var Custom;
}

class HUDTemplate extends BeatGroup {
	public var type(get, never):HUDType;
	function get_type():HUDType
		return Template;

	// for an easier time layering
	/**
	 * Contains all existing ArrowFields.
	 * Well it doesn't really have to contain *all* of them.
	 */
	public var fields:BeatTypedGroup<ArrowField> = new BeatTypedGroup<ArrowField>();
	/**
	 * Contains all hud elements like the health bar and icons.
	 */
	public var elements:BeatGroup = new BeatGroup();
	// public var combo:BeatGroup = new BeatGroup();

	/**
	 * Returns the field y level for the hud.
	 * @param downscroll If the position should be downscroll.
	 * @return `Float` ~ The field y level.
	 */
	public function getFieldYLevel(downscroll:Bool = false):Float {
		var yLevel:Float = (FlxG.height / 2) - ((FlxG.height / 2.6) * (downscroll ? -1 : 1));
		return call('onGetFieldY', [downscroll, yLevel], yLevel);
	}

	/**
	 * Scripts that can effect the hud.
	 */
	public var scripts:ScriptGroup;
	inline function getScripts():Array<Script> {
		var _scripts:Array<Script> = [];
		// adds song scripts
		if (PlayState.direct != null && PlayState.direct.scripts != null)
			for (script in PlayState.direct.scripts)
				_scripts.push(script);
		// adds hud scripts
		for (script in scripts)
			_scripts.push(script);
		return _scripts;
	}
	/**
	 * Call's a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @param def If it's null then return this.
	 * @return `Dynamic` ~ Whatever is in the functions return statement.
	 */
	public function call(func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		for (script in getScripts())
			if (script != null)
				return script.call(func, args) ?? def;
		return def;
	}
	/**
	 * Call's a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	@:access(imaginative.backend.scripting.events.ScriptEvent.continueLoop)
	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		for (script in getScripts()) {
			if (!script.active) continue;
			event.returnCall = call(func, [event]);
			if (event.prevented && !event.continueLoop) break;
		}
		return event;
	}

	override public function new() {
		super();

		scripts = new ScriptGroup(this);

		add(fields);
		add(elements);
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
					var bot:ArrowField = PlayConfig.enemyPlay ? ArrowField.player : ArrowField.enemy;
					if (bot != null)
						_fields.insert(0, bot);
					var top:ArrowField = PlayConfig.enemyPlay ? ArrowField.enemy : ArrowField.player;
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