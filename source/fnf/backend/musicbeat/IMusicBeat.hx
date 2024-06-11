package fnf.backend.musicbeat;

interface IMusicBeat {
	public function stepHit(curStep:Int):Void;
	public function beatHit(curBeat:Int):Void;
	public function measureHit(curMeasure:Int):Void;
}