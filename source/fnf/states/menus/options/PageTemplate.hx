package fnf.states.menus.options;

class PageTemplate extends OptionsState.Page { // this class is not used for ControlsPage
	var items:TextMenuList;
	var optionCategory:String;

	var checkboxes:Array<Checkbox> = [];
	var menuCamera:FunkinCamera;
	var camFollow:FlxObject;

	public function new(optionCategory:String) {
		super();

		menuCamera = new FunkinCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = 0x0;
		camera = menuCamera;

		add(items = new TextMenuList());
		this.optionCategory = optionCategory;
		onPrefCreation();

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null) camFollow.y = items.selectedItem.y;

		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;

		items.onChange.add(function(selected) {camFollow.y = selected.y;});
	}

	public function onPrefCreation() {}

	// easy shorthand
	private function getPref(pref:String):Dynamic return SaveManager.getOption('$optionCategory.$pref');
	private function setPref(pref:String, value:Dynamic):Dynamic return SaveManager.setOption('$optionCategory.$pref', value);

	private function createPrefItem(prefName:String, prefString:String, prefValue:Dynamic):Void {
		items.createItem(120, (120 * items.length) + 30, prefName, AtlasFont.Bold, function() {
			preferenceCheck(prefString, prefValue);
			switch (Type.typeof(prefValue).getName()) {
				case 'TBool': prefToggle(prefString);
				default: trace('swag');
			}
		});

		switch (Type.typeof(prefValue).getName()) {
			case 'TBool': createCheckbox(prefString);
			default: trace('swag');
		}

		trace(Type.typeof(prefValue).getName());
	}

	function createCheckbox(prefString:String) {
		var checkbox:Checkbox = new Checkbox(0, 120 * (items.length - 1), getPref(prefString));
		checkboxes.push(checkbox);
		add(checkbox);
	}

	/**
	 * Assumes that the preference has already been checked/set?
	 */
	private function prefToggle(prefName:String) {
		var daSwap:Bool = getPref(prefName);
		daSwap = !daSwap;
		setPref(prefName, daSwap);
		checkboxes[items.selectedIndex].daValue = daSwap;
		trace('toggled? ' + getPref(prefName));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		// menuCamera.followLerp = CoolUtil.camLerpShit(0.05);

		items.forEach(function(daItem:TextMenuItem) {
			daItem.x = items.selectedItem == daItem ? 150 : 120;
		});
	}

	private function preferenceCheck(prefString:String, prefValue:Dynamic):Void {
		if (getPref(prefString) == null) {
			setPref(prefString, prefValue);
			trace('set preference!');
		}
		else trace('found preference: ' + getPref(prefString));
	}
}