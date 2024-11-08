package objects.gameplay;

class ArrowField extends BeatGroup {
	/**
	 * Stores extra data that coders can use for cool stuff.
	 */
	public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();

	// Even tho you can have a but ton of ArrowField's you can ONLY play as one!
	/**
	 * The main enemy field.
	 */
	public static var enemy:ArrowField;
	/**
	 * The main player field.
	 */
	public static var player:ArrowField;
	/**
	 * States if its the main enemy or player field.
	 * False is the enemy, true is the player, and null is neither.
	 */
	public var status(get, set):Null<Bool>;
	inline function get_status():Null<Bool> {
		if (this == enemy) return false;
		if (this == player) return true;
		return null;
	}
	inline function set_status(value:Null<Bool>):Null<Bool> {
		switch (value) {
			case false:
				if (enemy == player) swapTargetFields();
				else enemy = this;
			case true:
				if (player == enemy) swapTargetFields();
				else player = this;
			case null:
				var prevStatus:Null<Bool> = status; // jic
				if (prevStatus != null) prevStatus ? player = null : enemy = null;
		}
		return status;
	}
	/**
	 * Swaps the current enemy and player field's around.
	 * I guess you could look at this like it triggers enemy play.
	 * When it technically doesn't.
	 */
	inline public static function swapTargetFields():Void {
		var prevOppo:ArrowField = enemy;
		var prevPlay:ArrowField = player;
		enemy = prevPlay;
		player = prevOppo;
	}

	/**
	 * The strums of the field.
	 */
	public var strums:BeatTypedGroup<Strum> = new BeatTypedGroup<Strum>();
	/**
	 * The notes of the field.
	 */
	public var notes:BeatTypedGroup<Note> = new BeatTypedGroup<Note>();

	/**
	 * The amount of strums in the field.
	 * Forced to 4 for now.
	 */
	public var strumCount(default, set):Int;
	inline function set_strumCount(value:Int):Int
		return strumCount = 4;//Std.int(FlxMath.bound(value, 1, 9));

	override public function new(x:Float = 0, y:Float = 0, mania:Int = 4) {
		strumCount = mania;
		super();

		for (i in 0...strumCount)
			strums.add(new Strum(this, i));
		setStrumPositions(x, y);

		add(strums);
		add(notes);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!PlayConfig.botplay && status != null && PlayConfig.enableP2) {
			var controls:Controls = status != PlayConfig.enemyPlay ? Controls.p1 : Controls.p2;
			for (i => strum in strums.members) {
				final hasHit:Bool = [controls.noteLeft, controls.noteDown, controls.noteUp, controls.noteRight][i];
				final beingHeld:Bool = [controls.noteLeftHeld, controls.noteDownHeld, controls.noteUpHeld, controls.noteRightHeld][i];
				final wasReleased:Bool = [controls.noteLeftReleased, controls.noteDownReleased, controls.noteUpReleased, controls.noteRightReleased][i];

				if (beingHeld)
					strum.playAnim('press');
			}
		}
	}

	/**
	 * Set's the strum positions.
	 * @param x The x position.
	 * @param y The y position.
	 */
	public function setStrumPositions(x:Float = 0, y:Float = 0):Void {
		for (i => strum in strums.members) {
			strum.setPosition(x - (Note.baseWidth / 2), y);
			strum.x += Note.baseWidth * i;
			strum.x -= (Note.baseWidth * ((strumCount - 1) / 2));
			// if (SaveManager.getOption('strumShift')) strum.x -= Note.baseWidth / 2.4;
		}
	}

	/**
	 * Parses chart ArrowField information.
	 * @param info The chart ArrowField data.
	 */
	public function parse(info:Dynamic):Void {

	}
}