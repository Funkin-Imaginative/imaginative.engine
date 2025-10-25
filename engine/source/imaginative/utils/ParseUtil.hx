package imaginative.utils;

import json2object.JsonParser;
import imaginative.states.editors.ChartEditor.ChartData;

// MAYBE: Might end up not using.
/**
 * Used for parsing extra data from json files.
 */
@SuppressWarnings('checkstyle:FieldDocComment')
abstract ParseDynamic(Dynamic) from ExtraData from Int from Float from Bool from String {
	@:to inline public function toInt():Int {
		var target:Dynamic = Type.getClass(this) == ExtraData ? this.data : this;
		return switch (Type.getClass(target)) {
			case Int: target;
			case Float: Math.round(target);
			case Bool: target ? 1 : 0;
			case String: Std.parseInt(target);
			default: cast target;
		}
	}
	@:to inline public function toFloat():Float {
		var target:Dynamic = Type.getClass(this) == ExtraData ? this.data : this;
		return switch (Type.getClass(target)) {
			case Int: target;
			case Float: target;
			case Bool: target ? 1 : 0;
			case String: Std.parseFloat(target);
			default: cast target;
		}
	}
	@:to inline public function toBool():Bool {
		var target:Dynamic = Type.getClass(this) == ExtraData ? this.data : this;
		return switch (Type.getClass(target)) {
			case Int: target > 0;
			case Float: target > 0;
			case Bool: target;
			case String: target == 'true';
			default: cast target;
		}
	}
	@:to inline public function toString():String
		return Std.string(Type.getClass(this) == ExtraData ? this.data : this);
}

/**
 * Used for parsing colors from json files.
 */
@SuppressWarnings('checkstyle:FieldDocComment')
abstract ParseColor(String) {
	public var red(get, set):Int;
	inline function get_red():Int
		return toFlxColor().red;
	inline function set_red(value:Int):Int {
		var color:FlxColor = toFlxColor();
		color.red = value;
		this = fromFlxColor(color);
		return color.red;
	}
	public var green(get, set):Int;
	inline function get_green():Int
		return toFlxColor().green;
	inline function set_green(value:Int):Int {
		var color:FlxColor = toFlxColor();
		color.green = value;
		this = fromFlxColor(color);
		return color.green;
	}
	public var blue(get, set):Int;
	inline function get_blue():Int
		return toFlxColor().blue;
	inline function set_blue(value:Int):Int {
		var color:FlxColor = toFlxColor();
		color.blue = value;
		this = fromFlxColor(color);
		return color.blue;
	}

	inline public function nullCheck(nullColor:ParseColor):ParseColor
		return this ??= nullColor;

	@:from inline public static function fromString(from:String):ParseColor
		return cast FlxColor.fromString(from ?? 'white').toWebString();
	@:to inline public function toString():String
		return this ?? '#FFFFFF';

	@:from inline public static function fromInt(from:Int):ParseColor
		return FlxColor.fromInt(from ?? FlxColor.WHITE).toWebString();
	@:to inline public function toInt():Int
		return FlxColor.fromString(this ?? 'white');

	@:from inline public static function fromFlxColor(from:FlxColor):ParseColor
		return FlxColor.fromInt(from ?? FlxColor.WHITE).toWebString();
	@:to inline public function toFlxColor():FlxColor
		return FlxColor.fromString(this ?? 'white');

	@:from inline public static function fromArray(from:Array<Int>):ParseColor
		return fromInt(FlxColor.fromRGB(from[0] ?? 255, from[1] ?? 255, from[2] ?? 255));
	@:to inline public function toArray():Array<Int> {
		var color:FlxColor = toFlxColor();
		return [color.red ?? 255, color.green ?? 255, color.blue ?? 255];
	}
}

typedef GamemodesTyping = {
	/**
	 * If true this song allows you to play as the enemy.
	 */
	@:default(false) var playAsEnemy:Bool;
	/**
	 * If true this song allows you to go against another player.
	 */
	@:default(false) var p2AsEnemy:Bool;
}

@:structInit class ExtraData {
	/**
	 * Name of the data.
	 */
	public var name:String;
	/**
	 * The data contents.
	 */
	public var data:ParseDynamic;

	public function new(name:String, ?data:ParseDynamic) {
		this.name = name;
		this.data = data;
	}
}

