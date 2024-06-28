package fnf.backend.song;

class SongGroup extends FlxGroup implements ISong {
	public function stepHit(curStep:Int) for (member in members) if (member is ISong) cast(member, ISong).stepHit(curStep);
	public function beatHit(curBeat:Int) for (member in members) if (member is ISong) cast(member, ISong).beatHit(curBeat);
	public function measureHit(curMeasure:Int) for (member in members) if (member is ISong) cast(member, ISong).measureHit(curMeasure);
}