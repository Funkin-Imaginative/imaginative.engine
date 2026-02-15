package imaginative.objects.ui;

import imaginative.backend.scripting.events.menus.*;

// holding off on this class til a later date
// class _SelectionValue {
// 	/**
// 	 * The value as an integer.
// 	 */
// 	public var int(default, set):Int;
// 	inline function set_int(value:Int):Int {
// 		@:bypassAccessor float = value;
// 		return int = value;
// 	}

// 	/**
// 	 * The value as a float.
// 	 */
// 	public var float(default, set):Float;
// 	inline function set_float(value:Float):Float {
// 		if (int != value)
// 			@:bypassAccessor int = Math.round(value);
// 		return float = value;
// 	}

// 	public function new(startValue:Float = 0)
// 		set(startValue);

// 	/**
// 	 * Set's the value of this selection.
// 	 * **NOTE:** This only exists for easier use when scripting.
// 	 * @param value What to set it to.
// 	 * @return _SelectionValue
// 	 */
// 	inline public function set(value:Float):_SelectionValue {
// 		float = value;
// 		return this;
// 	}
// 	/**
// 	 * Set's the value from a different selection.
// 	 * **NOTE:** This only exists for easier use when scripting.
// 	 * @param value What to set it from.
// 	 * @return _SelectionValue
// 	 */
// 	inline public function from(value:_SelectionValue):_SelectionValue
// 		return set(value.float);
// }

// @:forward(int, float)
// @SuppressWarnings('checkstyle:FieldDocComment')
// abstract SelectionValue(_SelectionValue) {
// 	inline public function new(startValue:Float = 0)
// 		this = new _SelectionValue(startValue);

// 	@:from inline public static function fromRaw(from:_SelectionValue):SelectionValue
// 		return new SelectionValue(from.float);
// 	@:to inline public function toRaw():_SelectionValue
// 		return this;

// 	@:from inline public static function fromInt(from:Int):SelectionValue
// 		return new SelectionValue(from);
// 	@:to inline public function toInt():Int
// 		return this.int;

// 	@:from inline public static function fromFloat(from:Float):SelectionValue
// 		return new SelectionValue(from);
// 	@:to inline public function toFloat():Float
// 		return this.float;
// }

enum abstract LayoutType(String) from String to String {
	/**
	 * States that the layout is vertical.
	 */
	var VerticalLayout = 'vertical';
	/**
	 * States that the layout is horizontal.
	 */
	var HorizontalLayout = 'horizontal';

	/**
	 * States that the layout is a grid.
	 */
	var GridLayout = 'grid';

	/**
	 * States that the layout is being handled manually.
	 */
	var CustomLayout = 'custom';
}

class SelectionItem<SelectEvent:MenuSFXEvent> extends BeatSpriteGroup {
	/**
	 * Map for storing extra variables.
	 */
	public final extra:Map<String, Dynamic> = new Map<String, Dynamic>();

	// internals
	/**
	 * The parent selection handler this item in contained within.
	 */
	public final parentHandler:SelectionHandler<SelectEvent>;
	/**
	 * The id for this item.
	 */
	public final itemId:String;
	/**
	 * The index of the selection item.
	 */
	public var itemIndex(get, never):Int;
	inline function get_itemIndex():Int
		return parentHandler.members.indexOf(this);

	// properties
	/**
	 * If true, the item is locked and cannot be chosen.
	 * **NOTE:** This does not effect visuals. Override the "_isLocked" function for that, its dynamic for a reason.
	 */
	public var isLocked(default, set):Bool = false;
	inline function set_isLocked(value:Bool):Bool {
		_isLocked(isLocked = value);
		return value;
	}
	/**
	 * Override this to have the visuals change.
	 * **NOTE:** Override this after you've created all the objects within the item.
	 * @param value Wether the item is locked.
	 */
	public dynamic function _isLocked(value:Bool):Void {}
	/**
	 * If false, the item will be skipped over when navigating.
	 * **NOTE:** This does not effect visuals. Override the "_canSelect" function for that, its dynamic for a reason.
	 */
	public var canSelect(default, set):Bool = true;
	inline function set_canSelect(value:Bool):Bool {
		_canSelect(canSelect = value);
		return value;
	}
	/**
	 * Override this to have the visuals change.
	 * **NOTE:** Override this after you've created all the objects within the item.
	 * @param value Wether the item can be selected.
	 * @return Bool
	 */
	public dynamic function _canSelect(value:Bool):Void {}

	// functions
	/**
	 * The function for when the item becomes the current selection.
	 */
	public var changeFunc:SelectionChangeEvent->Void;
	/**
	 * The function for when the item is selected.
	 */
	public var selectFunc:Null<SelectEvent->Void>;
	/**
	 * The function for when the item is no longer the current selection.
	 */
	public var deselectFunc:Null<SelectionChangeEvent->Void>;

