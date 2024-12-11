package backend.objects;

import flixel.addons.effects.FlxSkewedSprite;

// TODO: Look back at ISelfGroup code.
class SelfContainedSprite extends FlxSkewedSprite {
	var group:BeatSpriteGroup;

	override public function new(x:Float = 0, y:Float = 0, ?simpleGraphic:flixel.system.FlxAssets.FlxGraphicAsset) {
		super(0, 0, simpleGraphic);
		group = new BeatSpriteGroup(x, y);
		group.add(this);
	}
}