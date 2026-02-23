package imaginative.objects.gameplay.hud;

import imaginative.objects.gameplay.hud.engines.*;

enum abstract HUDType(String) from String to String {
	/**
	 * The current HUD instance.
	 */
	public static var instance(default, set):GameplayHUD;
	@SuppressWarnings('checkstyle:FieldDocComment')
	static function set_instance(value:GameplayHUD):GameplayHUD {
		if (instance == null || value == null)
			instance = value;
		else {
			_log('[HUDType] A HUD already exists, killing new one.', WarningMessage);
			value.destroy();
		}
		return instance;
	}

	// Base
	/**
	 * States this is base class.
	 * This HUD type has nothing special going for it.
	 */
	var IsBaseHUD = 'base';
	/**
	 * States this is a custom HUD.
	 * Any HUD with this type
	 */
	var IsCustomHUD = 'custom';
	// Engines
	/**
	 * States this is the base funkin VSlice HUD.
	 */
	var IsVSliceHUD = 'vslice';
	/**
	 * States this is the Kade Engine HUD.
	 */
	var IsKadeHUD = 'kade';
	/**
	 * States this is the Psych Engine HUD.
	 */
	var IsPsychHUD = 'psych';
	/**
	 * States this is the Codename Engine HUD.
	 */
	var IsCodenameHUD = 'codename';
	/**
	 * States this is the Imaginative Engine HUD.
	 */
	var IsImaginativeHUD = 'imaginative';

	/**
	 * Returns the hud class based on the key name.
	 * @param desiredHUD The desired hud.
	 * @return GameplayHUD
	 */
	public static function getHUD(desiredHUD:String):GameplayHUD {
		return switch (desiredHUD) {
			case 'default': // based on your settings
				switch (Settings.setup.HUDSelection) {
					case IsVSliceHUD: new VSliceHUD();
					case IsKadeHUD: new KadeHUD();
					case IsPsychHUD: new PsychHUD();
					case IsCodenameHUD: new CodenameHUD();
					case IsImaginativeHUD: new ImaginativeHUD();
					default: new GameplayHUD();
				}
			// allows people to use a specific hud type if they want to without messing with user settings
			case IsVSliceHUD: return new VSliceHUD();
			case IsKadeHUD: return new KadeHUD();
			case IsPsychHUD: return new PsychHUD();
			case IsCodenameHUD: return new CodenameHUD();
			case IsImaginativeHUD: return new ImaginativeHUD();
			default:
				// allows for custom class huds, idk how else to do it at this moment
				var customHUD:GameplayHUD = GlobalScript.call('onHudGet', [desiredHUD]);
				customHUD ??= new ModdedHUD(desiredHUD);
				customHUD;
		}
	}
}