import states.menus.MainMenu;

function postUpdate(elapsed:Float) {
	if (FlxG.keys.justPressed.F5) {
		trace('Reseting state...');
		FlxG.resetState();
		trace('Reset state successfully.');
	}

	if (FlxG.keys.justPressed.F6) {
		trace('Heading to MainMenu...');
		BeatState.switchState(new MainMenu());
		trace('Successfully entered MainMenu.');
	}

	if (FlxG.keys.justPressed.F7)
		if (GlobalScript.scripts.length > 0) {
			trace('Reloading global script...');
			GlobalScript.loadScript();
			trace('Global script successfully reloaded.');
		} else {
			trace('Loading global script...');
			GlobalScript.loadScript();
		}
}