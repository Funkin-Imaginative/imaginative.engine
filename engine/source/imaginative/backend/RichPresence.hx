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
	public static var clientID:String;

	/**
	 * Whether the rich presence has already been initialized.
	 */
	public static var initialized(default, null):Bool = false;

	/**
	 * The current rich presence instance.
	 */
	public static var instance:DiscordRichPresence = new DiscordRichPresence();

	/**
	 * Initializes the rich presence.
	 */
	@:allow(imaginative.backend.system.Main.new)
	inline static function init():Void {
		sys.thread.Thread.create(() -> {
			while (initialized) {
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();
				Sys.sleep(2);
			}
		});

		launchRichPresence();
		FlxWindow.instance.self.onClose.add(shutdown);
	}

	/**
	 * Launches the rich presence.
	 * @param appId The client ID you wish to use. Defaults to base engine ID.
	 */
	public static function launchRichPresence(appId:String = '1093650535103615096'):Void {
		if (clientID == appId) return;
		if (initialized) shutdown();
		clientID = appId;

		var handlers:DiscordEventHandlers = new DiscordEventHandlers();
		handlers.ready = Function.fromStaticFunction(onReady);
		handlers.disconnected = Function.fromStaticFunction(onDisconnect);
		handlers.errored = Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(handlers), false, null);
		initialized = true;

		instance.type = DiscordActivityType_Playing;
		instance.largeImageText = 'Version ${#if KNOWS_VERSION_ID Main.engineVersion #else 'Unknown' #end}';
		instance.smallImageText = 'Its-a-me!';
		changePresence('Using The Engine', 'No advanced stuff for this yet.', 'rodney', 'engine-logo');
	}

	/**
	 * Updates the rich presence.
	 * @param details Changes the rich presence details.
	 * @param state Changes the rich presence state
	 * @param smallImage Changes the rich presence small image.
	 * @param largeImage Changes the rich presence large image.
	 */
	public static function changePresence(?details:String, ?state:String, ?smallImage:String, ?largeImage:String):Void {
		instance.details = details;
		instance.state = state;
		instance.smallImageKey = smallImage;
		instance.largeImageKey = largeImage;

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(instance));
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

	static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void {
		var username:String = request[0].username;
		var globalName:String = request[0].globalName;
		var discrim:Int = Std.parseInt(request[0].discriminator);
		_log('[RichPresence] Connected successfully to $username${discrim != 0 ? '$discrim' : ''} ($globalName)', DebugMessage);
		changePresence();
	}

	inline static function onDisconnect(code:Int, message:cpp.ConstCharStar):Void {
		_log('[RichPresence] Disconnected. | ($code:$message)', DebugMessage);
	}
	inline static function onError(code:Int, message:cpp.ConstCharStar):Void {
		_log('[RichPresence] An error has occurred. | ($code:$message)', ErrorMessage);
	}
}
#end