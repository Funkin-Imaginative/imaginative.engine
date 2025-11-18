package imaginative.objects.gameplay.arrows.group;

class StrumGroup extends FlxTypedSpriteGroup<Strum> {
	/**
	 * The field the strum group is assigned to.
	 */
	public var setField(default, null):ArrowField;

	override public function new(field:ArrowField) {
		setField = field;
		super();

		// MAYBE: Rework this when adding EK support.
		group.memberAdded.add((_:Strum) -> members.sort((a:Strum, b:Strum) -> return FlxSort.byValues(FlxSort.ASCENDING, a.id, b.id)));
		group.memberRemoved.add((_:Strum) -> members.sort((a:Strum, b:Strum) -> return FlxSort.byValues(FlxSort.ASCENDING, a.id, b.id)));
	}

	/**
	 * Stores the unused strums to be reused later for EK usage.
	 */
	public var unusedMembers:Array<Strum> = [];

	// MAYBE: Once EK support is added make it store strum objects that are unused somewhere.
	/**
	 * Sets the line up for the amount of strums to use.
	 * @param count The amount you wish to play with.
	 */
	public function setLineup(count:Int):Void {
		while (!members.empty()) unusedMembers.push(remove(members[0], true));
		for (i in 0...count) {
			var strum = recycle(Strum, () -> return unusedMembers.empty() ? new Strum(setField, i) : unusedMembers.shift());
			strum.id = i; // force strum id
		}
		members.sort((a:Strum, b:Strum) -> return FlxSort.byValues(FlxSort.ASCENDING, a.id, b.id));
		setField.controls.laneCount = length;
	}
}