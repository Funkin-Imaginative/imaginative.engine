function update(elapsed:Float) {
	if (FlxG.keys.justPressed.TAB)
		BeatState.switchState(new ScriptedState('TestState', Conductor.song));
}