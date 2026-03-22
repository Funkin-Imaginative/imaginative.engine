package imaginative.objects.holders;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawSongData = {
	var icon:String;
	var ?startingDiff:Int;
	var difficulties:Array<String>;
	var ?color:String;
	var ?gamemodes:Dynamic<Bool>;
	var ?extra:Dynamic<Dynamic>;
}
@:structInit @:publicFields class SongData {
	/**
	 * The song id.
	 */
	var id:String;
	/**
	 * The song name.
	 */
	var name:String;

	/**
	 * The song icon.
	 */
	var icon:String;

	/**
	 * The starting difficulty.
	 */
	var startingDiff:Int;
	/**
	 * The difficulty id's.
	 */
	var difficulties:Array<String>;
	/**
	 * The variation id's.
	 */
	var variants:Array<Null<String>>;

	/**
	 * The song color.
	 */
	var color:Null<FlxColor>;

	/**
	 * Gamemodes allowed in the song.
	 */
	var gamemodes:Map<String, Bool>;

	/**
	 * Extra data that can be stored.
 	 */
	var extra:Null<Map<String, Dynamic>>;

	/**
	 * Converts the raw object data.
	 * @param songId The song id; since the raw data doesn't include it.
	 * @param raw The object data.
	 * @return SongData
	 */
	static function fromRaw(songId:String, raw:RawSongData):SongData {
		final songDiffs:Array<Array<String>> = [
			for (value in raw.difficulties) {
				final split:Array<String> = value.toLowerCase().split(':');
				final diff:String = split[split.length > 1 ? 1 : 0];
				[diff, split.length > 1 ? split[0] : FunkinUtil.getDifficultyVariant(diff)];
			}
		];
		return {
			id: songId,
			name: ParseUtil.json('content/songs/$songId/audio', true)?.name ?? songId,
			icon: raw.icon,
			startingDiff: raw.startingDiff ?? (Math.floor(raw.difficulties.length / 2) - 1),
			difficulties: [for (value in songDiffs) value[0]],
			variants: [for (value in songDiffs) value[1]],
			color: raw.color == null ? null : FlxColor.fromString(raw.color),
			gamemodes: FunkinUtil.gamemodesCheck(FunkinUtil.objectToMap(raw.gamemodes)),
			extra: raw.extra == null ? null : FunkinUtil.objectToMap(raw.extra)
		}
	}
	/**
	 * Converts the object data.
	 * @param data The object data.
	 * @param clearStartDiff Whether to clear the starting difficulty.
	 * @return RawSongData
	 */
	static function toRaw(data:SongData, clearStartDiff:Bool = true):RawSongData {
		final songDiffs:Array<String> = [
			for (i in 0...data.difficulties.length) {
				final diff:String = data.difficulties[i];
				final variant:Null<String> = data.variants[i];
				variant == null ? diff : '$variant:$diff';
			}
		];
		var raw:Dynamic = {
			icon: data.icon,
			difficulties: songDiffs,
			color: data.color == null ? null : data.color.toWebString(),
			gamemodes: FunkinUtil.mapToObject(data.gamemodes)
		}
		// prevents it from stringify-ing as containing null
		if (!clearStartDiff) raw._set('startingDiff', data.startingDiff);
		if (data.extra != null) raw._set('extra', FunkinUtil.mapToObject(data.extra));
		return raw;
	}

	inline private function toString():String {
		return FunkinUtil.toDebugString([
			'Song ID' => id,
			'Song Name' => name,
			'Character Icon' => icon,
			'Starting Difficulty Index' => startingDiff,
			'Difficulties List' => difficulties,
			'Variations List' => variants,
			'Song Color' => color == null ? 'No Color' : color.toWebString(),
			'Active Gamemodes' => gamemodes,
			'Extra Data' => extra
		]);
	}
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
		var theCall:Dynamic = scripts.call('onSongLockedCheck');
		var result:Bool = theCall is Bool ? theCall : false;
		return result;
	}
	/**
	 * Is the holder be hidden?
	 */
	public var isHidden(get, never):Bool;
	inline function get_isHidden():Bool {
		var theCall:Dynamic = scripts.call('onSongHiddenCheck');
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
			// log([for (file in bruh) file.format()], DebugMessage);
			for (song in bruh)
				for (script in Script.createMulti('$pathType:content/scripts/songs/${song.path}'))
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
		scripts.destroy();
		super.destroy();
	}
}