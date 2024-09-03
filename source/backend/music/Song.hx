package backend.music;

import backend.music.Section.SwagSection;
import haxe.Json;

typedef SwagSong = {
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
}

class Song {
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(song:String, diff:String):SwagSong
		return parseJSONshit(Paths.getFileContent(Paths.json('songs/${song.replace('.', '')}/$diff')));

	public static function parseJSONshit(rawJson:String):SwagSong {
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}