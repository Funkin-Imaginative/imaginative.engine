package fnf.backend.scripting.events;

final class PlayFieldSetupEvent extends ScriptEvent {
	public var oppoIconColor:FlxColor = FlxColor.RED;
	public var oppoIcon:String = 'face';

	public var playIconColor:FlxColor = 0xFF66FF33;
	public var playIcon:String = 'face';
	
	public var cameras:Array<FlxCamera> = [];
	public var camera(get, set):FlxCamera;
	private var get_camera():FlxCamera return cameras[0];
	private var set_camera(value:FlxCamera):FlxCamera return cameras[0] = value;

	override public function new(oppoIconColor:FlxColor = FlxColor.RED, oppoIcon:String = 'face', playIconColor:FlxColor = 0xFF66FF33, playIcon:String = 'face', cameras:Array<FlxCamera> = []) {
		super();
		this.oppoIconColor = oppoIconColor;
		this.oppoIcon = oppoIcon;
		this.playIconColor = playIconColor;
		this.playIcon = playIcon;
		this.cameras = cameras;
	}
}