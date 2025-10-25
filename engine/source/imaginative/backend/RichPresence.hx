#if DISCORD_RICH_PRESENCE
package imaginative.backend;

import cpp.Function;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

// TODO: Get this class to work.
/**
 * Class for applying rich presence onto the users discord profile.
 * @author Zylfx
 */
class RichPresence {
	/**
	 * The client ID for the rich presence.
	 */
	public static var clientID(default, set):String;
	inline static function set_clientID(value:String):String
		return clientID = value ?? '1093650535103615096';

	/**
	 * Whether the rich presence has already been initialized.
	 */
	public static var initialized(default, null):Bool = false;

	/**
	 * The current rich presence instance.
	 */
	public static var instance:DiscordRichPresence = DiscordRichPresence.create();

	/**
	 * Initializes the rich presence.
	 */
	@:allow(imaginative.backend.system.Main.new)
	inline static function init():Void {
		if (initialized)
			return;

		var handlers:DiscordEventHandlers = DiscordEventHandlers.create();
		handlers.ready = Function.fromStaticFunction(onReady);
		handlers.disconnected = Function.fromStaticFunction(onDisconnect);
		handlers.errored = Function.fromStaticFunction(onError);
		Discord.Initialize(RichPresence.clientID, cpp.RawPointer.addressOf(handlers), 1, null);

		sys.thread.Thread.create(() -> {
			while (true) {
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();
				Sys.sleep(2);
			}
		});

		FlxWindow.instance.self.onClose.add(shutdown);

		initialized = true;
	}

	/**
	 * Updates the rich presence.
	 * @param details .
	 * @param state .
	 * @param smallImage .
	 * @param largeImage .
	 */
	public static function changePresence(details:String, ?state:String, ?smallImage:String, largeImage:String = 'engine-logo'):Void {
		var time:Float = Date.now().getTime();

		instance.type = DiscordActivityType_Playing;
		instance.details = details ?? 'In Menus';
		instance.state = state;
		instance.smallImageKey = smallImage;
		instance.largeImageKey = largeImage;
		instance.largeImageText = 'Version ${Main.engineVersion}';
		instance.startTimestamp = Std.int(time * 0.001);

		updatePresence();
	}

	/**
	 * Shuts down the rich presence.
	 * Called when the player closes the window or disables rich presence in the options.
	 */
	public static function shutdown():Void {
		if (!initialized)
			return;

		initialized = false;
		Discord.Shutdown();
	}

	static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void {
		var name:String = request[0].username;
		var globalName:String = request[0].username;
		var discrim:Int = Std.parseInt(request[0].discriminator);
		_log('Connected successfully to ${discrim != 0 ? '$name#$discrim' : name} ($globalName)');
		changePresence(null);
	}

	inline static function onDisconnect(code:Int, message:cpp.ConstCharStar):Void {
		_log('RichPresence disconnected. | ($code:$message)');
	}
	inline static function onError(code:Int, message:cpp.ConstCharStar):Void {
		_log('An error has occurred. | ($code:$message)');
	}

	inline static function updatePresence():Void
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(instance));
}
#end