# commands/setup/
This is how you'll install the libraries the engine uses.

Just execute this below to get started!
```
haxe -cp commands -D analyzer-optimize --run Main setup
```
You could also just launch the bat or sh file in the setup folder.
> [!IMPORTANT]
> If your having trouble using the setup, try double checking your haxe version.
>
> Make sure it's version 4.3.6!
>
> To double check, just do this code below into a console like cmd or powershell.
> ```
> haxe --version
> ```

setup json example
```json
{
	"dependencies": [
		{
			"name": "flixel", "version": "git",
			"url": "https://github.com/CodenameCrew/cne-flixel",
			// Forces the dependencies of the library. If it already has dependencies it skips them so it being blank just skips dependencies.
			"dependencies": [{"name": "openfl"}, {"name": "lime"}]
		},

		{
			"name": "moonchart", "version": "git", "branch": "imaginative",
			"url": "https://github.com/Funkin-Imaginative/moonchart"
		},

		{"name": "hxvlc"}
	],
	// Anything listed here becomes optional.
	"questions": [
		{
			"name": "hxvlc",
			"description": "allow videos to be played"
		}
	]
}
```
