package imaginative.objects.gameplay.hud;

@SuppressWarnings('checkstyle:FieldDocComment')
enum abstract HUDType(String) from String to String {
	/**
	 * The current HUD instance.
	 */
	public static var direct:HUDTemplate;

	var Template;
	var VSlice;
	var Kade;
	var Psych;
	var Codename;
	var Imaginative;
	var Custom;
}