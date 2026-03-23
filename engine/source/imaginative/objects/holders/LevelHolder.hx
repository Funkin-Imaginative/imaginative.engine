package imaginative.objects.holders;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawBasicSpriteTyping = {
	var ?sprite:DynamicSpriteData;
	var ?flip:Bool;
	var ?offset:Array<Float>;
	var ?size:Float;
	var ?cheer:Bool;
	var ?extra:Dynamic<Dynamic>;
}
@:structInit @:publicFields class BasicSpriteTyping {
	/**
	 * The object json mod path, if there is one.
	 */
	var path:Null<ModPath>;
	/**
	 * The sprite data.
	 */
	var data:SpriteData;

	/**
	 * Wether the sprite is flipped or not.
	 */
	var flipped:Bool;
	/**
	 * A position offset.
	 */
	var offset:Position;
	/**
	 * A size multiplier.
	 */
	var sizeMult:Float;

	/**
	 * States whether the object will play a cheering animation on level select.
	 */
	var cheerOnSelect:Bool;

	/**
	 * Extra data that the object can store.
 	 */
	var extra:Map<String, Dynamic>;

	/**
	 * Converts the raw object data.
	 * @param raw The object data.
	 * @param index The index of the object in the list, used for null checks. Defaults to false if not assigned.
	 * @param amount The length of the list, used for null checks. Defaults to false if not assigned.
	 * @return BasicSpriteTyping
	 */
	static function fromRaw(raw:RawBasicSpriteTyping, ?index:Int, ?amount:Int):BasicSpriteTyping {
		var _path:Null<ModPath> = null;
		var _data:SpriteData = null;
		if (raw.sprite != null) {
			if (Paths.object(raw.sprite.getPath()).isFile)
				if (raw.sprite.isDirectory())
					_data = ParseUtil.object(_path = raw.sprite.getPath(), IsBeatSprite);
				else _data = raw.sprite.getData(true, IsBeatSprite);
		}
		return {
			path: _path,
			data: _data,
			flipped: raw.flip ?? (index == null || amount == null) ? false : (index + 1) > Math.floor(amount / 2),
			offset: Position.fromArray(raw.offset ?? [0, 0]),
			sizeMult: raw.size ?? 1,
			cheerOnSelect: raw.cheer ?? (index == null || amount == null) ? false : index == Math.floor(amount / 2),
			extra: raw.extra == null ? [] : FunkinUtil.objectToMap(raw.extra)
		}
	}
	/**
	 * Converts the object data.
	 * @param data The object data.
	 * @param clearFlip Whether to clear the flip.
	 * @param clearCheer Whether to clear the cheer.
	 * @return RawBasicSpriteTyping
	 */
	static function toRaw(data:BasicSpriteTyping, clearFlip:Bool = true, clearCheer:Bool = true):RawBasicSpriteTyping {
		var raw:Dynamic = {
			sprite: new DynamicSpriteData(data.path, SpriteData.toRaw(data.data)),
			offset: data.offset.toArray(),
			size: data.sizeMult
		}
		// prevents it from stringify-ing as containing null
		if (!clearFlip) raw._set('flip', data.flipped);
		if (!clearCheer) raw._set('cheer', data.cheerOnSelect);
		if (data.extra != null) if (!data.extra.empty()) raw._set('extra', FunkinUtil.mapToObject(data.extra));
		return raw;
	}

	inline private function toString():String {
		return FunkinUtil.toDebugString([
			'File Path' => path.isFile ? '$path (raw:${path.format()})' : 'No Path',
			'Sprite Data' => data == null ? 'No Data' : data,
			'Flip X' => flipped,
			'Position Offset' => offset,
			'Size multiplier' => sizeMult,
			'Plays Cheer' => cheerOnSelect,
			'Extra Data' => extra
		]);
	}
}

