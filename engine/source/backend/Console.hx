package backend;

import haxe.Log;
import haxe.PosInfos;
import flixel.system.debug.log.LogStyle;
import flixel.system.frontEnds.LogFrontEnd;

enum abstract LogLevel(String) from String to String {
	var ErrorMessage = 'error';
	var WarningMessage = 'warning';
	var SystemMessage = 'system';
	var DebugMessage = 'debug';
	var LogMessage = 'log';
}

class Console {
	static final ogTrace:(Dynamic, ?PosInfos) -> Void = Log.trace;

	@:allow(backend.system.Main.new)
	static function init():Void {
		Log.trace = (value:Dynamic, ?infos:PosInfos) -> {
			log(value, infos);
		}

		LogFrontEnd.onLogs = (data:Dynamic, style:LogStyle, fireOnce:Bool) -> {
			var level:LogLevel = LogMessage;
			if (style == LogStyle.CONSOLE) level = SystemMessage;
			else if (style == LogStyle.ERROR) level = ErrorMessage;
			else if (style == LogStyle.NORMAL) level = SystemMessage;
			else if (style == LogStyle.NOTICE) level = SystemMessage;
			else if (style == LogStyle.WARNING) level = WarningMessage;

			log(data, level, null);
		}
	}

	static function formatInfos(value:Dynamic, infos:PosInfos):String {
		var content:String = Std.string(value);
		if (infos == null)
			return content;
		var front:String = '${FilePath.withoutExtension(infos.fileName.replace('/', '.'))}:${infos.lineNumber}';
		if (infos.customParams != null)
			for (value in infos.customParams)
				content += ', ${Std.string(value)}';
		return '$front: $content';
	}

	static function formatLogLevel(level:LogLevel):String {
		var result:String = '[';
		result += switch (level) { // the numbers are the word lengths
			case ErrorMessage:
				'    ERROR    '; // 5
			case WarningMessage:
				'   WARNING   '; // 7
			case SystemMessage:
				'     SYS     '; // 3
			case DebugMessage:
				'    DEBUG    '; // 5
			case LogMessage:
				'   MESSAGE   '; // 7
		}
		result += '] ';
		return result;
	}

	/**
	 * The engine's special trace function.
	 * @param value The information you want to pop on to the console.
	 * @param level The level status of the message.
	 * @param infos The code position information.
	 */
	public static function log(value:Dynamic, level:LogLevel = LogMessage, ?infos:PosInfos):Void {
		// When compiling debug it's basically forced off DebugMessage level in a sense.
		#if !debug
		if (Settings.setup.debugMode && level != DebugMessage)
			return;
		if (Settings.setup.ignoreLogWarnings && level != WarningMessage)
			return;
		#end
		Sys.println(formatLogLevel(level) + formatInfos(value, infos));
	}
}