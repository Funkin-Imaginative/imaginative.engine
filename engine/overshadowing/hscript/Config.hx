package hscript;

class Config {
	public static final ALLOWED_CUSTOM_CLASSES = [
		'flixel',
		'imaginative'
	];

	public static final ALLOWED_ABSTRACT_AND_ENUM = [
		'flixel',
		'imaginative',
		'openfl',
		'haxe.xml',
		'haxe.CallStack',
	];

	public static final DISALLOW_CUSTOM_CLASSES = [
		'imaginative.backend.Console'
	];

	public static final DISALLOW_ABSTRACT_AND_ENUM = [];
}