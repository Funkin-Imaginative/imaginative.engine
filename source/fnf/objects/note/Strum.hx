package fnf.objects.note;

import fnf.graphics.shaders.ColorSwap;

class Strum extends FlxSprite {
	public var extra:Map<String, Dynamic> = [];

	public var strumGroup(default, null):StrumGroup;
	@:unreflective private static function setStrumGroup(strum:Strum, group:StrumGroup) strum.strumGroup = group;
	public var cpu(get, never):Bool; function get_cpu():Bool return strumGroup.status == null || (strumGroup.status == PlayUtil.opponentPlay && !PlayUtil.enableP2) || PlayUtil.botplay;

	// public var colorSwap:ColorSwap;
	public var noteData(get, set):Int;
	inline function get_noteData():Int return ID;
	inline function set_noteData(value:Int):Int return ID = value;
	public var lastHit:Float = Math.NEGATIVE_INFINITY;

	public var baseScaling:PositionMeta;
	public var applyScaling(get, default):Bool = false;
	function get_applyScaling():Bool return baseScaling == null ? false : applyScaling;

	public var scaleMult:PositionMeta = new PositionMeta(1, 1);

	var col(get, never):String; function get_col():String return ['purple', 'blue', 'green', 'red'][ID];
	var dir(get, never):String; function get_dir():String return ['left', 'down', 'up', 'right'][ID];
	public function new(x:Float, y:Float, data:Int, pixel:Bool = false) {
		super(x, y);

		// colorSwap = new ColorSwap();
		// shader = colorSwap.shader;
		ID = data;

		if (pixel) {
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

			animation.add('note', [data + 4]);

			animation.add('static', [data], 24);
			animation.add('press', [data + 4, data + 8], 24, false);
			animation.add('confirm', [data + 12, data + 16], 24, false);
		} else {
			frames = Paths.getSparrowAtlas('notes/NOTE_assets');

			animation.addByPrefix('note', '${col}0');

			animation.addByPrefix('static', 'arrow${dir.toUpperCase()}', 24);
			animation.addByPrefix('press', '$dir press', 24, false);
			animation.addByPrefix('confirm', '$dir confirm', 24, false);
		}
		antialiasing = !pixel;
		setGraphicSize(Std.int(width * (pixel ? PlayState.daPixelZoom : 0.7)));
		updateHitbox();

		baseScaling = new PositionMeta(scale.x, scale.y);
		applyScaling = true;
		playAnim('static', true);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (applyScaling) scale.set(baseScaling.x * scaleMult.x, baseScaling.y * scaleMult.y);

		if (cpu && lastHit + (Conductor.crochet / 2) < Conductor.songPosition && animation.name == 'confirm' && animation.curAnim.finished) playAnim('static', true);
	}

	public function playAnim(name:String, force:Bool = false) {
		animation.play(name, force);
		centerOffsets();
		centerOrigin();
		if (name == 'confirm') lastHit = Conductor.songPosition;
	}
}