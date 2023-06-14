package;

class DeadChar extends Character {
	public function new(char:String = 'bf', ?x:Float = 0, ?y:Float = 0) {
		super(char, x, y, true);
	}

	public var startedDeath:Bool = false;
	override function update(elapsed:Float) {
		if (!debugMode)
			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
				playAnim('deathLoop');

		super.update(elapsed);
	}
}