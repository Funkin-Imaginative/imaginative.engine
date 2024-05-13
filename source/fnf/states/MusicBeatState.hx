package fnf.states;

import fnf.backend.Conductor.BPMChangeEvent;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;

class MusicBeatState extends FlxUIState {
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
		var className:String = Type.getClassName(Type.getClass(this));
		if (stateScripts == null) (stateScripts = new ScriptGroup(className)).parent = this;
		if (scriptsAllowed) {
			if (stateScripts.scripts.length == 0) {
				var path = Paths.script(className, 'state');
				var script = Script.create(path);
				if (!script.isInvalid) scriptName = script.scriptName;
				// script.remappedNames.set(script.fileName, '$i:${script.fileName}');
				stateScripts.add(script);
				script.load();
			}
			else stateScripts.reload();
		}
	}

	override function create() {
		loadScript();
		super.create();
		if (stateScripts != null) stateScripts.call('create');
	}

	override function update(elapsed:Float) {
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		if (stateScripts != null) stateScripts.call('update', [elapsed]);
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
	}

	public function beatHit():Void {
		// do literally nothing dumbass
	}
}
