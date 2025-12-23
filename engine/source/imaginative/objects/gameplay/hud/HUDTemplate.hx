package imaginative.objects.gameplay.hud;

import imaginative.objects.ui.Bar;

class HUDTemplate extends BeatGroup {
	/**
	 * The HUD type.
	 */
	public var type(get, never):HUDType;
	function get_type():HUDType
		return Template;

	// for an easier time layering
	/**
	 * Contains all hud elements like the health bar and icons.
	 */
	public var elements:BeatGroup = new BeatGroup();
	/**
	 * Contains all existing ArrowFields.
	 * Well it doesn't really have to contain *all* of them.
	 */
	public var fields:BeatTypedGroup<ArrowField> = new BeatTypedGroup<ArrowField>();

	// hud specific shit
	/**
	 * This bar tells you how much health you have left.
	 */
	public var healthBar:Bar;

	/**
	 * This this the stats text.
	 * It tells you what your stats are!
	 */
	public var statsText:FlxText;
	/**
	 * This this the stats text but for player 2.
	 * It tells you what player 2's stats are!
	 */
	public var statsP2Text:FlxText;

	/**
	 * The current amount of health.
	 */
	public var health(default, set):Float;
	inline function set_health(value:Float):Float
		return health = FlxMath.bound(value, minHealth, maxHealth);
	/**
	 * The visual amount of health.
	 */
	public var visualHealth(default, set):Float;
	inline function set_visualHealth(value:Float):Float
		return visualHealth = FlxMath.bound(value, minHealth, maxHealth);
	/**
	 * The minimum amount of health possible.
	 */
	@:isVar public var minHealth(get, set):Float;
	inline function get_minHealth():Float
		return healthBar == null ? 0 : healthBar.min;
	inline function set_minHealth(value:Float):Float {
		if (healthBar != null)
			healthBar.setRange(value, healthBar.max);
		return minHealth = value;
	}
	/**
	 * The maximum amount of health possible.
	 */
	@:isVar public var maxHealth(get, set):Float;
	inline function get_maxHealth():Float
		return healthBar == null ? 2 : healthBar.max;
	inline function set_maxHealth(value:Float):Float {
		if (healthBar != null)
			healthBar.setRange(healthBar.min, value);
		return maxHealth = value;
	}

	/**
	 * Returns the field y level for the hud.
	 * @param downscroll If the position should be downscroll.
	 * @param field Is used for some of the huds. Forced to be required to avoid "Null Object Reference"s.
	 * @return Float ~ The field y level.
	 */
	public function getFieldYLevel(downscroll:Bool = false, field:ArrowField):Float {
		var yLevel:Float = 50;
		if (downscroll) yLevel = getDefaultCamera().height - yLevel - ArrowField.arrowSize;
		yLevel += (ArrowField.arrowSize / 2);
		return call(true, 'onFieldY', [downscroll, yLevel], yLevel);
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
			if (PlayState.instance != null && PlayState.instance.songScripts != null)
				PlayState.instance.songScripts.forEach(script -> _scripts.push(script));
		// adds hud scripts
		if (hudOnly || hudOnly == null)
			scripts.forEach(script -> _scripts.push(script));
		return _scripts;
	}
	/**
	 * Calls a function in the script instance.
	 * @param hudOnly If true it only calls this for hud scripts.
	 * @param func The name of the function to call.
	 * @param args Arguments of said function.
	 * @param def If it's null, then return this.
	 * @return Dynamic ~ Whatever is in the functions return statement.
	 */
	public function call(?hudOnly:Bool, func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		for (script in getScripts(hudOnly)) {
			// var commonValue:V;
			script.call(func, args);
		}
		return def;
	}
	/**
	 * Calls an event in the script instance.
	 * @param hudOnly If true it only calls this for hud scripts.
	 * @param func The name of the function to call.
	 * @param event The event class.
	 * @return ScriptEvent
	 */
	@:access(imaginative.backend.scripting.events.ScriptEvent.continueLoop)
	public function event<SC:ScriptEvent>(?hudOnly:Bool, func:String, event:SC):SC {
		for (script in getScripts(hudOnly)) {
			event.returnCall = script.call(func, [event]);
			if (event.prevented && !event.continueLoop) break;
		}
		return event;
	}

