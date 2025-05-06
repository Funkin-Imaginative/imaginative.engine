package imaginative.backend.scripting.events.menus;

@SuppressWarnings('checkstyle:CodeSimilarity')
final class SongSelectionEvent extends MenuSFXEvent {
	/**
	 * The song data.
	 */
	public var data(get, never):SongData;
	inline function get_data():SongData
		return holder.data;
	/**
	 * The song holder.
	 */
	public var holder(default, null):SongHolder;

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
	 * The folder name of the song.
	 */
	public var songKey(default, null):String;
	/**
	 * The key name of the difficulty.
	 */
	public var difficultyKey(default, null):String;
	/**
	 * The key name of the variant.
	 */
	public var variantKey:String;

	/**
	 * If true, the song is locked.
	 */
	public var isLocked(get, never):Bool;
	inline function get_isLocked():Bool
		return holder.isLocked || diffHolder.isLocked;

	override public function new(holder:SongHolder, diffHolder:DifficultyHolder, songKey:String, difficultyKey:String, variantKey:String) {
		super();
		this.holder = holder;
		this.diffHolder = diffHolder;
		this.songKey = songKey;
		this.difficultyKey = difficultyKey;
		this.variantKey = variantKey;
	}
}