package fnf.backend.musicbeat;

import fnf.backend.Conductor.BPMChangeEvent;
import flixel.addons.transition.FlxTransitionableState;

class MusicBeatState extends FlxTransitionableState implements IMusicBeat {
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curMeasure:Int = 0;
	private var controls(get, never):Controls;
	inline function get_controls():Controls return PlayerSettings.player1.controls;

	public var paused:Bool = false;

	public var stateScripts:ScriptGroup;
	public var scriptsAllowed:Bool = true;
	public var scriptName:String = null;

	override public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
		super();
		this.scriptsAllowed = #if SOFTCODED_STATES scriptsAllowed #else false #end;
		this.scriptName = scriptName;
	}

	function loadScript() {
		if (stateScripts == null) stateScripts = new ScriptGroup(this);
		if (scriptsAllowed) {
			if (stateScripts.length == 0) {
				var script = Script.create(CoolUtil.getClassName(this), 'state');
				if (!script.isInvalid) scriptName = script.fileName;
				stateScripts.add(script);
				script.load();
			}
			else stateScripts.reload();
		}
	}

	public function call(name:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		if (stateScripts != null)
			return stateScripts.call(name, args);
		return def;
	}

	override public function create() {
		loadScript();
		super.create();
		call('create');
	}

	override public function createPost() {
		super.createPost();
		call('createPost');
	}

	override public function tryUpdate(elapsed:Float):Void {
		if (persistentUpdate || subState == null) {
			call('preUpdate', [elapsed]);
			update(elapsed);
			call('updatePost', [elapsed]);
		}
		if (_requestSubStateReset) {
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null) subState.tryUpdate(elapsed);
	}

	override public function update(elapsed:Float) {
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);
		curMeasure = Math.floor(curBeat / 4);

		if (oldStep != curStep && curStep >= 0)
			stepHit(curStep);

		call('update', [elapsed]);
		super.update(elapsed);
	}

	override public function openSubState(SubState:FlxSubState) {
		stateScripts.call('openingSubState', [SubState]);
		if (paused) {
			persistentUpdate = false;
			persistentDraw = true;
		}
		super.openSubState(SubState);
	}
	override public function closeSubState() {
		stateScripts.call('closingSubState', [subState]);
		if (paused) {
			persistentUpdate = persistentDraw = true;
			paused = false;
		}
		super.closeSubState();
	}

	private function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	var oldBeat:Int = 0;
	public function stepHit(curStep:Int):Void {
		for (member in members) if (member is IMusicBeat) cast(member, IMusicBeat).stepHit(curStep);
		if (curStep % 4 == 0 && oldBeat != curBeat)
			beatHit(oldBeat = curBeat);
		call('stepHit', [curStep]);
	}

	public function beatHit(curBeat:Int):Void {
		for (member in members) if (member is IMusicBeat) cast(member, IMusicBeat).beatHit(curBeat);
		call('beatHit', [curBeat]);
		if (curBeat & 4 == 0) measureHit(curMeasure);
	}

	public function measureHit(curMeasure:Int):Void {
		for (member in members) if (member is IMusicBeat) cast(member, IMusicBeat).measureHit(curMeasure);
		call('measureHit', [curMeasure]);
	}

	override public function destroy() {
		stateScripts.destroy();
		fnf.objects.note.groups.StrumGroup.hitFuncs.noteHit = null;
		fnf.objects.note.groups.StrumGroup.hitFuncs.noteMiss = null;
		try {if (PlayField.direct.state == this) PlayField.direct.state = null;} catch(e) {}
		super.destroy();
	}
}