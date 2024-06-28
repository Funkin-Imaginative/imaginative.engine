import flixel.addons.effects.FlxTrail;

function createPost()
	extra.set('flxTrail', new FlxTrail(this, null, 4, 24, 0.3, 0.069));

var added:Bool = false;
function update(elapsed:Float) {
	if (!added && extra.exists('flxTrail')) {
		added = true;
		addBehindObject(extra.get('flxTrail'), this);
		disableScript();
	}
}