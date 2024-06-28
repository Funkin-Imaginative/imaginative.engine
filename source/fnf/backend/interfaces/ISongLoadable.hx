package fnf.backend.interfaces;

/**
 * Literally just so `PlayField`'s `state` var won't be a bitch.
 * Gave it the `State:SongState` thing for defining bullshit.
 */
interface ISongLoadable<State:SongState> {
	var playField(default, null):PlayField;
	var scripts:ScriptGroup;
}