package fnf.backend.musicbeat;

class MusicBeatGroup extends FlxGroup implements IMusicBeat {
	public function stepHit(curStep:Int) for (member in members) if (member is IMusicBeat) cast(member, IMusicBeat).stepHit(curStep);
	public function beatHit(curBeat:Int) for (member in members) if (member is IMusicBeat) cast(member, IMusicBeat).beatHit(curBeat);
	public function measureHit(curMeasure:Int) for (member in members) if (member is IMusicBeat) cast(member, IMusicBeat).measureHit(curMeasure);
}