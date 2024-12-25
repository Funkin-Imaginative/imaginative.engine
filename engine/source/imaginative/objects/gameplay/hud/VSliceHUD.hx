package imaginative.objects.gameplay.hud;

import imaginative.objects.gameplay.hud.HUDTemplate.HUDType;

class VSliceHUD extends HUDTemplate {
	override function get_type():HUDType
		return VSlice;

	override public function getFieldYLevel(downscroll:Bool = false, ?field:ArrowField):Float {
		field ??= ArrowField.player;
		var height:Float = field?.strums?.height ?? 161;
		var yLevel:Float = (downscroll ? FlxG.height - height - 24 : 24) + (height / 2);
		return call(true, 'onGetFieldY', [downscroll, yLevel], yLevel);
	}
}