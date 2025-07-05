package imaginative.backend.scripting.types;

import imaginative.scripting.ScriptObjectBase;

/**
 * The idea is you can code scripts without having to use files. You can just make a script in the source code!
 * NOTE: THIS IS EXPERIMENTAL! THE SET FUNCTION MAY NOT FULLY WORK!
 */
final class SourceScript extends Script {
	var scriptObjectClass(default, null):Class<ScriptObjectBase>;
	var scriptObject(default, null):ScriptObjectBase;

	@:unreflective override public function new(scriptObjectClass:Class<ScriptObjectBase>) {
		this.scriptObjectClass = scriptObjectClass;
		renderNecessities();
		scripts.push(this);
		GlobalScript.call('scriptCreated', [this, type]);
	}

	override function renderNecessities():Void {
		canRun = true;
	}
	override function loadCodeString():Void {
		scriptObject = Type.createInstance(scriptObjectClass, []);
		loaded = true;
	}
}