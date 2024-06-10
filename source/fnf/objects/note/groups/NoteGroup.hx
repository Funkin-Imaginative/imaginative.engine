package fnf.objects.note.groups;

class NoteGroup extends FlxTypedGroup<Note> {
	// cne go brrrrrrrrrr
	var _loop:Note;
	var _cur:Int = 0;
	var _curLoop:Bool = false;
	var _time:Float = -1;

	public var viewTimeLimit:Float = 1500;

	override public function new() super(); // just to prevent max size setting lol

	override public function update(elapsed:Float) {
		_cur = length - 1;
		_loop = null;
		_time = Conductor.songPosition;
		while(_cur >= 0) {
			_loop = members[_cur--];
			if (_loop == null || !_loop.exists || !_loop.active) continue;
			if (_loop.strumTime - _time > viewTimeLimit) break;
			_loop.update(elapsed);
		}
	}

	override public function draw() {
		@:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (cameras != null) FlxCamera._defaultCameras = cameras;

		var oldCur = _curLoop;
		_curLoop = true;

		_cur = length - 1;
		_loop = null;
		_time = Conductor.songPosition;
		while(_cur >= 0) {
			_loop = members[_cur--];
			if (_loop == null || !_loop.exists || !_loop.active) continue;
			if (_loop.strumTime - _time > viewTimeLimit) break;
			_loop.draw();
		}
		_curLoop = oldCur;

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}

	override public function forEach(func:Note->Void, recursive:Bool = false) {
		_cur = length - 1;
		_loop = null;
		_time = Conductor.songPosition;

		var oldCur = _curLoop;
		_curLoop = true;

		while(_cur >= 0) {
			_loop = members[_cur--];
			if (_loop == null || !_loop.exists) continue;
			if (_loop.strumTime - _time > viewTimeLimit) break;
			func(_loop);
		}
		_curLoop = oldCur;
	}
	override public function forEachAlive(func:Note->Void, recursive:Bool = false) {
		forEach((note:Note) -> if (note.alive) func(note), recursive);
	}

	static function sortCode(n1:Note, n2:Note):Int {
		if (n1.strumTime == n2.strumTime) {
			var level:Int = 0;
			// n1.isSustain ? level++ : level--;
			if (n1.lowPriority && !n2.lowPriority) level++;
			else if (!n1.lowPriority && n2.lowPriority) level--;
			return level;
		}
		return FlxSort.byValues(FlxSort.DESCENDING, n1.strumTime, n2.strumTime);
	}
	inline public static function noteSortGroup(i:Int, n1:Note, n2:Note):Int return sortCode(n1, n2);
	inline public static function noteSortArray(n1:Note, n2:Note):Int return sortCode(n1, n2);
	inline public function sortSelf():Void {
		sort(noteSortGroup);
		for (note in members)
			note.tail.sort(noteSortArray);
	}

	override public function add(basic:Note):Note {
		var toReturn:Note = super.add(basic);
		sortSelf();
		return toReturn;
	}
	override public function remove(Object:Note, Splice:Bool = false):Note {
		if (members == null) return null;

		var index:Int = members.indexOf(Object);

		if (index < 0) return null;

		// doesnt prevent looping from breaking
		if (Splice && _curLoop && _cur >= index) _cur++;

		if (Splice) {
			members.splice(index, 1);
			length--;
		} else members[index] = null;

		if (_memberRemoved != null) _memberRemoved.dispatch(Object);

		return Object;
	}
}