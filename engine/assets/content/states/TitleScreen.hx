function update(elapsed:Float)
	if (SettingsConfig.setup.debugMode && FlxG.keys.justPressed.TAB)
		BeatState.switchState(new ScriptedState('TestState', Conductor.song));