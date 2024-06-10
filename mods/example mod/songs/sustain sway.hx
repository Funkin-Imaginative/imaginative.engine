var range:Float = 5;
function create(elapsed:Float) {
	for (strumLine in strumLines) {
		for (note in strumLine.notes) {
			if (note.isSustain) {
				note.scrollAngle = FlxG.random.float(-range, range);
				note.extra.set('turnLeft', true);
			}
		}
	}
}
function update(elapsed:Float) {
	for (strumLine in strumLines) {
		// for (strum in strumLine.members) strum.screenCenter(FlxAxes.Y);
		for (note in strumLine.notes) {
			if (note.isSustain) {
				if (note.scrollAngle < -range) note.extra.set('turnLeft', true);
				if (note.scrollAngle > range) note.extra.set('turnLeft', false);
				note.scrollAngle += (Conductor.stepCrochet / 1000) * (note.extra.get('turnLeft') ? 1 : -1);
			} else {
				// note.scrollAngle += (Conductor.stepCrochet / 1000);
			}
		}
	}
}