	@:allow(imaginative.objects.ui.SelectionHandler)
	function new(parent:SelectionHandler<SelectEvent>, itemId:String) {
		super();
		parentHandler = parent;
		this.itemId = itemId;
	}

	/**
	 * Sets the selection functions.
	 * @param changeFunc The function for when the item becomes the current selection.
	 * @param selectFunc The function for when the item is selected.
	 * @param deselectFunc The function for when the item is no longer the current selection.
	 */
	public function init(changeFunc:SelectionChangeEvent->Void, ?selectFunc:SelectEvent->Void, ?deselectFunc:SelectionChangeEvent->Void):Void {
		this.changeFunc = changeFunc;
		this.selectFunc = selectFunc;
		this.deselectFunc = deselectFunc;
	}
}

// TODO: Finish documentation!
/**
 * An input handler for menu selection.
 * **NOTE:** This class just handles the input, you'll need to handle the visuals yourself.
 */
class SelectionHandler<SelectEvent:MenuSFXEvent> extends BeatTypedGroup<SelectionItem<SelectEvent>> {
	/**
	 * All saved selections.
	 */
	static final savedSelections:Map<String, Int> = new Map<String, Int>();

	final traceTag:String;

	/**
	 * The tag used to save and receive from the "savedSelections" map.
	 */
	final saveTag:Null<String>;
	/**
	 * The layout of the items, this determines how your inputs will interact with the items within the handler.
	 */
	final layoutType:LayoutType;
	/**
	 * The amount of items in a horizontal grid layout before wrapping to the next row.
	 * **NOTE:** Only used if the layout type is set to 'GridLayout'.
	 */
	var horizontalGridCap:Null<Int> = 0;
	/**
	 * The function for creating a selection event instance.
	 */
	final eventCreator:SelectionItem<SelectEvent>->SelectEvent;
	/**
	 * The function for calling to scripts.
	 */
	dynamic function eventCall<SC:ScriptEvent>(name:String, event:SC):SC
		return event;

	/**
	 * Wether the handler can receive input.
	 */
	public var allowSelect:Bool = false;

	// selection values
	/**
	 * The previous value that was inputted.
	 */
	public var previousValue:Int;
	/**
	 * The current value that is inputted.
	 */
	public var currentValue:Int;
	/**
	 * The current item the camera should be centered on.
	 * This is a float for allowing the camera to be displaced in-between items.
	 */
	public var currentView:Float;

	var _forceVisualOntoCurrent:Bool = true;
	/**
	 * Wether the **currentView** should always be the **currentValue**.
	 */
	final forceVisualOntoCurrent:Bool;

	/**
	 * Creates a new 'SelectionHandler' instance.
	 * @param saveTag The tag to save the selection data to. If null it won't save any information.
	 * @param layoutType The way inputs should be handled.
	 * @param horizontalGridCap The amount of items in a horizontal grid layout before wrapping to the next row.
	 * @param forceVisualOntoCurrent Wether the visuals should update on selection change always.
	 * @param eventCreator The function for creating a selection event instance.
	 * @param eventCall The function for calling to scripts.
	 */
	public function new<SC:ScriptEvent>(?saveTag:String, layoutType:LayoutType = VerticalLayout, ?horizontalGridCap:Int, forceVisualOntoCurrent:Bool = true, eventCreator:SelectionItem<SelectEvent>->SelectEvent, ?eventCall:(String, SC) -> SC) {
		super();
		this.saveTag = saveTag;
		this.horizontalGridCap = horizontalGridCap;
		this.forceVisualOntoCurrent = forceVisualOntoCurrent;
		this.eventCreator = eventCreator;
		this.eventCall = eventCall ?? this.eventCall;

		traceTag = saveTag == null ? '[SelectionHandler]' : '[SelectionHandler - "$saveTag"]';
		final resultLayout:LayoutType = layoutType == GridLayout && (horizontalGridCap == null || horizontalGridCap <= 0) ? VerticalLayout : layoutType;
		if (layoutType == GridLayout && resultLayout == VerticalLayout)
			_log('$traceTag Please input a horizontalGridCap when using GridLayout, defaulting to VerticalLayout until then.', WarningMessage);
		this.layoutType = resultLayout;
	}

