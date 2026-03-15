package imaginative.backend;

import haxe.Log;
import haxe.PosInfos;
import flixel.system.debug.log.LogStyle;

// stole from my friend @NebulaStellaNova lol
@SuppressWarnings('checkstyle:FieldDocComment')
enum abstract ConsoleColors(String) from String to String {
	var RESET =         '\033[0m';
	var BLACK =         '\x1b[30m';
	var DARKRED =       '\x1b[31m';
	var DARKGREEN =     '\x1b[32m';
	var DARKYELLOW =    '\x1b[33m';
	var ORANGE =        '\x1b[33m';
	var DARKBLUE =      '\x1b[34m';
	var PURPLE =        '\x1b[35m';
	var DARKMAGENTA =   '\x1b[35m';
	var DARKCYAN =      '\x1b[36m';
	var LIGHTGRAY =     '\x1b[37m';
	var GRAY =          '\x1b[90m';
	var RED =           '\x1b[91m';
	var GREEN =         '\x1b[92m';
	var YELLOW =        '\x1b[93m';
	var BLUE =          '\x1b[94m';
	var MAGENTA =       '\x1b[95m';
	var CYAN =          '\x1b[96m';
	var WHITE =         '\x1b[97m';

	public static final mapList:Map<String, ConsoleColors> = [
		'reset' => RESET,
		'black' => BLACK,
		'darkred' => DARKRED,
		'darkgreen' => DARKGREEN,
		'darkyellow' => DARKYELLOW,
		'orange' => ORANGE,
		'darkblue' => DARKBLUE,
		'purple' => PURPLE,
		'darkmagenta' => DARKMAGENTA,
		'darkcyan' => DARKCYAN,
		'lightgray' => LIGHTGRAY,
		'gray' => GRAY,
		'red' => RED,
		'green' => GREEN,
		'yellow' => YELLOW,
		'blue' => BLUE,
		'magenta' => MAGENTA,
		'cyan' => CYAN,
		'white' => WHITE
	];

	public static function format(input:String):String {
		for (name => color in mapList) {
			input = input.replace('#$name', color);
			input = input.replace('#${name.toUpperCase()}', color);
			input = input.replace('$' + name, color);
			input = input.replace('$' + name.toUpperCase(), color);
			input = input.replace('<$name>', color);
			input = input.replace('<${name.toUpperCase()}>', color);
		}
		return input;
	}
}

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
private enum LogFrom {
	FromSource;
	FromHaxe;
	FromLua;
	FromUnknown;
}

class Console {
	static var errorColor:ConsoleColors = RED;
	static var warningColor:ConsoleColors = YELLOW;
	static var systemColor:ConsoleColors = BLUE;
	static var debugColor:ConsoleColors = GREEN;
	static var logColor:ConsoleColors = LIGHTGRAY;

	static var ogTrace(default, null):(Dynamic, ?PosInfos) -> Void;

	static var initialized(default, null):Bool = false;
	@:allow(imaginative.backend.system.Main)
	inline static function init():Void {
		if (!initialized) {
			initialized = true;
			ogTrace = Log.trace;
			Log.trace = (value:Dynamic, ?infos:PosInfos) -> log(value, infos);
			@:privateAccess FlxG.log._standardTraceFunction = (value:Dynamic, ?infos:PosInfos) -> {}

			final styles:Array<LogStyle> = [LogStyle.NORMAL, LogStyle.WARNING, LogStyle.ERROR, LogStyle.NOTICE, LogStyle.CONSOLE];
			for (style in styles) {
				style.onLog.add((data:Any, ?pos:PosInfos) -> log(data, switch (style.prefix) {
					case '[WARNING]': WarningMessage;
					case '[ERROR]': ErrorMessage;
					default: SystemMessage;
				}, pos));
			}
			styles.resize(0);

			_log('					<purple>Initialized Custom Trace System<reset>\n		Thank you for using <yellow>Imaginative Engine<reset>, hope you like it!\n^w^');
		}
	}