/**
 * This util is for all your parsing needs.
 */
class ParseUtil {
	/**
	 * Parses a json file.
	 * @param file The mod path.
	 * @return Dynamic ~ The parsed json.
	 */
	inline public static function json(file:ModPath):Dynamic {
		var jsonPath:ModPath = Paths.json(file);
		return Assets.json(Assets.text(jsonPath), jsonPath);
	}

	/**
	 * Parses a difficulty json.
	 * @param key The difficulty key.
	 * @return DifficultyData ~ The parsed difficulty json.
	 */
	inline public static function difficulty(key:String):DifficultyData {
		var jsonPath:ModPath = Paths.difficulty(key);
		var contents:DifficultyData = new JsonParser<DifficultyData>().fromJson(Assets.text(jsonPath), jsonPath.format());
		contents.display = contents.display ?? key;
		return contents;
	}

	/**
	 * Parses a level json.
	 * @param name The level json name.
	 * @return LevelData ~ The parsed level json.
	 */
	public static function level(name:ModPath):LevelData {
		var jsonPath:ModPath = Paths.level(name);
		var contents:LevelParse = new JsonParser<LevelParse>().fromJson(Assets.text(jsonPath), jsonPath.format());
		for (i => data in contents.objects) {
			data.flip ??= ((i + 1) > Math.floor(contents.objects.length / 2));
			data.willHey ??= (i == Math.floor(contents.objects.length / 2));
		}
		var songs:Array<SongData> = [
			for (song in contents.songs)
				ParseUtil.song(song)
		];
		for (song in songs)
			song.color = song.color == null ? contents.color : song.color;
		return {
			name: name.path,
			title: contents.title,
			songs: songs,
			startingDiff: contents.startingDiff ?? (Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [
				for (difficulty in contents.difficulties)
					difficulty.toLowerCase()
			],
			variants: [
				for (variant in contents.variants ?? [
					for (difficulty in contents.difficulties)
						FunkinUtil.getDifficultyVariant(difficulty)
				])
					variant.toLowerCase()
			],
			objects: contents.objects,
			color: contents.color.nullCheck('#F9CF51')
		}
	}

	/**
	 * Parses an object json.
	 * @param file The object json name.
	 * @param type The sprite type.
	 * @return SpriteData ~ The parsed object json.
	 */
	public static function object(file:ModPath, type:SpriteType):SpriteData {
		var jsonPath:ModPath = Paths.object(file);
		var typeData:SpriteData = new JsonParser<SpriteData>().fromJson(Assets.text(jsonPath), jsonPath.format());
		var tempData:Dynamic = json(jsonPath);

		var charData:CharacterData = null;
		if (type == IsCharacterSprite && Reflect.hasField(tempData, 'character')) {
			var gottenData:CharacterData = null;
			var typeData:SpriteData = typeData;
			try {
				gottenData = json(jsonPath).character;
				typeData.character.color = FlxColor.fromString(gottenData.color);
			} catch(error:haxe.Exception)
				log(error.message, ErrorMessage);
			charData = {
				camera: new Position(Reflect.getProperty(typeData.character.camera, 'x'), Reflect.getProperty(typeData.character.camera, 'y')),
				color: typeData.character.color,
				icon: typeData.character.icon,
				singlength: typeData.character.singlength
			}
		}

		var beatData:BeatData = null;
		if (type.isBeatType && Reflect.hasField(tempData, 'beat')) {
			var typeData:BeatData = typeData.beat;
			beatData = {
				interval: typeData.interval,
				skipnegative: typeData.skipnegative
			}
		}

		var data:Dynamic = {}
		if (Reflect.hasField(typeData, 'offsets'))
			try {
				data.offsets = {
					position: new Position(Reflect.getProperty(typeData.offsets.position, 'x'), Reflect.getProperty(typeData.offsets.position, 'y')),
					flip: new TypeXY<Bool>(Reflect.getProperty(typeData.offsets.flip, 'x'), Reflect.getProperty(typeData.offsets.flip, 'y')),
					scale: new Position(Reflect.getProperty(typeData.offsets.scale, 'x'), Reflect.getProperty(typeData.offsets.scale, 'y'))
				}
			} catch(error:haxe.Exception) {
				data.offsets = {
					position: new Position(),
					flip: new TypeXY<Bool>(false, false),
					scale: new Position(1, 1)
				}
			}
		else
			data.offsets = {
				position: new Position(),
				flip: new TypeXY<Bool>(false, false),
				scale: new Position(1, 1)
			}

		data.asset = typeData.asset;
		if (Reflect.hasField(typeData.asset, 'dimensions'))
			data.asset.dimensions = new TypeXY<Int>(Reflect.getProperty(typeData.asset.dimensions, 'x') ?? 0, Reflect.getProperty(typeData.asset.dimensions, 'y') ?? 0);
		data.animations = [];
		for (anim in typeData.animations) {
			var slot:AnimationTyping = cast {}
			slot.name = anim.name;
			if (Reflect.hasField(anim, 'tag')) slot.tag = anim.tag ?? slot.name;
			if (Reflect.hasField(anim, 'swapKey')) slot.swapKey = anim.swapKey ?? '';
			if (Reflect.hasField(anim, 'flipKey')) slot.flipKey = anim.flipKey ?? '';
			slot.indices = anim.indices ?? [];
			slot.offset = new Position(Reflect.getProperty(anim.offset, 'x'), Reflect.getProperty(anim.offset, 'y'));
			slot.flip = new TypeXY<Bool>(Reflect.getProperty(anim.flip, 'x'), Reflect.getProperty(anim.flip, 'y'));
			slot.loop = anim.loop ?? false;
			slot.fps = anim.fps ?? 24;
			data.animations.push(slot);
		}

		if (Reflect.hasField(typeData, 'starting')) {
			try {
				data.starting = {
					position: new Position(Reflect.getProperty(typeData.starting.position, 'x'), Reflect.getProperty(typeData.starting.position, 'y')),
					flip: new TypeXY<Bool>(Reflect.getProperty(typeData.starting.flip, 'x'), Reflect.getProperty(typeData.starting.flip, 'y')),
					scale: new Position(Reflect.getProperty(typeData.starting.scale, 'x'), Reflect.getProperty(typeData.starting.scale, 'y'))
				}
			} catch(error:haxe.Exception) {}
		}

		data.swapAnimTriggers = typeData.swapAnimTriggers;
		data.flipAnimTrigger = typeData.flipAnimTrigger;
		data.antialiasing = typeData.antialiasing;

		if (charData != null) data.character = charData;
		if (beatData != null) data.beat = beatData;

		return data;
	}

	/**
	 * Parses a chart json.
	 * @param song The song folder name.
	 * @param difficulty The difficulty key.
	 * @param variant The variant key.
	 * @return ChartData ~ The parsed chart json.
	 */
	inline public static function chart(song:String, difficulty:String = 'normal', variant:String = 'normal'):ChartData {
		var jsonPath:ModPath = Paths.chart(song, difficulty, variant);
		return new JsonParser<ChartData>().fromJson(Assets.text(jsonPath), jsonPath.format());
	}

	/**
	 * Parses a SpriteText json.
	 * @param font The font json file name.
	 * @return SpriteTextSetup ~ The parsed font json.
	 */
	inline public static function spriteFont(font:ModPath):SpriteTextSetup {
		var jsonPath:ModPath = Paths.spriteFont(font);
		return new JsonParser<SpriteTextSetup>().fromJson(Assets.text(jsonPath), jsonPath.format());
	}

	/**
	 * Parses a songs meta json.
	 * @param name The song folder name.
	 * @return SongData ~ The parsed meta json.
	 */
	public static function song(name:ModPath):SongData {
		var jsonPath:ModPath = Paths.json('content/songs/${name.path}/meta');
		var contents:SongParse = new JsonParser<SongParse>().fromJson(Assets.text(jsonPath), jsonPath.format());
		return {
			name: json('content/songs/${name.path}/audio').name,
			folder: name.path,
			icon: contents.icon,
			startingDiff: contents.startingDiff ?? (Math.floor(contents.difficulties.length / 2) - 1),
			difficulties: [
				for (difficulty in contents.difficulties)
					difficulty.toLowerCase()
			],
			variants: [
				for (variant in contents.variants ?? [
					for (difficulty in contents.difficulties)
						FunkinUtil.getDifficultyVariant(difficulty)
				])
					variant.toLowerCase()
			],
			color: contents.color,
			allowedModes: contents.allowedModes
		}
	}
}