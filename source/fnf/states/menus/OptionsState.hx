package fnf.states.menus;

import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxSignal;

import fnf.ui.Prompt;
import fnf.ui.TextMenuList;
import fnf.states.menus.options.*;

class OptionsState extends SongState {
	public var pages = new Map<PageName, Page>();
	public var currentName:PageName = Options;
	public var currentPage(get, never):Page;
	private function get_currentPage():Page return pages[currentName];

	override function create() {
		var menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.scrollFactor.set();
		add(menuBG);

		var preferences = addPage(Preferences, new PreferencesPage());
		var gameplay = addPage(Gameplay, new GameplayPage());
		var graphics = addPage(Graphics, new GraphicsPage());
		var sensitivity = addPage(Sensitivity, new SensitivityPage());
		var controls = addPage(Controls, new ControlsPage());
		var options = addPage(Options, new OptionsMenu());

		if (options.hasMultipleOptions()) {
			preferences.onExit.add(switchPage.bind(Options));
			gameplay.onExit.add(switchPage.bind(Options));
			graphics.onExit.add(switchPage.bind(Options));
			sensitivity.onExit.add(switchPage.bind(Options));
			controls.onExit.add(switchPage.bind(Options));
			options.onExit.add(exitToMainMenu);
		} else {
			// No need to show Options page
			controls.onExit.add(exitToMainMenu);
			setPage(Controls);
		}

		// disable for intro transition
		currentPage.enabled = false;
		super.create();
	}

	function addPage<T:Page>(name:PageName, page:T):T {
		page.onSwitch.add(switchPage);
		pages[name] = page;
		add(page);
		page.exists = currentName == name;
		return page;
	}

	function setPage(name:PageName) {
		if (pages.exists(currentName))
			currentPage.exists = false;

		currentName = name;

		if (pages.exists(currentName))
			currentPage.exists = true;
	}

	override function finishTransIn() {
		super.finishTransIn();

		currentPage.enabled = true;
	}

	function switchPage(name:PageName) {
		// Todo animate?
		setPage(name);
	}

	function exitToMainMenu() {
		currentPage.enabled = false;
		// Todo animate?
		FlxG.switchState(new MainMenuState());
	}
}

class Page extends FlxGroup {
	public var onSwitch(default, null) = new FlxTypedSignal<PageName->Void>();
	public var onExit(default, null) = new FlxSignal();

	public var enabled(default, set) = true;
	public var canExit = true;

	var controls(get, never):Controls;

	inline function get_controls()
		return PlayerSettings.player1.controls;

	var subState:FlxSubState;

	inline function switchPage(name:PageName)
	{
		onSwitch.dispatch(name);
	}

	inline function exit()
	{
		onExit.dispatch();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (enabled)
			updateEnabled(elapsed);
	}

	function updateEnabled(elapsed:Float)
	{
		if (canExit && controls.BACK)
		{
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			exit();
		}
	}

	function set_enabled(value:Bool)
	{
		return this.enabled = value;
	}

	function openPrompt(prompt:Prompt, onClose:Void->Void)
	{
		enabled = false;
		prompt.closeCallback = () -> {
			enabled = true;
			if (onClose != null)
				onClose();
		}

		FlxG.state.openSubState(prompt);
	}

	override public function destroy()
	{
		super.destroy();
		onSwitch.removeAll();
	}
}

class OptionsMenu extends Page
{
	var items:TextMenuList;

	public function new()
	{
		super();

		add(items = new TextMenuList());
		createItem('preferences', () -> switchPage(Preferences));
		createItem('gameplay', () -> switchPage(Gameplay));
		createItem('graphics', () -> switchPage(Graphics));
		createItem('sensitivity', () -> switchPage(Sensitivity));
		createItem('controls', () -> switchPage(Controls));
	}

	function createItem(name:String, callback:Void->Void, fireInstantly = false)
	{
		var item = items.createItem(0, 100 + items.length * 100, name, Bold, callback);
		item.fireInstantly = fireInstantly;
		item.screenCenter(X);
		return item;
	}

	override public function set_enabled(value:Bool)
	{
		items.enabled = value;
		return super.set_enabled(value);
	}

	/**
	 * True if this page has multiple options, excluding the exit option.
	 * If false, there's no reason to ever show this page.
	 */
	public function hasMultipleOptions():Bool
	{
		return items.length > 2;
	}
}

enum abstract PageName(String) {
	var Preferences = 'prefs';
	var Gameplay = 'gameplay';
	var Controls = 'controls';
	var Graphics = 'graphics';
	var Sensitivity = 'sensitivity';
	var Options = 'options';
}