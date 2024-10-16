import backend.configs.ModConfig;
import backend.scripting.GlobalScript;
import states.menus.MainMenu;

function postUpdate(elapsed:Float) {
	if (FlxG.keys.justPressed.F1)
		trace('test');

	if (FlxG.keys.justPressed.F5)
		FlxG.resetState();

	if (FlxG.keys.justPressed.F6)
		FlxG.switchState(new MainMenu());

	if (FlxG.keys.justPressed.F7)
		if (GlobalScript.scripts.length > 0) {
			trace('Reloading global script...');
			GlobalScript.scripts.reload();
			trace('Global script successfully reloaded.');
		} else {
			trace('Loading global script...');
			GlobalScript.loadScript(ModConfig.curSolo);
		}
}