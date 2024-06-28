package fnf.objects.note;

import fnf.graphics.shaders.ColorSwap;

class Strum extends FlxSprite implements INoteTriggers implements IReloadable {
	public var extra:Map<String, Dynamic> = [];

	public var strumGroup(default, null):StrumGroup;
	@:unreflective inline private static function setStrumGroup(strum:Strum, group:StrumGroup) strum.strumGroup = group;
	public var cpu(get, never):Bool; function get_cpu():Bool return strumGroup.status == null || (strumGroup.status == PlayUtil.enemyPlay && !PlayUtil.enableP2) || PlayUtil.botplay;

	// public var colorSwap:ColorSwap;
	public var data:Int;
	public var safedata(get, set):Int; // mod safety precaction
	inline function get_safedata():Int return strumGroup == null ? data : data % strumGroup.length - 1;
	inline function set_safedata(value:Int):Int return data = value; // ¯\_(ツ)_/¯
	public var lastHit:Float = Math.NEGATIVE_INFINITY;

	public var applyScaling(get, default):Bool = false;
	function get_applyScaling():Bool return baseScale == null ? false : applyScaling;
	private var baseScale:PositionMeta = new PositionMeta(0.7, 0.7);
	public function setBaseScale(func:Void->Void) {
		var prev:Bool = applyScaling; applyScaling = false;
		if (func != null) func();
		updateHitbox();
		baseScale.set(scale.x, scale.y);
		applyScaling = prev;
	}
	public var scaleMult:PositionMeta = new PositionMeta(1, 1);

	public function new(x:Float, y:Float, data:Int, pixel:Bool = false) {
		super(x, y);

		// colorSwap = new ColorSwap();
		// shader = colorSwap.shader;
		this.data = data;
		var col:String = ['purple', 'blue', 'green', 'red'][data];
		var dir:String = ['left', 'down', 'up', 'right'][data];

		if (pixel) {
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

			animation.add('note', [data + 4]);

			animation.add('static', [data], 24);
			animation.add('press', [data + 4, data + 8], 24, false);
			animation.add('confirm', [data + 12, data + 16], 24, false);
		} else {
			frames = Paths.getSparrowAtlas('gameplay/notes/NOTE_assets');

			animation.addByPrefix('note', '${col}0');

			animation.addByPrefix('static', 'arrow${dir.toUpperCase()}', 24);
			animation.addByPrefix('press', '$dir press', 24, false);
			animation.addByPrefix('confirm', '$dir confirm', 24, false);
		}
		antialiasing = !pixel;
		playAnim('static', true);

		setBaseScale(() -> setGraphicSize(Std.int(width * (pixel ? PlayState.daPixelZoom : 0.7))));
		applyScaling = true;
	}

	public var reloading(default, null):Bool = false;
	public function reload(hard:Bool = false) {
		lastHit = Math.NEGATIVE_INFINITY;
		if (hard) extra.clear();
		scaleMult.set(1, 1);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (applyScaling) scale.set(baseScale.x * scaleMult.x, baseScale.y * scaleMult.y);
		if (cpu && lastHit + (Conductor.crochet / 2) < Conductor.songPosition && animation.name == 'confirm' && animation.curAnim.finished) playAnim('static', true);
	}

	public function noteHit(event:NoteHitEvent) {
		if (SaveManager.getOption('beatLoop')) playAnim('confirm', true); else {
			if (!event.note.isSustain) playAnim('confirm', true);
			else lastHit = Conductor.songPosition;
		}
	}
	public function noteMiss(event:NoteMissEvent) {}
	public function generalMiss(event:MissEvent) {}

	public function playAnim(name:String, force:Bool = false) {
		animation.play(name, force);
		centerOffsets();
		centerOrigin();
		if (name == 'confirm') lastHit = Conductor.songPosition;
	}
}