package backend;

import haxe.Json;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import backend.Section;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var boyfriend:String;
	var opponent:String;
	var girlfriend:String;
	var stage:String;

	var arrowSkin:String;
	var splashSkin:String;
}

class Song {
	public var song:String = 'test';
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String = 'NOTE_assets';
	public var splashSkin:String = 'noteSplashes';
	public var speed:Float = 1;
	public var stage:String = 'stage';
	public var boyfriend:String = 'bf';
	public var opponent:String = 'dad';
	public var girlfriend:String = 'gf';

	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if (songJson.boyfriend == null) {
			songJson.boyfriend = songJson.player1;
			songJson.player1 = null;
		}
		if (songJson.opponent == null) {
			songJson.opponent = songJson.player2;
			songJson.player2 = null;
		}
		if (songJson.girlfriend == null) {
			songJson.girlfriend = songJson.gfVersion;
			songJson.gfVersion = null;
		}

		if (songJson.events == null) {
			songJson.events = [];
			for (secNum in 0...songJson.notes.length) {
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len) {
					var note:Array<Dynamic> = notes[i];
					if (note[1] < 0) {
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}

	public function new(song, notes, bpm) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if (FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if (rawJson == null) {
			#if sys
			rawJson = File.getContent(Paths.json(formattedFolder + '/' + formattedSong)).trim();
			#else
			rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong)).trim();
			#end
		}

		while (!rawJson.endsWith("}")) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		var songJson:Dynamic = parseJSONshit(rawJson);
		if (jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong {
		return cast Json.parse(rawJson).song;
	}
}
