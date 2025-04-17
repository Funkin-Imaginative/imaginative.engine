package imaginative.backend.converters;

import imaginative.states.editors.ChartEditor;

typedef FNFCodenameFormat = {
	strumLines:Array<FNFCodenameStrumline>,
	events:Array<FNFCodenameEvent>,
	meta:FNFCodenameMeta,
	codenameChart:Bool,
	stage:String,
	scrollSpeed:Float,
	noteTypes:Array<String>
}

typedef FNFCodenameStrumline = {
	position:String,
	strumScale:Float,
	visible:Bool,
	type:Int,
	characters:Array<String>,
	strumPos:Array<Float>,
	strumLinePos:Float,
	vocalsSuffix:String,
	notes:Array<FNFCodenameNote>
}

typedef FNFCodenameNote = {
	time:Float,
	id:Int,
	sLen:Float,
	type:Int
}

typedef FNFCodenameEvent = {
	time:Float,
	name:String,
	params:Array<Dynamic>
}

typedef FNFCodenameMeta = {
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
		var audio = haxe.Json.parse(audioData)
		if (Reflect.hasField(audio, 'customValues')) {
			var data:FNFCodenameMeta = new JsonParser<FNFCodenameMeta>().fromJson(metaData, 'Codename Meta (Audio)');
			return fromCodenameMeta(data, true);
		} else return audio;
	}
	public function convertMeta(metaData:String):SongData {
		var meta = haxe.Json.parse(metaData)
		if (Reflect.hasField(meta, 'customValues')) {
			var data:FNFCodenameMeta = new JsonParser<FNFCodenameMeta>().fromJson(metaData, 'Codename Meta');
			return fromCodenameMeta(data);
		} else return meta;
	}
	public function convertChart(chartData:String):ChartData {
		var chart = haxe.Json.parse(chartData);
		if (Reflect.hasField(chart, 'codenameChart')) {
			var data:FNFCodenameFormat = new JsonParser<FNFCodenameFormat>().fromJson(chartData, 'Codename Chart');
			return fromCodenameChart(data);
		} else return chart;
	}

	// Codename
	public function fromCodenameMeta(meta:FNFCodenameMeta, isAudio:Bool = false):SongData {
		return {
			name: meta.displayName,
			folder: meta.name,
			icon: meta.icon,
			difficulties: [
				for (difficulty in meta.difficulties)
					difficulty.toLowerCase()
			],
			color: meta.color,
			allowedModes: {
				playAsEnemy: meta.opponentModeAllowed,
				p2AsEnemy: meta.coopAllowed
			}
		}
	}
	public function fromCodenameChart(chart:FNFCodenameFormat):ChartData {
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
			speed: chart.scrollSpeed
			stage: chart.stage,
			fields: fields,
			characters: characters,
			fieldSettings: {
				order: [for (field in fields) field.tag],
				enemy: [for (field in fields) field.tag][0],
				player: [for (field in fields) field.tag][1]
			}
			hud: 'funkin',
			events: []
		}
	}

}