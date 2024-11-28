#if DISCORD_RICH_PRESENCE
package backend;

import cpp.Function;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

/**
 * Class for applying rich presence onto the users discord profile.
 * @author Zylfx
 */
class RichPresence {
	/**
	 * The client ID for the rich presence.
	 */
	public static final clientID:String = '1093650535103615096';

	/**
	 * Whether the rich presence has already been initialized.
	 */
	public static var initialized:Bool = false;

	/**
	 * The current rich presence instance.
	 */
	public static var direct:DiscordRichPresence = DiscordRichPresence.create();

	/**
	 * Initializes the rich presence.
	 */
	@:allow(backend.system.Main.new)
	static function init():Void {
		if (initialized) return;

		final handlers:DiscordEventHandlers = DiscordEventHandlers.create();
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

		FlxWindow.direct.self.onClose.add(shutdown);

		initialized = true;
	}

	/**
	 * Updates the rich presence.
	 */
	public static function changePresence(details:String, ?state:String, ?smallImage:String, largeImage:String = 'engine-logo'):Void {
		final time:Float = Date.now().getTime();

		direct.type = DiscordActivityType_Playing;
		direct.details = details ?? 'In Menus';
		direct.state = state;
		direct.smallImageKey = smallImage;
		direct.largeImageKey = largeImage;
		direct.largeImageText = 'Version ${Main.engineVersion}';
		direct.startTimestamp = Std.int(time * 0.001);

		updatePresence();
	}

	/**
	 * Shuts down the rich presence.
	 * Called when the player closes the window or disables rich presence in the options.
	 */
	public static function shutdown():Void {
		if (!initialized) return;
		initialized = false;
		Discord.Shutdown();
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void {
		final name:String = request[0].username;
		final globalName:String = request[0].username;
		final discrim:Int = Std.parseInt(request[0].discriminator);
		_log('Connected successfully to ${discrim != 0 ? '$name#$discrim' : name} ($globalName)');
		changePresence(null);
	}

	inline private static function onDisconnect(code:Int, message:cpp.ConstCharStar):Void {
		_log('RichPresence disconnected. | ($code:$message)');
	}
	inline private static function onError(code:Int, message:cpp.ConstCharStar):Void {
		_log('An error has occurred. | ($code:$message)');
	}

	inline private static function updatePresence():Void
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(direct));
}
#end