#if desktop
package backend.system;

/**
 * A class that simply points OpenALSoft to a custom configuration file when the game starts up.
 * The config overrides a few global OpenALSoft settings with the aim of improving audio quality on desktop targets.
 * @author From Psych Engine.
 */
#if !DISABLE_DCE @:keep #end class ALSoftConfig {
	@:allow(backend.system.Main.new)
	static function fuckDCE():Void {}

	static function __init__():Void {
		var origin:String = #if hl Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = FilePath.directory(FilePath.withoutExtension(origin));
		#if windows
		configPath += '/plugins/alsoft.ini';
		#elseif mac
		configPath = FilePath.directory(configPath) + '/Resources/plugins/alsoft.conf';
		#else
		configPath += '/plugins/alsoft.conf';
		#end

		Sys.putEnv('ALSOFT_CONF', configPath);
	}
}
#end