	/**
	 * When ran it creates all items the handler will use.
	 * @param itemList The list of item id's.
	 * @param stopInitSelection If true, won't initialize the selection so you can do it yourself at a later point.
	 * @param createItem The function for how item creation will be handled.
	 * @param changeFunc The function for when the item becomes the current selection.
	 * @param selectFunc The function for when the item is selected.
	 * @param deselectFunc The function for when the item is no longer the current selection.
	 */
	public function initialize(itemList:Array<String>, stopInitSelection:Bool = false, createItem:(Int, SelectionItem<SelectEvent>) -> Bool, changeFunc:(Int, SelectionChangeEvent, SelectionItem<SelectEvent>) -> Void, ?selectFunc:(Int, SelectEvent, SelectionItem<SelectEvent>) -> Void, ?deselectFunc:(Int, SelectionChangeEvent, SelectionItem<SelectEvent>) -> Void):Void {
		if (length != 0) {
			_log('$traceTag List has already been created.', WarningMessage);
			return;
		}
		if (itemList.empty()) {
			_log('$traceTag Item list is empty.', WarningMessage);
			return;
		}
		_log('$traceTag List contents are, ${itemList.cleanDisplayList()}.', DebugMessage);

		var _i:Int = 0;
		final failedItems:Array<String> = [];
		for (item in itemList) {
			final itemGroup:SelectionItem<SelectEvent> = new SelectionItem<SelectEvent>(this, item);
			itemGroup.init(
				event -> changeFunc(_i, event, itemGroup),
				event -> if (selectFunc != null) selectFunc(_i, event, itemGroup),
				event -> if (deselectFunc != null) deselectFunc(_i, event, itemGroup)
			);
			// if false, then something happened that caused creating this item to go undone
			if (createItem(_i, itemGroup)) {
				add(itemGroup); _i++;
			} else { itemGroup.destroy(); failedItems.push(item); }
		}
		if (length == 0) {
			_log('$traceTag Item list is empty!', WarningMessage);
			return;
		}
		if (!failedItems.empty())
			_log('$traceTag Failed items are, ${failedItems.cleanDisplayList()}.', WarningMessage);

		if (!stopInitSelection)
			initSelection();
	}
	function initSelection():Void {
		if (saveTag != null && savedSelections.exists(saveTag))
			changeSelection(savedSelections.get(saveTag), true);
		else changeSelection(0);
		if (currentValue == 0) members[currentValue].changeFunc(new SelectionChangeEvent(previousValue, currentValue));
		currentView = currentValue;
		allowSelect = true;
	}

