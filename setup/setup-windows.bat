@echo off
color 0a
cd ..
@echo on
echo Thank you for wanting to use Imaginative Engine!
pause
haxelib install openfl 9.2.2 --always
haxelib install lime 8.1.2 --always
haxelib git flixel https://github.com/FNF-CNE-Devs/flixel --always
haxelib git flixel-addons https://github.com/FNF-CNE-Devs/flixel-addons --always
haxelib git hscript-improved https://github.com/FNF-CNE-Devs/hscript-improved --always
haxelib install hxdiscord_rpc --always
haxelib install hxvlc --always
haxelib install thx.semver --always
echo Finished installing the libraries!
pause