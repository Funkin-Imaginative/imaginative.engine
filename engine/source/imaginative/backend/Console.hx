package imaginative.backend;

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

/**
 * Just an enum, since, you wont need to use it. When scripting anyway.
 */
enum LogFrom {
	FromSource;
	FromHaxe;
	FromLua;
	FromUnknown;
}

class Console {
	static final ogTrace:(Dynamic, ?PosInfos) -> Void = Log.trace;

	@:allow(imaginative.backend.system.Main.new)
	inline static function init():Void {
		if (Log.trace != ogTrace) {
			_log('You can\'t run this again!');
			return;
		}

		Log.trace = (value:Dynamic, ?infos:PosInfos) ->
			log(value, infos);

		LogFrontEnd.onLogs = (data:Dynamic, style:LogStyle, fireOnce:Bool) -> {
			var level:LogLevel = LogMessage;
			if (style == LogStyle.CONSOLE) level = SystemMessage;
			else if (style == LogStyle.ERROR) level = ErrorMessage;
			else if (style == LogStyle.NORMAL) level = SystemMessage;
			else if (style == LogStyle.NOTICE) level = SystemMessage;
			else if (style == LogStyle.WARNING) level = WarningMessage;
			_log(data, level);
		}

		var initMessage = 'Initialized Custom Trace System';
		#if CONSOLE_FANCY_PRINT
		var officialMessage:String = #if official 'Fancy print enabled.' #else 'Thank you for using fancy print, hope you like it!' #end;
		_log('$officialMessage\n\t$initMessage');
		#else
		_log(initMessage);
		#end
	}

	static function formatLogInfo(value:Dynamic, level:LogLevel, ?file:String, ?line:Int, ?extra:Array<Dynamic>, from:LogFrom = FromSource):String {
		var log:String = switch (level) {
			case ErrorMessage:      'Error';
			case WarningMessage:  'Warning';
			case SystemMessage:    'System';
			case DebugMessage:      'Debug';
			case LogMessage:      'Message';
		}

		var info:String = '${file ?? 'Unknown'}';
		info += line == null ? '' : ':$line';
		if (info.trim() != '')
			info += '\n';

		var message:String = Std.string(value).replace('\t', '    ').replace('	', '    '); // keep consistant length

		#if CONSOLE_FANCY_PRINT
		var who:String = switch (from) {
			case FromSource: 'Source';
			case FromHaxe: 'Haxe Script';
			case FromLua: 'Lua Script';
			default: 'Unknown';
		}
		var description:String = switch (level) {
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
		if (description != null)
			description = ' $description';
		var split:Array<String> = '$log ~${description ?? ''}\n$info$message\nThrown from $who.'.split('\n');
		var length:Int = 0;
		for (i => _ in split) {
			if (length < split[i].length)
				length = split[i].length;
		}
		for (i => item in split) {
			var l:String = i == 0 ? ' /' : (i == (split.length - 1) ? ' \\' : '| ');
			var r:String = i == 0 ? '\\ ' : (i == (split.length - 1) ? '/ ' : ' |');
			var lineLen:Int = item.length;
			var edge:Bool = i == 0 || i == (split.length - 1);
			split[i] = '$l $item${[for (_ in 0...length - lineLen) ' '].join('')} $r';
		}
		split.insert(0, '   * ${[for (_ in 0...length - 4) '-'].join('')} *');
		split.insert(0, '');
		split.push('   * ${[for (_ in 0...length - 4) '-'].join('')} *');
		return split.join('\n');
		#else
		if (info.trim() != '')
			info = '"$info" ~ ';
		if (extra != null)
			for (value in extra)
				message += ', ${Std.string(value)}';
		return '$log ~ $info$message';
		#end
	}

	/**
	 * The engine's special trace function.
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
		Sys.println(formatLogInfo(value, level, infos.fileName, infos.lineNumber, from));
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