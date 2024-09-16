package backend.interfaces;

interface IBeat {
	function stepHit(curStep:Int):Void;
	function beatHit(curBeat:Int):Void;
	function measureHit(curMeasure:Int):Void;
}