# ../content/songs/
This is where you can store all your songs from its chart to audio.

Folder Layout
```
audio/
	erect/
		Inst.wav
		Voices-Enemy.wav
		Voices-Player.wav
	Inst.ogg
	Voices.ogg
charts/
	erect/
		erect.json
		nightmare.json
	easy.json
	hard.json
	normal.json
audio-erect.json
audio.json
meta.json
```
audio json explained in `../music/`

vVv meta json example below vVv
```json
{
	"folder": "Philly Nice",
	"icon": "pico",
	"color": "#941653",
	"startingDiff": 1,
	"difficulties": ["easy", "normal", "hard", "erect", "nightmare"],
	"allowedModes": {
		"playAsEnemy": true,
		"p2AsEnemy": true
	}
}
```
example from: `../content/songs/Philly Nice/meta.json`