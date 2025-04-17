package imaginative.backend.converters;

import json2object.JsonParser;
import imaginative.states.editors.ChartEditor;

typedef CNE_ChartData = {
	strumLines:Array<CNE_ChartStrumLine>,
	events:Array<CNE_ChartEvent>,
	meta:CNE_SongMeta,
	codenameChart:Bool,
	stage:String,
	scrollSpeed:Float,
	noteTypes:Array<String>
}

typedef CNE_ChartStrumLine = {
	position:String,
	strumScale:Float,
	visible:Bool,
	type:Int,
	characters:Array<String>,
	strumPos:Array<Float>,
	strumLinePos:Float,
	vocalsSuffix:String,
	notes:Array<CNE_ChartNote>
}

typedef CNE_ChartNote = {
	time:Float,
	id:Int,
	sLen:Float,
	type:Int
}

typedef CNE_ChartEvent = {
	time:Float,
	name:String,
	params:Array<Dynamic>
}

typedef CNE_SongMeta = {
	name:String,
	?bpm:Float,
	?displayName:String,
	?beatsPerMeasure:Float,
	?stepsPerBeat:Float,
	?needsVoices:Bool,
	?icon:String,
	?color:Dynamic,
	?difficulties:Array<String>,
	?coopAllowed:Bool,
	?opponentModeAllowed:Bool,
	?customValues:Dynamic
}

class ChartConverter {
	// Global
	public function convertAudio(audioData:String):SongData {
		var audio = Assets.json(audioData);
		if (Reflect.hasField(audio, 'customValues')) {
			var data:CNE_SongMeta = new JsonParser<CNE_SongMeta>().fromJson(metaData, 'Codename Meta (Audio)');
			return fromCodenameMeta(data, true);
		} else return audio;
	}
	public function convertMeta(metaData:String):SongData {
		var meta = Assets.json(metaData);
		if (Reflect.hasField(meta, 'customValues')) {
			var data:CNE_SongMeta = new JsonParser<CNE_SongMeta>().fromJson(metaData, 'Codename Meta');
			return fromCodenameMeta(data);
		} else return meta;
	}
	public function convertChart(chartData:String):ChartData {
		var chart = Assets.json(chartData);
		if (Reflect.hasField(chart, 'codenameChart')) {
			var data:CNE_ChartData = new JsonParser<CNE_ChartData>().fromJson(chartData, 'Codename Chart');
			return fromCodenameChart(data);
		} else return chart;
	}

	// Codename
	public function fromCodenameMeta(meta:CNE_SongMeta, isAudio:Bool = false):SongData {
		var diffs:Array<String> = [
			for (difficulty in meta.difficulties)
				difficulty.toLowerCase()
		];
		return {
			name: meta.displayName,
			folder: meta.name,
			icon: meta.icon,
			startingDiff: Math.floor(meta.difficulties.length / 2) - 1,
			difficulties: diffs,
			variants: [
				for (difficulty in diffs)
					FunkinUtil.getDifficultyVariant(difficulty)
			],
			color: meta.color,
			allowedModes: {
				playAsEnemy: meta.opponentModeAllowed,
				p2AsEnemy: meta.coopAllowed
			}
		}
	}
	public function fromCodenameChart(chart:CNE_ChartData):ChartData {
		var characters:Array<ChartCharacter> = [];
		var fields:Array<ChartField> = [];
		for (strumLine in chart.strumLines) {
			characters.push({
				tag: strumLine.characters[0],
				name: strumLine.characters[0],
				position: strumLine.position,
				vocals: strumLine.vocalSuffix.replace('-', '')
			});
			var notes:Array<ChartNote> = [];
			for (note in strumLine.notes) {
				notes.push({
					id: note.id,
					length: note.sLen,
					time: note.time,
					characters: [],
					type: chart.noteTypes[note.type]
				});
			}
			fields.push({
				tag: strumLine.position,
				characters: strumLine.characters,
				notes: notes,
				speed: null
			});
		}
		return {
			speed: chart.scrollSpeed,
			stage: chart.stage,
			fields: fields,
			characters: characters,
			fieldSettings: {
				order: [for (field in fields) field.tag],
				enemy: [for (field in fields) field.tag][0],
				player: [for (field in fields) field.tag][1]
			},
			hud: 'funkin',
			events: []
		}
	}

}