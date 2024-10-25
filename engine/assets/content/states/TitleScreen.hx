function update(elapsed:Float) {
	if (FlxG.keys.justPressed.TAB)
		BeatState.switchState(new ModState('TestState', Conductor.song));
}