package backend.interfaces;

interface IBeat {
	public function stepHit(curStep:Int):Void;
	public function beatHit(curBeat:Int):Void;
	public function measureHit(curMeasure:Int):Void;
}