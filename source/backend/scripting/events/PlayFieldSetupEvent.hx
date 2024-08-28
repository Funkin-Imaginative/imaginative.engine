package backend.scripting.events;

final class PlayFieldSetupEvent extends ScriptEvent {
	public var enemyIcon:String = 'face';
	public var playerIcon:String = 'face';

	public var cameras:Array<FlxCamera> = [];
	public var camera(get, set):FlxCamera;
	inline function get_camera():FlxCamera return cameras[0];
	inline function set_camera(value:FlxCamera):FlxCamera return cameras[0] = value;

	override public function new(enemyIcon:String = 'face', playerIcon:String = 'face', cameras:Array<FlxCamera>) {
		super();
		this.enemyIcon = enemyIcon;
		this.playerIcon = playerIcon;
		this.cameras = cameras == null ? [] : cameras;
	}
}