package;

import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;


class TitleState extends MusicBeatState {
	private var logo:FlxSprite;
	private var enterText:FlxSprite;
	private var enterTextColors:Array<FlxColor> = [0x33FFFF, 0x3333CC];
	private var enterTextAlphas:Array<Float> = [1, .64];
	private var gfBop:FlxSprite;

	public static var muteKeys:Array<FlxKey> = [FlxKey.NUMPADZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS];

	override public function create() {

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		super.create();

		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		Conductor.changeBPM(102);
		persistentUpdate = true;

		logo = new FlxSprite(-120, -70);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.animation.addByPrefix('bumpin', 'logo bumpin0', 24, true);
		logo.animation.play('bumpin', true);
		logo.angle = -10;
		add(logo);
		logo.antialiasing = true;

		enterText = new FlxSprite(0, 600);
		enterText.frames = Paths.getSparrowAtlas('titleEnter');
		enterText.animation.addByPrefix('idle', 'ENTER IDLE0');
		enterText.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, true);
		enterText.animation.addByPrefix('freeze', 'ENTER FREEZE0');
		enterText.animation.play('idle');
		enterText.screenCenter(X);
		enterText.x += 210;
		add(enterText);
		enterText.color = 0x33FFFF;
		enterText.antialiasing = true;

		gfBop = new FlxSprite(550, -20);
		gfBop.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfBop.animation.addByPrefix('boppin', 'gfDance0', 24, true);
		gfBop.animation.play('boppin', true);
		gfBop.scale.x = 0.8;
		gfBop.scale.y = 0.8;
		add(gfBop);
		gfBop.antialiasing = true;
	}

	var titleTimer:Float = 0;

	override public function update(elapsed:Float) {
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
		if (FlxG.keys.justPressed.ENTER) {
			enterText.animation.play('pressed');
			enterText.color = 0xFFFFFF;
			new FlxTimer().start(1, function (tmr:FlxTimer) {
				MusicBeatState.switchState(new PlayState());
			});
		}
		if (!pressedEnter) {
			var timer:Float = titleTimer;
			if (timer >= 1)
				timer = (-timer) + 2;
			
			timer = FlxEase.quadInOut(timer);
			
			enterText.color = FlxColor.interpolate(enterTextColors[0], enterTextColors[1], timer);
			enterText.alpha = FlxMath.lerp(enterTextAlphas[0], enterTextAlphas[1], timer);
		}
		super.update(elapsed);
	}

	var sickBeats:Int;
	override public function beatHit() {

		super.beatHit();

		sickBeats++;

		trace('BAP BOOP DUM IDIOT');
	}
}