	function loadScript():Void
		if (type != Template || type != Custom)
			/* if (Paths.folderExists('lead:content/huds/$type'))
				for (ext in Script.exts)
					for (file in Paths.readFolder(folder, ext))
						for (script in Script.createMulti(file))
							scripts.add(script);
			else */
				for (script in Script.createMulti('lead:content/huds/${type}HUD'))
					scripts.add(script);

	function initHealthBar():Bar {
		// temp bg add
		var bg:FlxSprite = new FlxSprite(0, getDefaultCamera().height * 0.9).makeGraphic(600, 20, FlxColor.BLACK);
		bg.screenCenter(X);
		if (Settings.setupP1.downscroll)
			CodenameHUD.cneYLevel(bg);
		elements.add(bg);

		return new Bar(bg.x + 4, bg.y + 4, RIGHT_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), this, 'visualHealth', minHealth, maxHealth);
	}

	function initStatsText():FlxText {
		var text:FlxText = new FlxText((healthBar.x - 4) + (healthBar.width + 8) - 190, (healthBar.y - 4) + 30);
		text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		if (Settings.setupP1.downscroll)
			CodenameHUD.cneYLevel(text);
		return text;
	}
	function initStatsP2Text():FlxText {
		var text:FlxText = new FlxText((healthBar.x - 4) - (healthBar.width + 8) + 190, (healthBar.y - 4) + 30);
		text.setFormat(Paths.font('vcr').format(), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		if (Settings.setupP1.downscroll)
			CodenameHUD.cneYLevel(text);
		text.visible = ArrowField.enableP2;
		return text;
	}

	function createElements():Void {
		elements.add(healthBar = initHealthBar());
		elements.add(statsP2Text = initStatsP2Text());
		elements.add(statsText = initStatsText());
		call(true, 'onCreateElements');
		updateStatsText();
		updateStatsP2Text();
	}

	override public function new() {
		if (HUDType.instance == null)
			HUDType.instance = this;
		else {
			_log('A HUD already exists, killing new one.');
			destroy();
		}
		super();

		add(scripts = new ScriptGroup(this));
		loadScript();
		scripts.load();
		call(true, 'create');

		visualHealth = health = FlxMath.lerp(minHealth, maxHealth, 0.5);
		createElements();
		add(elements);
		add(fields);

		call(true, 'createPost');
	}

	// TODO: figure out script calls
	override public function update(elapsed:Float):Void {
		call(true, 'update', [elapsed]);
		super.update(elapsed);
		visualHealth = FunkinUtil.lerp(visualHealth, health, 0.15);
	}

	/**
	 * Should be called when stats change.
	 */
	public function updateStatsText():Void {
		statsText.text = 'Score:${Scoring.statsP1.score}';
		call('onUpdateStats', [Settings.setupP1, Scoring.statsP1]);
	}
	/**
	 * Should be called when stats change.
	 */
	public function updateStatsP2Text():Void {
		statsP2Text.text = 'Score:${Scoring.statsP2.score}';
		call('onUpdateStatsP2', [Settings.setupP2, Scoring.statsP2]);
	}

	var _fields(null, null):Array<ArrowField>;
	@:access(flixel.FlxCamera._defaultCameras)
	override public function draw():Void {
		var i:Int = 0;
		var basic:FlxBasic = null;

		var oldDefaultCameras = FlxCamera._defaultCameras;
		if (cameras != null)
			FlxCamera._defaultCameras = cameras;

		// MAYBE: Rework this.
		while (i < length) {
			basic = members[i++];
			if (basic != null && basic.exists && basic.visible)
				if (basic == fields) {
					var i:Int = 0;
					var basic:ArrowField = null;

					// orders the player and enemy fields above all
					_fields = fields.members.copy().filter((field:ArrowField) -> return field.status == null);
					var top:ArrowField = ArrowField.enemyPlay ? ArrowField.enemy : ArrowField.player;
					if (top != null)
						_fields.insert(0, top);
					var bot:ArrowField = ArrowField.enemyPlay ? ArrowField.player : ArrowField.enemy;
					if (bot != null)
						_fields.insert(0, bot);

					while (i < _fields.length) {
						basic = _fields[i++];
						if (basic != null && basic.exists && basic.visible)
							basic.draw();
					}
				} else basic.draw();
		}

		FlxCamera._defaultCameras = oldDefaultCameras;
	}

	override public function destroy():Void {
		if (HUDType.instance == this)
			HUDType.instance = null;
		super.destroy();
	}
}