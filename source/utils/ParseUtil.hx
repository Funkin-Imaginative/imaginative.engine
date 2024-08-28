package utils;

enum abstract CharDataType(String) from String to String {
	var BASE = 'Funkin';
	var PSYCH = 'Psych';
	var CNE = 'Codename';
	var IMAG = 'Imaginative';
}

class ParseUtil {
	inline public static function json(path:String, ?pathType:FunkinPath):Dynamic return haxe.Json.parse(Paths.getContent(Paths.json(path, pathType)));
}