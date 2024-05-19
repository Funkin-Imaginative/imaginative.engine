package fnf.backend.musicbeat;

import fnf.backend.Conductor.BPMChangeEvent;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState {
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;
	inline function get_controls():Controls return PlayerSettings.player1.controls;

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

	override function create() {
		loadScript();
		super.create();
		call('create');
		call('postCreate');
	}

	override public function tryUpdate(elapsed:Float):Void {
		if (persistentUpdate || subState == null) {
			call('preUpdate', [elapsed]);
			update(elapsed);
			call('postUpdate', [elapsed]);
		}
		if (_requestSubStateReset) {
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null) subState.tryUpdate(elapsed);
	}

	override function update(elapsed:Float) {
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		call('update', [elapsed]);
		super.update(elapsed);
	}

	private function updateBeat():Void {
		curBeat = Math.floor(curStep / 4);
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

	public function stepHit():Void {
		if (curStep % 4 == 0)
			beatHit();
		call('stepHit', [curStep]);
	}

	public function beatHit():Void {
		call('beatHit', [curBeat]);
	}

	override public function destroy() {
		stateScripts.destroy();
		if (PlayField.direct.state == this) PlayField.direct.state = null;
		super.destroy();
	}
}
