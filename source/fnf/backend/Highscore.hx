package fnf.backend;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map<String, Int>();

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var formattedSong:String = formatSong(song, diff);

		if (songScores.exists(formattedSong))
		{
			if (songScores.get(formattedSong) < score)
				setScore(formattedSong, score);
		}
		else
			setScore(formattedSong, score);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		var formattedSong:String = formatSong('week' + week, diff);

		if (songScores.exists(formattedSong))
		{
			if (songScores.get(formattedSong) < score)
				setScore(formattedSong, score);
		}
		else
			setScore(formattedSong, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(formattedSong:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(formattedSong, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = 'Normal';

		if (diff == 0)
			daSong = 'Easy';
		else if (diff == 2)
			daSong = 'Hard';

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
	}
}