	// TODO: Move to a different class.
	static function formatValueInfo(value:Dynamic, addArrayBrackets:Bool = false, addStringQuotes:Bool = false):String {
		if (value is String) {
			var output = cast(value, String).replace('\t', '    ').replace('	', '    '); // keep consistant length
			if (addStringQuotes) output = '"$output"';
			return output;
		}
		if (value is Array) {
			var output = [for (lol in cast(value, Array<Dynamic>)) formatValueInfo(lol, true, true)].formatArray();
			if (addArrayBrackets) output = '[$output]';
			return output;
		}
		if (value is haxe.Constraints.IMap) {
			var output = [for (key => value in cast(value, Map<Dynamic, Dynamic>)) formatValueInfo(key, true, true) + ' => ' + formatValueInfo(value, true, true)].formatArray();
			if (addArrayBrackets) output = '[$output]';
			return output;
		}
		if (value is Class)
			return '[${value.getClassName(true)}]';
		return Std.string(value);
	}
	static function formatLogInfo(value:Dynamic, level:LogLevel, ?file:String, ?line:Int, ?extra:Array<Dynamic>, from:LogFrom = FromSource):String {
		final color:ConsoleColors = switch (level) {
			case ErrorMessage:        errorColor;
			case WarningMessage:    warningColor;
			case SystemMessage:      systemColor;
			case DebugMessage:        debugColor;
			case LogMessage:            logColor;
		}
		final log:String = switch (level) {
			case ErrorMessage:        'Error';
			case WarningMessage:    'Warning';
			case SystemMessage:      'System';
			case DebugMessage:        'Debug';
			case LogMessage:        'Message';
		}

		final description:Null<String> = switch (level) {
			case ErrorMessage: 'It seems an error has occurred!';
			case WarningMessage: 'Uh oh, something happened!';
			default: null;
		}

		var info:String = file ?? 'Unknown';
		if (line != null) info += ':$line';

		final who:String = switch (from) {
			case FromSource: '<gray>Source';
			case FromHaxe: '<orange>Haxe Script';
			case FromLua: '<blue>Lua Script';
			default: '<red>Unknown';
		}

		var message:String = formatValueInfo(value, from == FromSource || from == FromUnknown);
		if (extra != null && !extra.empty())
			message += formatValueInfo(extra);
		final traceMessage:String = ConsoleColors.format('\n$color$log${description == null ? '' : ': $description'} ~${info.isNullOrEmpty() ? '' : ' "$info"'} [$who$color]\n<reset>$message');
		#if TRACY_DEBUGGER
		final tracyMessage:String = {
			var _:String = traceMessage;
			for (name => color in ConsoleColors.mapList)
				_ = _.replace(color, '');
			_;
		}
		TracyProfiler.message(tracyMessage, FlxColor.WHITE);
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
		if (Settings?.setup?.debugMode ?? false && level != DebugMessage)
			return;
		if (Settings?.setup?.ignoreLogWarnings ?? false && level != WarningMessage)
			return;
		#end
		Sys.println(formatLogInfo(value, level, infos.fileName, infos.lineNumber, infos.customParams, from));
	}

	/**
	 * It's just log but without the file and line in the print.
	 * @param value The information you want to pop on to the console.
	 * @param level The level status of the message.
	 * @param from States if script or source logged this.
	 */
	public static function _log(value:Dynamic, level:LogLevel = SystemMessage, from:LogFrom = FromSource):Void {
		// When compiling debug it's basically forced off the DebugMessage level in a sense.
		#if !debug
		if (Settings?.setup?.debugMode ?? false && level != DebugMessage)
			return;
		if (Settings?.setup?.ignoreLogWarnings ?? false && level != WarningMessage)
			return;
		#end
		Sys.println(formatLogInfo(value, level, '', from));
	}
}