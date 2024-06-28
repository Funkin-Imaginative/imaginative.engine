package fnf.utils;

typedef MergedLevelSongData = {
	var diffs:Array<String>;
	var icon:String;
	var color:FlxColor;
	var measure:Array<Int>;
	@:optional @default(false) var failedLoad:Bool; // jic
}

class FailsafeUtil {
	// idk why I did this lmao https://www.dcode.fr/keyboard-smash
	@:unreflective inline public static final invaildScriptKey:String = 'DSSDREW GFDGFDTRRTASDDSA FDSFDSWXCWXCERTERT FDSSDFWXCWXCFDS FDDFKLMKLMKLM MLKKLM[POOP[ POPOASD KJHDSSDKJHPOI WECXWCXW SDSDEWQFDSFDS SDFERTTRE DSADFGSDF KJHOIUUIO SDFGFDFGGFFDS DFGJKLKLMLM;;ML OP[OP[GFDDFGDFGGFD LKJPOPOUIOLKJLKJ LKJPOIIOPLKJASD DSAASDLKJLKJPOI KJHHJKJKLJKL OP[SAAS SDFSDFGFDDFGDSDS ERTTRRTFDSFDS JKLJKLSDF EWQEWQIOPWXCWXC JKLLKJSD SDFGFGFOIUUIO LKJDSAASDDSASDF LM;LM;IUUI FDSLKJMLK DSSDDFGDFG EWQGFDGFD SDFSDFASDASDKL MLKFDSFDS LKJJKLLKJ SDFEROP[ IOPIOPJKLLKJLKJLKJ JKJKSDFSDFTRE EWQOIIOLKJKLM ASDERTSDFIUUI OPJKLIO FDFDSDF REWJKKJLM;UIO JKLJKLKLKLLK KLLKJLKJ EWNM,POOP [POLKJKLMMLK ASDDSADFGLKJLKJLKJ SDFFDSLKJ LM;LM;LKJ';

	public static final diffYaml:DifficultyMeta.DiffData = {
		audioVariant: null,
		scoreMult: 1,
		fps: 24
	}

	public static final levelYaml:fnf.states.menus.StoryMenuState.LevelData = {
		name: 'Week Failsafe',
		title: 'It\'s a Failsafe!',
		songs: ['Test'],
		diffs: ['Normal'],
		chars: ['', '', ''],
		color: FlxColor.WHITE,
		failedLoad: true
	}
	public static final songMetaYaml:fnf.states.menus.FreeplayState.SongData = {
		name: 'Test',
		icon: 'face',
		color: FlxColor.WHITE,
		diffs: ['Normal'],
		measure: [4, 4],
		failedLoad: true
	}

	inline public static function mergeLevelAndSongData(?levelInfo:fnf.states.menus.StoryMenuState.LevelData, ?songInfo:fnf.states.menus.FreeplayState.SongData):MergedLevelSongData {
		if (levelInfo == null) levelInfo = levelYaml;
		if (songInfo == null) songInfo = songMetaYaml;
		return cast {
			diffs: songInfo.diffs == null ? levelInfo.diffs : songInfo.diffs,
			icon: songInfo.icon,
			color: songInfo.color,
			measure: songInfo.measure,
			failedLoad: levelInfo.failedLoad || songInfo.failedLoad
		}
	}

	public static final iconYaml:fnf.ui.HealthIcon.IconData = {
		dimensions: 150,
		scale: 1,
		flip: false,
		aliasing: true,
		anims: [
			{name: 'idle', tag: 'idle', fps: 24, loop: false, offset: {x: 0, y: 0}},
			{name: 'losing', tag: 'losing', fps: 24, loop: false, offset: {x: 0, y: 0}}
		],
		frames: [
			{name: 'idle', index: 0, offset: {x: 0, y: 0}},
			{name: 'losing', index: 1, offset: {x: 0, y: 0}}
		]
	}

	public static final charYaml:fnf.objects.Character.CharData = {
		name: 'Failsafe Character',
		sprite: 'BOYFRIEND',
		flip: true,
		anims: [{name: 'idle', tag: 'BF idle dance', fps: 24, loop: false, offset: {x: -5, y: 0}}],
		position: {x: 0, y: 350},
		camera: {x: 0, y: 0},

		scale: 1,
		singLen: 4,
		icon: 'face',
		aliasing: true,
		color: '',
		beat: 0
	}
}