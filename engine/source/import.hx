#if !macro
#if Tracy_Debugger
import cpp.vm.tracy.TracyProfiler;
#end

/* Haxe */
import haxe.io.Path as FilePath;

using Lambda;

/* Flixel */
import flixel.FlxG;

/* Engine */
import imaginative.backend.systems.Assets;
import imaginative.backend.systems.Modding;
import imaginative.backend.systems.Paths;

using imaginative.backend.utils.ArrayUtil;
using imaginative.backend.utils.StringUtil;
#end