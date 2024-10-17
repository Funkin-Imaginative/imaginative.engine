package backend.scripting;

import backend.scripting.types.HaxeScript;
import backend.scripting.types.LuaScript;

enum abstract ScriptType(String) from String to String {
	var UNREGISTERED;
	var HAXE;
	var LUA;
	var INVAILD;

	public var dummy(get, never):Bool;
	inline function get_dummy():Bool
		return this == UNREGISTERED || this == INVAILD;
}

/**
 * All your scripting needs are right here!
 * @author Class started by @Zyflx. Expanded on by @rodney528.
 */
class Script extends FlxBasic implements IScript {
	/**
	 * All possible extension types.
	 */
	public static final exts:Array<String> = [
		for (exts in [HaxeScript.exts, LuaScript.exts])
			for (ext in exts)
				ext
	];

	public var rootPath:String;
	public var path:String;
	public var name:String;
	public var extension:String;

	public static function create(file:String, pathType:FunkinPath = ANY, getAllInstances:Bool = true):Array<Script> {
		var scriptPath:String->Array<String> = (file:String) -> {
			if (getAllInstances) {
				var result:Array<String> = [];
				for (ext in exts)
					for (instance in ModConfig.getAllInstancesOfFile('$file.$ext', pathType))
						result.push(instance);
				return result;
			} else return [Paths.script(file, pathType)];
		}
		final paths:Array<String> = scriptPath(file);
		#if debug
		for (path in paths)
			if (path.trim() != '')
				trace(path);
		#end
		var scripts:Array<Script> = [];
		for (path in paths) {
			switch (FilePath.extension(path).toLowerCase()) {
				case 'haxe' | 'hx' | 'hscript' | 'hsc' | 'hxs' | 'hxc' | 'hxp':
					scripts.push(new HaxeScript(path));
				case 'lua':
					scripts.push(new LuaScript(path));
				default:
					trace('Extension "${FilePath.extension(path).toLowerCase()}" is invaild!');
					scripts.push(new InvaildScript(path));
			}
		}
		return scripts;
	}

	var canRun:Bool = false;
	public var type(get, never):ScriptType;
	inline function get_type():ScriptType {
		return switch (this.getClassName()) {
			case 'Script':        	UNREGISTERED;
			case 'HaxeScript':    	HAXE;
			case 'LuaScript':     	LUA;
			case 'InvaildScript': 	INVAILD;
			default:              	INVAILD;
		}
	}

	/* public static function getScriptImports(script:Script):Map<String, Dynamic>
		return []; */

	function renderNecessities():Void {}

	public function new(path:String):Void {
		super();
		rootPath = path;
		name = FilePath.withoutDirectory(path);
		extension = FilePath.extension(path);
		this.path = path;
		renderScript(path);
		renderNecessities();
		GlobalScript.call('scriptCreated', [this, type]);
	}

	var code:String = '';
	function renderScript(path:String):Void {}
	function loadCodeString(code:String):Void {}

	public var loaded:Bool = false;
	public function load():Void
		if (!loaded)
			loadCodeString(code);
	public function reload():Void {}

	public var parent(get, set):Dynamic;
	function get_parent():Dynamic return null;
	function set_parent(value:Dynamic):Dynamic return null;

	public function setPublicVars(map:Map<String, Dynamic>):Void {}

	public function set(variable:String, value:Dynamic):Void {}
	public function get(variable:String, ?def:Dynamic):Dynamic return def;
	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic return null;
	public function event<SC:ScriptEvent>(func:String, event:SC):SC return event;

	override public function destroy():Void {
		call('destroy');
		super.destroy();
	}
}
