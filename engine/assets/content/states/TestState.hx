var p1:Character;
var p2:Character;

function render():Void {
	conductor.reset();
	var song:String = 'Roses';
	var variant:Null<String> = 'erect';
	conductor.loadFullSong(song, variant == 'erect' ? 'nightmare' : 'hard', variant, (_:FlxSound) -> conductor.play());
	log('Song $song on variant $variant.');
}

function create():Void {
	render();
	conductor._onComplete = e -> render();
	add(p1 = new Character(0, 0, 'boyfriend', true));
	p1.screenCenter();
	p1.x += 300;
	add(p2 = new Character(0, 0, 'boyfriend'));
	p2.screenCenter();
	p2.x -= 300;
}

var anims:Array<String> = ['left', 'down', 'up', 'right'];
function binds(dir:Int, is2:Bool = false):Bool {
	return (is2 ? Controls.p2 : Controls.p1).notePressed(dir, 4);
}
function bindsHeld(dir:Int, is2:Bool = false):Bool {
	return (is2 ? Controls.p2 : Controls.p1).noteHeld(dir, 4);
}

function update(elapsed:Float):Void {
	for (char in [p1, p2]) {
		for (i => name in anims) {
			var nameUpper:String = name.toUpperCase();
			if (binds(i, char == p2)) {
				char.playAnim('sing$nameUpper', true, 'IsSinging');
				char.lastHit = time;
			}
			if (bindsHeld(i, char == p2)) {
				char.lastHit = time;
				if (char.getAnimName(char == p2) != 'sing$nameUpper')
					char.playAnim('sing$nameUpper', true, 'IsSinging');
			}
			if (FlxG.keys.justPressed.SPACE)
				char.playAnim('hey', true, 'NoSinging');
		}
	}

	if (Controls.global.back)
		BeatState.switchState(() -> new TitleScreen());
}