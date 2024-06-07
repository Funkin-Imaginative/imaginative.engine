package fnf.objects.note;

class HoldCover extends FlxSprite {
	var col(get, never):String; function get_col():String return ['purple', 'blue', 'green', 'red'][ID];
	var dir(get, never):String; function get_dir():String return ['left', 'down', 'up', 'right'][ID];

	override public function new(data:Int) {
		ID = data;
		super();
		frames = Paths.getSparrowAtlas('holdCover');
		animation.addByPrefix('start', '${col}Start', 24, false);
		animation.addByPrefix('hold', '$col', 24, false);
		animation.addByPrefix('splash', '${col}Splash', 24, false);
		animation.finishCallback = function(name:String) {
			switch (name) {
				case 'splash':
					kill();
			}
		}
		animation.play('hold', true);
	}
}