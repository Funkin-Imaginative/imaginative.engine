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

	// TODO: Write this better.
	/**
	 * The icon name.
	 */
	public var tagName:String;

	override public function renderData(inputData:SpriteData, applyStartValues:Bool = false):Void {
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

	override function get_swapAnimTriggers():Bool
		return true;

	override function loadScript(file:ModPath):Void {
		scripts = new ScriptGroup(this);

		var bruh:Array<ModPath> = ['lead:global', 'lead:icons/global'];
		if (file != null && file.path != null && file.path.trim() != '')
			bruh.push(file);

		for (sprite in bruh)
			for (script in Script.create('${sprite.type}:content/objects/${sprite.path}'))
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
		scale.x = FunkinUtil.lerp(scale.x, spriteOffsets.scale.x, 0.30);
		scale.y = FunkinUtil.lerp(scale.y, spriteOffsets.scale.y, 0.30);
		if (_update != null)
			_update(elapsed);
		scripts.call('updatePost', [elapsed]);
	}

	/**
	 * If true, it prevents the scale bopping from occurring.
	 */
	public var preventScaleBop:Bool = false;
	/**
	 * The scale multiplier for scale bopping.
	 */
	public var bopScaleMult:Position = new Position(1.1, 1.1);
	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		if (!preventScaleBop && !(skipNegativeBeats && curBeat < 0) && curBeat % (bopRate < 1 ? 1 : bopRate) == 0)
			scale.set(spriteOffsets.scale.x * bopScaleMult.x, spriteOffsets.scale.y * bopScaleMult.y);
		scripts.call('beatHit', [curBeat]);
	}

	/**
	 * Changes the icon.
	 * @param newTag The new icon tag.
	 * @param pathType The mod path type.
	 */
	public function changeIcon(newTag:String, pathType:ModType = ANY):Void {
		if (tagName != newTag) {
			try {
				var prevAnim:String = getAnimName();
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
				playAnim(prevAnim);
				scripts.call('createPost');
			} catch(error:haxe.Exception)
				log('Icon change to "${Paths.icon(newTag).format()}" was unsuccessful.');
		}
	}
}