package imaginative.objects.ui;

/**
 * This class is used for a character's health icon.
 */
final class HealthIcon extends BeatSprite implements ITexture<HealthIcon> {
	// Texture related stuff.
	override public function loadTexture(newTexture:ModPath):HealthIcon
		return cast super.loadTexture(newTexture);
	override public function loadImage(newTexture:ModPath, animated:Bool = false, width:Int = 0, height:Int = 0):HealthIcon
		return cast super.loadImage(newTexture, animated, width, height);
	override public function loadSheet(newTexture:ModPath):HealthIcon
		return cast super.loadSheet(newTexture);

	public var tagName:String;

	override public function renderData(inputData:SpriteData, applyStartValues:Bool = false) {
		var modPath:ModPath = null;
		try {
			modPath = inputData.asset.image;
		} catch(error:haxe.Exception)
			try {
				log('Something went wrong. All try statements were bypassed! Tip: "${modPath.format()}"', ErrorMessage);
			} catch(error:haxe.Exception)
				log('Something went wrong. All try statements were bypassed! Tip: "null"', ErrorMessage);
		super.renderData(inputData, applyStartValues);
	}

	override function loadScript(file:ModPath):Void {
		scripts = new ScriptGroup(this);

		var bruh:Array<ModPath> = ['lead:global', 'lead:icons/global'];
		if (file != null && file.path != null && file.path.trim() != '')
			bruh.push('${file.type}:icons/${file.path}');

		log([for (file in bruh) file.format()], DebugMessage);

		for (icon in bruh)
			for (script in Script.create('${icon.type}:content/objects/${icon.path}'))
				scripts.add(script);

		scripts.load();
	}

	override public function new(x:Float, y:Float, name:String = 'face', faceLeft:Bool = false) {
		super(x, y, 'icons/${tagName = (Paths.fileExists(Paths.icon(name)) ? name : 'face')}');
		if (faceLeft) flipX = !flipX;
		scripts.call('createPost');
	}

	public function changeIcon(newTag:String, pathType:ModPath):Void {
		if (tagName != newTag) {
			// double check tag
			var tag:ModPath = (Paths.fileExists(Paths.icon('$pathType:$newTag')) ? '$pathType:$newTag' : 'face');

			// remove previous icon scripts
			scripts.call('onIconChange');
			var oldScripts:Array<Script> = scripts.members.copy().filter((script:Script) -> return !script.pathing.path.contains('global'));
			for (script in oldScripts)
				if (scripts.members.contains(script)) {
					scripts.remove(script);
					script.end();
				}

			// add new icon scripts
			for (script in Script.create('${tag.type}:content/objects/${tag.path}'))
				scripts.add(script);

			// change texture and data
			loadTexture('${tag.type}:icons/${tag.path}');
			if (Paths.fileExists(Paths.icon(tag)))
				renderData(ParseUtil.object('${tag.type}:icons/${tag.path}', type));

			// finalize stuff
			tagName = tag;
			scripts.call('create');
			scripts.call('createPost');
		}
	}
}