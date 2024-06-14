package fnf.backend;

/* private */ class FunkinMapHelper<ObjectClass:FlxBasic> extends FlxBasic {
	public var members:Map<String, ObjectClass> = [];
	public var topMember(get, never):ObjectClass; public
	inline function get_topMember():ObjectClass return members.get(topMemberName);
	public var topMemberName(default, set):String;
	function set_topMemberName(value:String):String {
		var oldObj:ObjectClass = get(topMemberName);
		var newObj:ObjectClass = get(value);

		var group:FlxTypedGroup<FlxBasic> = @:privateAccess FlxTypedGroup.resolveGroup(oldObj);
		if (group != null) {
			group.insert(group.members.indexOf(oldObj), newObj);
			group.remove(oldObj);
		}

		return topMemberName = value;
	}

	public function set(tag:String, instance:ObjectClass):ObjectClass {members.set(tag, instance); return instance;}
	public function get(tag:String):ObjectClass return members.get(tag);
	public function remove(tag:String):Bool return members.remove(tag);

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}
	override public function destroy() {
		for (key => value in members) {
			value.destroy();
			members.remove(key);
		}
		super.destroy();
	}
}

class FunkinMap<ObjectClass:FlxBasic> extends FlxBasic {
	public var internalMap:Map<String, FunkinMapHelper<ObjectClass>> = new Map<String, FunkinMapHelper<ObjectClass>>();
	public var members(get, never):Map<String, ObjectClass>;
	function get_members():Map<String, ObjectClass> {
		var topMembers:Map<String, ObjectClass> = new Map<String, ObjectClass>();
		for (tag => helper in internalMap) topMembers.set(tag, helper.topMember);
		return topMembers;
	}

	/**
	 * Creates a `FunkinMapHelper` group to store `ObjectClass` objects.
	 * @param key Name of the `FunkinMapHelper` group.
	 * @param tag Name of the `ObjectClass` object tag.
	 * @param instance An instance of `ObjectClass`.
	 * @return Null<ObjectClass>
	 */
	public function createGroup(key:String, ?tag:String, ?instance:ObjectClass):Null<ObjectClass> {
		if (groupExists(key)) {trace('Group "$key" already exists.'); return null;}
		if (slotExists(key, tag)) {trace('Slot "$tag" already exists.'); return null;}
		var helper:FunkinMapHelper<ObjectClass>;
		internalMap.set(key, helper = new FunkinMapHelper<ObjectClass>());
		if (instance == null) return null;
		else helper.set(tag, instance);
		helper.topMemberName = tag;
		return instance;
	}
	public function addSlotMember(key:String, tag:String, instance:ObjectClass):ObjectClass {
		if (slotExists(key, tag)) {trace('Slot already exists.'); return null;}
		return internalMap.get(key).set(tag, instance);
	}
	public function getSlotMember(key:String, tag:String):Null<ObjectClass> return internalMap.get(key).get(tag);

	public function setTopSlot(key:String, tag:String):ObjectClass {
		if (slotExists(key, tag)) internalMap.get(key).topMemberName = tag;
		return internalMap.get(key).topMember;
	}
	public function getTopSlot(key:String):Null<ObjectClass>
		return internalMap.get(key).topMember;

	public function groupExists(key:String):Bool return internalMap.exists(key);
	public function slotExists(key:String, tag:String):Bool return groupExists(key) ? internalMap.get(key).members.exists(tag) : false;

	public function destroyGroup(key:String):Void {
		internalMap.get(key).destroy();
		internalMap.remove(key);
	}
	public function destroySlot(key:String, tag:String):Void internalMap.get(key).remove(tag);

	public function keys():Iterator<String> return members.keys();
	public function iterator():Iterator<ObjectClass> return members.iterator();
	public function keyValueIterator():KeyValueIterator<String, ObjectClass> return members.keyValueIterator();
}