package;

class DeadChar extends Character {
	public function new(x:Float, y:Float, ?char:String = 'bf') {
		super(x, y, char, true);
	}

	public var startedDeath:Bool = false;
	override function update(elapsed:Float) {
		if (!debugMode) {
			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
				playAnim('deathLoop');
		}

		super.update(elapsed);
	}
}
