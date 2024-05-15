#if THROW_LUA_MAKEFUN
package fnf.states.sub;

// prevent script edits
@:unreflective class LuaMakeFunLmao extends MusicBeatSubstate {
	private static var alreadyOpened:Bool = false;

	override public function new() super(false); // prevent scripting

	override function create() {
		super.create();
		alreadyOpened = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.ACCEPT || controls.BACK) {
			close();
		}
	}
}
#end