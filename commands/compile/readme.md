# commands/compile/
This is how you'll complie the engine, cause vscode tasks are a **bitch** when it comes to active configuration and args.

Actions don't use this since you **have** to specify, so yeah.

Just execute this below to get started!
```
haxe -cp commands -D analyzer-optimize --run Main compile
```
You could also just launch the bat or sh file in the compile folder.
> [!IMPORTANT]
> If your having trouble compiling, try double checking your haxe version.
>
> Make sure it's version 4.3.6!
>
> To double check, just do this code below into a console like cmd or powershell.
> ```
> haxe --version
> ```

> [!IMPORTANT]
> Make sure you create a `platform.txt` in the compile folder.
>
> Have it contain the name of your platform! (windows, mac or linux)