@SuppressWarnings('checkstyle:FieldDocComment')
typedef RawLevelData = {
	var title:String;
	var songs:Array<String>;
	var ?startingDiff:Int;
	var difficulties:Array<String>;
	var ?sprites:Array<RawBasicSpriteTyping>;
	var ?color:String;
	var ?extra:Dynamic<Dynamic>;
}
@:structInit @:publicFields class LevelData {
	/**
	 * The level id.
	 */
	var id:String;

	/**
	 * The week title.
	 */
	var title:String;
	/**
	 * The song id's.
	 */
	var songs:Array<SongData>;

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
	 * The character sprites in the story menu.
	 */
	var sprites:Array<BasicSpriteTyping>;

	/**
	 * The week background color.
	 */
	var color:Null<FlxColor>;

	/**
	 * Extra data that can be stored.
 	 */
	var extra:Map<String, Dynamic>;

	/**
	 * Converts the raw object data.
	 * @param levelId The level id; since the raw data doesn't include it.
	 * @param raw The object data.
	 * @return LevelData
	 */
	static function fromRaw(levelId:String, raw:RawLevelData):LevelData {
		final levelColor:FlxColor = raw.color == null ? 0xFFF9CF51 : FlxColor.fromString(raw.color);
		final levelDiffs:Array<Array<String>> = [
			for (value in raw.difficulties) {
				final split:Array<String> = value.toLowerCase().split(':');
				final diff:String = split[split.length > 1 ? 1 : 0];
				[diff, split.length > 1 ? split[0] : FunkinUtil.getDifficultyVariant(diff)];
			}
		];
		return {
			id: levelId,
			title: raw.title ?? '[Please Add a Title]',
			songs: [
				for (name in raw.songs) {
					var data = ParseUtil.song(name);
					data.color ??= levelColor;
					data;
				}
			],
			startingDiff: raw.startingDiff ?? (Math.floor(raw.difficulties.length / 2) - 1),
			difficulties: [for (value in levelDiffs) value[0]],
			variants: [for (value in levelDiffs) value[1]],
			sprites: [for (i => data in raw.sprites ?? []) BasicSpriteTyping.fromRaw(data, i, raw.sprites.length)],
			color: levelColor,
			extra: raw.extra == null ? [] : FunkinUtil.objectToMap(raw.extra)
		}
	}
	/**
	 * Converts the object data.
	 * @param data The object data.
	 * @param clearStartDiff Whether to clear the starting difficulty.
	 * @param clearSpriteClearables Whether to clear the sprite clearable values.
	 * @return RawLevelData
	 */
	static function toRaw(data:LevelData, clearStartDiff:Bool = true, clearSpriteClearables:Bool = true):RawLevelData {
		final levelDiffs:Array<String> = [
			for (i in 0...data.difficulties.length) {
				final diff:String = data.difficulties[i];
				final variant:Null<String> = data.variants[i];
				variant == null ? diff : '$variant:$diff';
			}
		];
		var raw:Dynamic = {
			title: data.title,
			songs: [for (song in data.songs) song.id],
			difficulties: levelDiffs,
			sprites: [for (data in data.sprites) BasicSpriteTyping.toRaw(data, clearSpriteClearables, clearSpriteClearables)],
			color: data.color == null ? null : data.color.toWebString()
		}
		// prevents it from stringify-ing as containing null
		if (!clearStartDiff) raw._set('startingDiff', data.startingDiff);
		if (data.extra != null) if (!data.extra.empty()) raw._set('extra', FunkinUtil.mapToObject(data.extra));
		return raw;
	}

	inline private function toString():String {
		return FunkinUtil.toDebugString([
			'Level ID' => id,
			'Week Title' => title,
			'Songs List' => songs,
			'Starting Difficulty Index' => startingDiff,
			'Difficulties List' => difficulties,
			'Variations List' => variants,
			'Character Sprites' => sprites,
			'Background Color' => color == null ? 'No Color' : color.toWebString(),
			'Extra Data' => extra
		]);
	}
}

/**
 * The level sprite name.
 * This is mostly used for the story menu.
 */
class LevelHolder extends BeatSpriteGroup {
	/**
	 * The holders path type.
	 */
	public var pathType:ModType;

	/**
	 * The level data.
	 */
	public var data:LevelData;
	/**
	 * The actually sprite.
	 */
	public var sprite:BaseSprite;
	/**
	 * The lock sprite.
	 */
	public var lock:FlxSprite;//BaseSprite;

	/**
	 * The scripts attached to this holder.
	 */
	public var scripts:ScriptGroup;

	/**
	 * Is it locked?
	 */
	public var isLocked(get, never):Bool;
	inline function get_isLocked():Bool {
		var theCall:Dynamic = scripts.call('onLevelLockedCheck');
		var result:Bool = theCall is Bool ? theCall : false;
		return result;
	}
	/**
	 * Is the holder be hidden?
	 */
	public var isHidden(get, never):Bool;
	inline function get_isHidden():Bool {
		var theCall:Dynamic = scripts.call('onLevelHiddenCheck');
		var result:Bool = theCall is Bool ? theCall : false;
		return result;
	}
	/**
	 * The week character for that week.
	 * This is mostly used for the story menu.
	 */
	public var weekObjects:Array<BeatSprite> = [];

	override public function new(name:ModPath, loadSprites:Bool = false, allowScripts:Bool = true) {
		super();

		pathType = name.type;
		data = ParseUtil.level(name);
		scripts = new ScriptGroup(this);
		if (allowScripts) {
			var bruh:Array<ModPath> = ['lead:global', name];
			for (level in bruh)
				for (script in Script.createMulti('${level.type}:content/levels/${level.path}'))
					scripts.add(script);
		}
		scripts.load();

		if (loadSprites) {
			sprite = new BaseSprite('$pathType:menus/story/levels/${name.path}');
			add(sprite);

			if (isLocked) {
				sprite.color -= 0xFF646464;

				var mid:Position = Position.getObjMidpoint(sprite);
				lock = new FlxSprite(mid.x, mid.y, Assets.image('ui/lock'));//new BaseSprite(mid.x, mid.y, 'lol/lol');
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