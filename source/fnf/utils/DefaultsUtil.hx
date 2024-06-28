package fnf.utils;

class DefaultsUtil {
	public static var noteTimeViewLimit:Float = 1500;
	public static var noteScore:Int = 350;
	public static var noteHitMult:{early:Float, late:Float} = {
		early: 1,
		late: 1
	}
	public static var healthAmount:{gain:Float, drain:Float} = {
		gain: 0.03,
		drain: 0.05
	}

	public static var startingHealths(get, default):{min:Float, start:Null<Float>, max:Float} = {
		min: 0,
		start: null, // null to have it set automatically
		max: 2
	}
	static function get_startingHealths():{min:Float, start:Null<Float>, max:Float} {
		final fake = startingHealths;
		if (fake.start == null) fake.start = (fake.max - fake.min) / 2;
		return fake;
	}
	public static var healthLerp:Float = 0.15;
	public static var barColors:fnf.objects.BetterBar.BarColors = {enemy: FlxColor.RED, player: 0xFF66FF33}
}