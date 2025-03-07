package imaginative.objects.ui;

import imaginative.backend.scripting.events.objects.PlaySpecialAnimEvent;

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

	override public function update(elapsed:Float):Void {
		scripts.call('update', [elapsed]);
		if (!debugMode) {
			if (isAnimFinished() && doesAnimExist('${getAnimName()}-loop') && !getAnimName().endsWith('-loop')) {
				var event:PlaySpecialAnimEvent = scripts.event('playingSpecialAnim', new PlaySpecialAnimEvent('loop'));
				if (!event.prevented) {
					var prevAnimContext:AnimationContext = animContext;
					playAnim('${getAnimName()}-loop', event.force, event.context, event.reverse, event.frame);
					if (prevAnimContext == IsSinging || prevAnimContext == HasMissed)
						animContext = prevAnimContext; // for `tryDance()` checks
					scripts.call('playingSpecialAnimPost', [event]);
				}
			}

			if (animContext != IsDancing)
				tryDance();
		}
		super_update(elapsed);
		scale.x = FlxMath.lerp(1, scale.x, 0.56);
		scale.y = FlxMath.lerp(1, scale.y, 0.56);
		if (_update != null)
			_update(elapsed);
		scripts.call('updatePost', [elapsed]);
	}

	/**
	 * If true, it prevents the scale bopping from occurring.
	 */
	public var preventScaleBop:Bool = false;
	override public function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		if (preventScaleBop && !(skipNegativeBeats && curBeat < 0) && curBeat % (bopRate < 1 ? 1 : bopRate) == 0)
			scale.set(1.2, 1.2);
		scripts.call('beatHit', [curBeat]);
	}

	public function changeIcon(newTag:String, pathType:ModPath):Void {
		if (tagName != newTag) {
			try {
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
				renderData(ParseUtil.object('${tag.type}:icons/${tag.path}', type));

				// finalize stuff
				tagName = tag;
				scripts.call('create');
				scripts.call('createPost');
			} catch(error:haxe.Exception)
				log('Icon change to "${Paths.icon(newTag).format()}" was unsuccessful.');
		}
	}
}