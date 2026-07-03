# ./commands/setup
This is how you'll install the libraries the engine uses.

Just execute this below to get started!
```
haxe -cp commands -D analyzer-optimize --run Main setup
```
You could also just launch the bat or sh file in the setup folder.
> [!IMPORTANT]
> If your having trouble using the setup, try double checking your haxe version.
>
> Make sure it's version 4.3.7!
>
> To double check, just do this code below into a console like cmd or powershell.
> ```
> haxe --version
> ```

setup json example
```json
{
	"hxcpp-debug-server": {
		"version": "git",
		"branch": "7459934666a473a4cc4d066ba4a93ef92f1ce94c",
		"url": "https://github.com/FunkinCrew/hxcpp-debugger",
		"dev": true,
		"checks": { "debug": true }
	},
	"hxWindowColorMode": {
		"checks": { "target": "windows" }
	},
	"hxvlc": {
		"version": "2.2.5",
		"dependencies": {}
	}
}
```