	/**
	 * Checks if the mouse is overlapping with the given item.
	 * @param item The item to check.
	 * @return Bool
	 */
	public dynamic function overlapsCheck(item:SelectionItem<SelectEvent>):Bool
		return FlxG.mouse.overlaps(item);

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!allowSelect) return;

		if (layoutType == CustomLayout)
			customInput();
		else {
			// basic movement
			if (layoutType == HorizontalLayout || layoutType == GridLayout) {
				if (Controls.global.uiLeft || FlxG.keys.justPressed.COMMA) {
					changeSelection(-1);
					currentView = currentValue;
				}
				if (Controls.global.uiRight || FlxG.keys.justPressed.PERIOD) {
					changeSelection(1);
					currentView = currentValue;
				}
			}
			if (layoutType == VerticalLayout || layoutType == GridLayout) {
				if (Controls.global.uiUp || FlxG.keys.justPressed.PAGEUP) {
					final amount:Int = layoutType == GridLayout ? horizontalGridCap : 1;
					changeSelection(-amount);
					currentView = currentValue;
				}
				if (Controls.global.uiDown || FlxG.keys.justPressed.PAGEDOWN) {
					final amount:Int = layoutType == GridLayout ? horizontalGridCap : 1;
					changeSelection(amount);
					currentView = currentValue;
				}
			}

			// cursor movement / scrolling
			if (FlxG.mouse.wheel != 0) {
				changeSelection((FlxG.keys.pressed.SHIFT && layoutType == GridLayout ? horizontalGridCap : 1) * -1 * FlxG.mouse.wheel);
				currentView = currentValue;
			}
			if (PlatformUtil.mouseJustMoved())
				for (i => item in members)
					if (item.canSelect && overlapsCheck(item))
						changeSelection(i, true);

			// quick jumps
			if (FlxG.keys.justPressed.HOME) {
				var slot:Int = 0; // jic the first item is unselectable
				while (slot < length && !members[slot].canSelect) slot++;
				changeSelection(slot, true);
				currentView = currentValue;
			}
			if (FlxG.keys.justPressed.END) {
				var slot:Int = length - 1; // jic the last item is unselectable
				while (slot > 0 && !members[slot].canSelect) slot--;
				changeSelection(slot, true);
				currentView = currentValue;
			}

			// select
			if (Controls.global.accept || (FlxG.mouse.justPressed && (currentValue == -1 ? true : overlapsCheck(members[currentValue])))) {
				if (currentView != currentValue) {
					currentView = currentValue;
					FunkinUtil.playMenuSFX(ScrollSFX, 0.7);
				} else selectCurrent();
			}
		}

		if (forceVisualOntoCurrent && _forceVisualOntoCurrent && currentValue != -1)
			currentView = currentValue;
	}

	override public function destroy():Void {
		if (saveTag != null)
			savedSelections.set(saveTag, currentValue == -1 ? 0 : currentValue);
		super.destroy();
	}

	/**
	 * A quick and easy way for scripts to add custom input handling.
	 */
	public dynamic function customInput():Void {
		// do wtf you want
	}

	/**
	 * The default cooldown time in seconds.
	 * Isn't static because you might want different handlers to have different default cooldowns.
	 */
	public var defaultCooldown:Float = 0.3;
	var cooldownTimer:FlxTimer = new FlxTimer();
	/**
	 * Sets a cooldown for how long until the handler registers your inputs again.
	 * @param duration The length of the cooldown in seconds.
	 * @param addOnto If true, it will add onto the existing cooldown.
	 * @return FlxTimer
	 */
	inline public function setCooldown(?duration:Float, addOnto:Bool = false):FlxTimer {
		allowSelect = false;
		duration ??= defaultCooldown;
		final totalDuration:Float = addOnto ? cooldownTimer.timeLeft + duration : duration;
		_log('$traceTag Setting cooldown for $totalDuration seconds${addOnto ? ' (originally $duration seconds)' : ''}.', DebugMessage);
		return cooldownTimer.start(totalDuration, timer -> allowSelect = true);
	}

	var _stopSound:Bool = true;
	var _recursionTracker:Int = 0;
	function changeSelection(amount:Int = 0, pureSelect:Bool = false):Void {
		_recursionTracker++;
		if (_recursionTracker > length) {
			_log('$traceTag Recursion detected, setting selection to -1 to prevent stack overflow!', ErrorMessage);
			_recursionTracker = 0; changeSelection(-1, true);
			return;
		}

		if (members.empty()) {
			_log('$traceTag Cannot change selection, no members exist!', WarningMessage);
			return;
		}
		inline function wrap(amount:Int, curAmount:Int = 0):Int
			return FlxMath.wrap(curAmount + amount, 0, length - 1);
		final unselected:Bool = amount == -1 && pureSelect;

		final event:SelectionChangeEvent = eventCall('onChangeSelection', new SelectionChangeEvent(currentValue, pureSelect ? (unselected ? -1 : wrap(amount)) : wrap(amount, currentValue)));
		if (_stopSound) { // stops it from playing on handler creation
			event.playSFX = false;
			_stopSound = false;
		} else if (unselected)
			event.playSFX = false;

		final currentItem:Null<SelectionItem<SelectEvent>> = members[event.currentValue];
		if (!unselected && !currentItem.canSelect) {
			if (!pureSelect) {
				if (layoutType == GridLayout) return;
				changeSelection(amount + (amount > 0 ? 1 : -1));
			}
			return;
		}
		_recursionTracker = 0;

		if (event.prevented) return;
		previousValue = event.previousValue == event.currentValue ? previousValue : event.previousValue;
		currentValue = event.currentValue;
		event.playMenuSFX(ScrollSFX);

		if (!event.noChange) {
			members[event.previousValue]?.deselectFunc(event);
			currentItem?.changeFunc(event);
		}
	}
	dynamic function selectCurrent():Void {
		if (currentValue == -1) {
			_log('$traceTag Nothing selected.', DebugMessage);
			return; // unselected
		}
		setCooldown();

		final curItem = members[currentValue];
		_log('$traceTag Selecting item "${curItem.itemId}". (index:$currentValue)', DebugMessage);
		final event = eventCreator(curItem);
		if (event.prevented) return;

		if (curItem.isLocked)
			lockedEffect(curItem, event);
		else {
			event.playMenuSFX(ConfirmSFX);
			curItem?.selectFunc(event);
		}
	}

	/**
	 * What happens when an item is locked.
	 * @param item The item to apply the effect to.
	 * @param event The select event.
	 */
	public dynamic function lockedEffect(item:SelectionItem<SelectEvent>, ?event:SelectEvent):Void {
		item.extra.get('shakeTween')?.cancel();
		final time:Float = {
			final sound = event?.playMenuSFX(CancelSFX, true);
			if (sound == null) defaultCooldown;
			else sound.time / 1000;
		}
		final ogX:Float = item.x;
		// TODO: Figure out why the shake tween isn't working.
		item.extra.set('shakeTween', FlxTween.shake(item, 1, time, X, {
			onStart: tween -> setCooldown(time),
			onComplete: tween -> item.x = ogX
		}));
	}
}