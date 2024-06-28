package fnf.backend.interfaces;

interface IReloadable {
	var reloading(default, null):Bool;
	function reload(hard:Bool = false):Void;
}