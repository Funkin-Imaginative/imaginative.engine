package imaginative.objects.holders;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef SongParse = {
	var icon:String;
	var ?startingDiff:Int;
	var difficulties:Array<String>;
	var ?variants:Array<String>;
	var ?color:ParseColor;
	var allowedModes:GamemodesTyping;
}
typedef SongData = {
	/**
	 * The song display name.
	 */
	var name:String;
	/**
	 * The song folder name.
	 */
	var folder:String;
	/**
	 * The song icon.
	 */
	var icon:String;
	/**
	 * The starting difficulty.
	 */
	var startingDiff:Int;
	/**
	 * The difficulties listing.
	 */
	var difficulties:Array<String>;
	/**
	 * The variations listing.
	 */
	var variants:Array<String>;
	/**
	 * The song color.
	 */
	var ?color:ParseColor;
	/**
	 * Allowed modes for the song.
	 */
	var allowedModes:GamemodesTyping;
}

class SongHolder extends BeatSpriteGroup {
	/**
	 * The holders path type.
	 */
	public var pathType:ModType;

	/**
	 * The song data.
	 */
	public var data:SongData;
	/**
	 * The song display name.
	 */
	public var text:FlxText;
	/**
	 * The icon for the character you'll be battling against.
	 */
	public var icon:HealthIcon;
	/**
	 * The lock sprite.
	 */
	public var lock:BaseSprite;

	/**
	 * The scripts attached to this holder.
	 */
	public var scripts:ScriptGroup;

	/**
	 * Is it locked?
	 */
	public var isLocked(get, never):Bool;
	inline function get_isLocked():Bool {
		var theCall:Dynamic = scripts.call('shouldLock');
		var result:Bool = theCall is Bool ? theCall : false;
		return result;
	}
	/**
	 * Is the holder be hidden?
	 */
	public var isHidden(get, never):Bool;
	inline function get_isHidden():Bool {
		var theCall:Dynamic = scripts.call('shouldHide');
		var result:Bool = theCall is Bool ? theCall : false;
		return result;
	}

	override public function new(name:ModPath, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		pathType = name.type;
		data = ParseUtil.song(name);
		scripts = new ScriptGroup(this);
		if (allowScripts) {
			var bruh:Array<ModPath> = ['lead:global', name];
			log([for (file in bruh) file.format()], DebugMessage);
			for (song in bruh)
				for (script in Script.create('$pathType:content/scripts/songs/${name.path}'))
					scripts.add(script);
		}
		scripts.load();

		if (loadSprites) {
			text = new FlxText(name.path);
			text.setFormat(Paths.font('PhantomMuff/full letters').format(), 60, OUTLINE, FlxColor.BLACK);
			text.borderSize = 3.5;
			add(text);

			icon = new HealthIcon(text.width + 30, text.height / 2, data.icon/* '$pathType:${data.icon}' */);
			icon.preventScaleBop = true;
			icon.y -= icon.height / 2;
			add(icon);

			if (isLocked) {
				text.text += ' (Locked)';
				icon.color -= 0xFF646464;
				text.color -= 0xFF646464;
				text.borderColor -= 0xFF646464;

				var mid:Position = Position.getObjMidpoint(text);
				lock = new BaseSprite(mid.x, mid.y, 'ui/lock');
				lock.x -= lock.width / 2;
				lock.y -= lock.height / 2;
				add(lock);
			}
		}
	}

	override public function destroy():Void {
		scripts.end();
		super.destroy();
	}
}