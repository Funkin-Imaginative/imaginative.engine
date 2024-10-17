package backend.interfaces;

interface IBeat {
	var curStep(default, null):Int;
	var curBeat(default, null):Int;
	var curMeasure(default, null):Int;

	function stepHit(curStep:Int):Void;
	function beatHit(curBeat:Int):Void;
	function measureHit(curMeasure:Int):Void;
}