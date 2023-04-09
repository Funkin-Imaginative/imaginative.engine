package options;

class GraphicsSettingsSubState extends BaseOptionsMenu {
	public function new() {
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence

		// I'd suggest using 'Low Quality' as an example for making your own option since it is the simplest here
		var option:Option = new Option(
			'Low Quality', // Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', // Description
			'qualityLevel', // Save data variable name
			'float', // Variable type
			1 // Default value
		);
		option.scrollSpeed = 5;
		option.minValue = 0;
		option.maxValue = 1;
		option.changeValue = 0.01;
		addOption(option);

		var option:Option = new Option(
			'Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			'bool',
			true
		);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; // Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option(
			'Shaders', // Name
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', // Description
			'shaders', // Save data variable name
			'bool', // Variable type
			true // Default value
		);
		addOption(option);

		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option(
			'Framerate',
			'Pretty self explanatory, isn\'t it?',
			'maxFramerate',
			'int',
			60
		);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
	}

	function onChangeAntiAliasing() {
		for (sprite in members) {
			var sprite:Dynamic = sprite; // Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; // Don't judge me ok
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) sprite.antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	function onChangeFramerate() {
		if (ClientPrefs.data.maxFramerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = ClientPrefs.data.maxFramerate;
			FlxG.drawFramerate = ClientPrefs.data.maxFramerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.maxFramerate;
			FlxG.updateFramerate = ClientPrefs.data.maxFramerate;
		}
	}
}