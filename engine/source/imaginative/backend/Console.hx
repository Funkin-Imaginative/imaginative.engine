package imaginative.backend;

import haxe.Log;
import haxe.PosInfos;

// import flixel.system.debug.log.LogStyle;
// import flixel.system.frontEnds.LogFrontEnd;

@SuppressWarnings('checkstyle:FieldDocComment')
enum abstract LogLevel(String) from String to String {
	var ErrorMessage = 'error';
	var WarningMessage = 'warning';
	var SystemMessage = 'system';
	var DebugMessage = 'debug';
	var LogMessage = 'log';
}

/**
 * An internal enum used for stating where a trace came from.
 */
enum LogFrom {
	FromSource;
	FromHaxe;
	FromLua;
	FromUnknown;
}

class Console {
	static var ogTrace(default, null):(Dynamic, ?PosInfos) -> Void;

	static var initialized(default, null):Bool = false;
	@:allow(imaginative.states.EngineProcess)
	inline static function init():Void {
		if (!initialized) {
			initialized = true;
			ogTrace = Log.trace;
			@:privateAccess FlxG.log._standardTraceFunction = Log.trace = (value:Dynamic, ?infos:PosInfos) ->
				log(value, infos);

			// FlxG.log.style.onLog = (data:Any, ?pos:PosInfos) -> {
			// 	var level:LogLevel = LogMessage;
			// 	if (style == LogStyle.CONSOLE) level = SystemMessage;
			// 	else if (style == LogStyle.ERROR) level = ErrorMessage;
			// 	else if (style == LogStyle.NORMAL) level = SystemMessage;
			// 	else if (style == LogStyle.NOTICE) level = SystemMessage;
			// 	else if (style == LogStyle.WARNING) level = WarningMessage;
			// 	_log(data, level);
			// }

			_log('					Initialized Custom Trace System\n		Thank you for using Imaginative Engine, hope you like it!\n^w^');
		}
	}

	static function formatValueInfo(value:Dynamic):String {
		return switch (Type.getClass(value)) {
			case String: cast(value, String).replace('\t', '    ').replace('	', '    '); // keep consistant length
			case Array: '[${[for (lol in cast(value, Array<Dynamic>)) formatValueInfo(lol)].formatArray()}]';
			default: Std.string(value);
		}
	}
	static function formatLogInfo(value:Dynamic, level:LogLevel, ?file:String, ?line:Int, ?extra:Array<Dynamic>, from:LogFrom = FromSource):String {
		var log:String = switch (level) {
			case ErrorMessage:      'Error';
			case WarningMessage:  'Warning';
			case SystemMessage:    'System';
			case DebugMessage:      'Debug';
			case LogMessage:      'Message';
		}

		var description:Null<String> = switch (level) {
			case ErrorMessage:
				'It seems an error has ourred!';
			case WarningMessage:
				'Uh oh, something happened!';
			case SystemMessage:
				null;
			case DebugMessage:
				null;
			case LogMessage:
				null;
		}

		var info:String = file ?? 'Unknown';
		if (line != null)
			info += ':$line';

		var who:String = switch (from) {
			case FromSource: 'Source';
			case FromHaxe: 'Haxe Script';
			case FromLua: 'Lua Script';
			default: 'Unknown';
		}

		var message:String = formatValueInfo(value);
		if (extra != null && !extra.empty())
			message += extra.formatArray();
		var traceMessage:String = '\n$log${description == null ? '' : ': $description'} ~${info.isNullOrEmpty() ? '' : ' "$info"'} [$who]\n$message';
		#if TRACY_DEBUGGER
		TracyProfiler.message(traceMessage, FlxColor.WHITE);
		#end
		return traceMessage;
	}

	/**
	 * The engines special trace function.
	 * @param value The information you want to pop on to the console.
	 * @param level The level status of the message.
	 * @param from States if script or source logged this.
	 * @param infos The code position information.
	 */
	public static function log(value:Dynamic, level:LogLevel = LogMessage, from:LogFrom = FromSource, ?infos:PosInfos):Void {
		// When compiling debug it's basically forced off the DebugMessage level in a sense.
		#if !debug
		if (Settings.setup.debugMode && level != DebugMessage)
			return;
		if (Settings.setup.ignoreLogWarnings && level != WarningMessage)
			return;
		#end
		Sys.println(formatLogInfo(value, level, infos.fileName, infos.lineNumber, infos.customParams, from));
	}

	/**
	 * It's just log, but without the file and line in the print.
	 * @param value The information you want to pop on to the console.
	 * @param level The level status of the message.
	 * @param from States if script or source logged this.
	 */
	public static function _log(value:Dynamic, level:LogLevel = SystemMessage, from:LogFrom = FromSource):Void {
		// When compiling debug it's basically forced off the DebugMessage level in a sense.
		#if !debug
		if (Settings.setup.debugMode && level != DebugMessage)
			return;
		if (Settings.setup.ignoreLogWarnings && level != WarningMessage)
			return;
		#end
		Sys.println(formatLogInfo(value, level, '', from));
	}
}