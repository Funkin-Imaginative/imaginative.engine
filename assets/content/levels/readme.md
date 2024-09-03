# ../content/levels/
Levels are what the weeks are, they contain all the songs and difficulties that'll load.
When typing out the song listing make sure you type out the **folder** name.
When typing out the difficulty listing make sure you type out the name in **all** lowercase.

vVv level json example below vVv
```json
{
	"title": "Daddy Dearest",
	"songs": ["Bopeebo", "Fresh", "DadBattle"],
	"startingDiff": 1,
	"difficulties": ["easy", "normal", "hard", "erect", "nightmare"],
	"objects": [
		{"object": "characters/dad"},
		{"object": "characters/boyfriend"},
		{"object": "characters/gf"}
	],
	"color": "#F9CF51"
}
```
example from: [`../content/levels/Week 1.json`](https://github.com/rodney528/Imaginative-Engine-Development/blob/main/assets/content/levels/Week%201.json)