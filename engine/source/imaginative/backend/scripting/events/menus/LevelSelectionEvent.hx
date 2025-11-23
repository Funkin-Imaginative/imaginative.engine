package imaginative.backend.scripting.events.menus;

final class LevelSelectionEvent extends MenuSFXEvent {
	/**
	 * The level data.
	 */
	public var data(get, never):LevelData;
	inline function get_data():LevelData
		return holder.data;
	/**
	 * The level holder.
	 */
	public var holder(default, null):LevelHolder;

	/**
	 * The difficulty data.
	 */
	public var diffData(get, never):DifficultyData;
	inline function get_diffData():DifficultyData
		return diffHolder.data;
	/**
	 * The difficulty holder.
	 */
	public var diffHolder(default, null):DifficultyHolder;

	/**
	 * The json name of the level.
	 */
	public var levelKey(default, null):String;
	/**
	 * The key name of the difficulty.
	 */
	public var difficultyKey(default, null):String;
	/**
	 * The key name of the variant.
	 */
	public var variantKey:String;

	/**
	 * If true the level is locked.
	 */
	public var isLocked(get, never):Bool;
	inline function get_isLocked():Bool
		return holder.isLocked || diffHolder.isLocked;

	override public function new(holder:LevelHolder, diffHolder:DifficultyHolder, levelKey:String, difficultyKey:String, variantKey:String) {
		super();
		this.holder = holder;
		this.diffHolder = diffHolder;
		this.levelKey = levelKey;
		this.difficultyKey = difficultyKey;
		this.variantKey = variantKey;
	}
}