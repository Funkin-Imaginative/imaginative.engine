function update(elapsed:Float):Void
	if (Settings.setup.debugMode && FlxG.keys.justPressed.TAB)
		BeatState.switchState(() -> new ModdedState('TestState', Conductor.song));